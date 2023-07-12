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
        idProvider: @escaping () -> String
    ) {
        self.openAIClient = openAIClient
        self.idProvider = idProvider
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
        var preparedMessage = "Search Results:\n"
        for (index, result) in searchResults.enumerated() {
            preparedMessage += "\(index + 1). \(result.string ?? "")\n"
        }
        preparedMessage += "\nPlease answer based on the provided search results and specify the index(es) of the used resource(s)."
        
        return message + preparedMessage
    }
    
    @MainActor
    func sendMessage(
        _ message: Message,
        conversationId: Conversation.ID,
        searchResults: [PDFSelection],
        model: Model
    ) async {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        conversations[conversationIndex].messages.append(message)

        await completeChat(
            conversationId: conversationId,
            model: model
        )
    }
    
    @MainActor
    func completeChat(
        conversationId: Conversation.ID,
        model: Model
    ) async {
        guard let conversation = conversations.first(where: { $0.id == conversationId }) else {
            return
        }
                
        conversationErrors[conversationId] = nil

        do {
            guard let conversationIndex = conversations.firstIndex(where: { $0.id == conversationId }) else {
                return
            }

            let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = openAIClient.chatsStream(
                query: ChatQuery(
                    model: model,
                    messages: conversation.messages.map { message in
                        Chat(role: message.role, content: message.rawContent)
                    }
                )
            )
            
            
            for try await partialChatResult in chatsStream {
                for choice in partialChatResult.choices {
                    let existingMessages = conversations[conversationIndex].messages
                    // Function calls are also streamed, so we need to accumulate.
                    var messageText = choice.delta.content ?? ""
                    let message = Message(
                        id: partialChatResult.id,
                        role: choice.delta.role ?? .assistant,
                        content: messageText,
                        rawContent: messageText,
                        createdAt: Date(timeIntervalSince1970: TimeInterval(partialChatResult.created))
                    )
                    if let existingMessageIndex = existingMessages.firstIndex(where: { $0.id == partialChatResult.id }) {
                        // Meld into previous message
                        let previousMessage = existingMessages[existingMessageIndex]
                        let combinedMessage = Message(
                            id: message.id, // id stays the same for different deltas
                            role: message.role,
                            content: previousMessage.content + message.content,
                            rawContent: previousMessage.content + message.content,
                            createdAt: message.createdAt
                        )
                        conversations[conversationIndex].messages[existingMessageIndex] = combinedMessage
                    } else {
                        conversations[conversationIndex].messages.append(message)
                    }
                }
            }
        }  catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            print("context", context)
        } catch {
            print("error: ", error)
        }
    }
}
