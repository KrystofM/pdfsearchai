//
//  ChatView.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/23/23.
//

import Combine
import SwiftUI
import AppKit
import OpenAI
import PDFKit

public struct ChatView: View {
    @ObservedObject var chatStore: ChatStore
    @ObservedObject var embedStore: AppViewModel
    let selectReference: (PDFSelection) -> Void
    
    @Environment(\.idProviderValue) var idProvider
    @Environment(\.dateProviderValue) var dateProvider
    
    @State var errorMes: Error?

    init(chatStore: ChatStore, embedStore: AppViewModel, selectReference: @escaping (PDFSelection) -> Void) {
        self.chatStore = chatStore
        self.embedStore = embedStore
        self.selectReference = selectReference
    }
    
    public var body: some View {
         DetailView(
            conversation: chatStore.currentConversation,
            error: errorMes,
            sendMessage: { message, selectedModel in
                Task {
                    do {
                        errorMes = nil
                        
                        let searchResults = try await embedStore.embeddedDocument?.searchDocument(query: message) ?? []
                        
                        let message = Message(
                            id: idProvider(),
                            role: .user,
                            content: message,
                            rawContent: chatStore.prepareRawContent(searchResults, message: message),
                            createdAt: dateProvider()
                        )
                        
                        await chatStore.sendSingularMessage(
                            message,
                            conversationId: chatStore.currentConversation.id,
                            searchResults: searchResults,
                            model: selectedModel
                        )
                                                
                    } catch {
                        errorMes = error
                    }
                }
            },
            selectReference: selectReference
        )
    }
}
