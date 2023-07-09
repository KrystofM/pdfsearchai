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

public struct ChatView: View {
    @ObservedObject var chatStore: ChatStore
    @ObservedObject var embedStore: AppViewModel
    
    @Environment(\.idProviderValue) var idProvider

    init(chatStore: ChatStore, embedStore: AppViewModel) {
        self.chatStore = chatStore
        self.embedStore = embedStore
    }
    
    public var body: some View {
         DetailView(
            conversation: chatStore.currentConversation,
            error: chatStore.conversationErrors[chatStore.currentConversation.id],
            sendMessage: { message, selectedModel in
                Task {
                    let searchResults = try! await embedStore.embeddedDocument?.searchDocument(query: message) ?? []
                    
                    print(searchResults)
                    print(message)
                    
                    await chatStore.sendMessage(
                        Message(
                            id: idProvider(),
                            role: .user,
                            content: message,
                            createdAt: Date.init()
                        ),
                        conversationId: chatStore.currentConversation.id,
                        model: selectedModel
                    )
                }
            }
        )
    }
}
