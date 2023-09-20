//
//  ChatStore.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/23/23.
//

import Foundation
import Combine
import OpenAI
import PDFKit

public final class ChatStore: ObservableObject {
    public var openAIClient: OpenAIProtocol
    let idProvider: () -> String
    let dateProvider: () -> Date

    @Published var conversations: [Conversation] = []
    @Published var conversationErrors: [Conversation.ID: Error] = [:]
    @Published var selectedConversationID: Conversation.ID?
    
    var currentConversation: Conversation {
        if selectedConversationID == nil {
            self.selectConversation(self.createConversation().id)
        }
        
        return selectedConversation!
    }

    var selectedConversation: Conversation? {
        selectedConversationID.flatMap { id in
            conversations.first { $0.id == id }
        }
    }    

    var selectedConversationPublisher: AnyPublisher<Conversation?, Never> {
        $selectedConversationID.receive(on: RunLoop.main).map { id in
            self.conversations.first(where: { $0.id == id })
        }
        .eraseToAnyPublisher()
    }

    public init(
        openAIClient: OpenAIProtocol,
        idProvider: @escaping () -> String,
        dateProvider: @escaping () -> Date
    ) {
        self.openAIClient = openAIClient
        self.idProvider = idProvider
        self.dateProvider = dateProvider
    }

    // MARK: - Events
    func createConversation() -> Conversation {
        let conversation = Conversation(id: idProvider(), messages: [])
        conversations.append(conversation)
        return conversation
    }
    
    
    func selectConversation(_ conversationId: Conversation.ID?) {
        selectedConversationID = conversationId
    }
    
    func deleteConversation(_ conversationId: Conversation.ID) {
        conversations.removeAll(where: { $0.id == conversationId })
    }
    
    func prepareRawContent(_ searchResults: [PDFSelection], message: String) -> String {
        var finalMessage = "You goal is to help me to understand parts of a large document. I will be asking questions that are aimed at gaining knowledge with respect to this document. Whenever I ask a question I will provide sections of the document that correspond to the question that I am asking. Your goal will be to answer my questions as best as you can while using the document sections as reference. Dont answer it is based on provided sections at the start of your answer. Each section is seperated by '*Section #*' where # will be the number. At the end of your response provide a list of used sections based on their pagenumber and sort them from most important to least. Only answer with numbers of the sections, nothing more or less, seperated by comma. If you did not use a section at all, then dont provide it. ALWAYS CREATE A FUNCTION CALL!\n"
        finalMessage += "Question: "
        finalMessage += message
        finalMessage += "\nSections:\n"
        for (index, result) in searchResults.enumerated() {
            finalMessage += "*Section \(index)*\n \(result.string ?? "")\n"
        }
        
        return finalMessage
    }
    
    func doesContainResponse(text: String) -> Bool {
        let searchText = "\"response\": \""
        return text.contains(searchText)
    }
    
    func getTextAfterResponse(text: String) -> String? {
        guard let rangeStart = text.range(of: "\"response\": \"") else {
            return nil
        }
        
        let startIndex = rangeStart.upperBound
        
        if let rangeEnd = text.range(of: "\",", range: startIndex..<text.endIndex) {
            return String(text[startIndex..<rangeEnd.lowerBound]).replacingOccurrences(of: "\\n", with: "\n")
        } else {
            return String(text[startIndex...]).replacingOccurrences(of: "\\n", with: "\n")
        }
    }
    
    @MainActor
    func sendSingularMessage(
        _ message: Message,
        conversationId: Conversation.ID,
        searchResults: [PDFSelection],
        model: Model
    ) async {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        conversations[conversationIndex].messages.append(message)
        
        let currentMessages = [message]

        conversationErrors[conversationId] = nil
        
        
        var functionCallName = ""
        var functionCallArguments = ""
        do {
            let sectionsFunction = ChatFunctionDeclaration(
                name: "getReponseAndSections",
                description: "Get a response to the question and return a list of sections sorted based on their importance.",
                parameters: .init(
                  type: .object,
                  properties: [
                    "response": .init(type: .string, description: "Detailed and good reponse to the provided question based on the sections given."),
                    "sections": .init(type: .array, description: "The sorted list of sections based on their importance to the response, if a section is not used to create the response do not include it.", items: .init(type: .number))
                  ],
                  required: ["response","sections"]
                )
            )
            
            let functions = [sectionsFunction]

            let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = openAIClient.chatsStream(
                query: ChatQuery(
                    model: model,
                    messages: currentMessages.map { message in
                        Chat(role: message.role, content: message.rawContent)
                    },
                    functions: functions
                )
            )
            
            for try await partialChatResult in chatsStream {
                for choice in partialChatResult.choices {
                    let existingMessages = conversations[conversationIndex].messages
                    // Function calls are also streamed, so we need to accumulate.
                    var messageText = choice.delta.content ?? ""
                    if let functionCallDelta = choice.delta.functionCall {
                        if let nameDelta = functionCallDelta.name {
                            functionCallName += nameDelta
                        }
                        if let argumentsDelta = functionCallDelta.arguments {
                            functionCallArguments += argumentsDelta
                            if (self.doesContainResponse(text: functionCallArguments)) {
                                messageText = self.getTextAfterResponse(text: functionCallArguments) ?? ""
                            }
                        }
                    }
                    if let finishReason = choice.finishReason,
                       finishReason == "function_call" {
                        if (self.doesContainResponse(text: functionCallArguments)) {
                            messageText = self.getTextAfterResponse(text: functionCallArguments) ?? ""
                        }
                    }
                    if let existingMessageIndex = existingMessages.firstIndex(where: { $0.id == partialChatResult.id }) {
                        conversations[conversationIndex].messages[existingMessageIndex].content = messageText
                        conversations[conversationIndex].messages[existingMessageIndex].rawContent = messageText
                    } else {
                        let message = Message(
                            id: partialChatResult.id,
                            role: choice.delta.role ?? .assistant,
                            content: messageText,
                            rawContent: messageText,
                            createdAt: Date(timeIntervalSince1970: TimeInterval(partialChatResult.created))
                        )
                        conversations[conversationIndex].messages.append(message)
                    }
                }
            }
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            print("context", context)
        } catch {
            print("error: ", error)
        }
        
        
    }
    
}
