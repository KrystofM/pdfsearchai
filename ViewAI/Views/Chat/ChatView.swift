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
    @Environment(\.dateProviderValue) var dateProvider

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
                    let raw = chatStore.prepareRawContent(searchResults, message: message)
                    let message = Message(
                        id: idProvider(),
                        role: .user,
                        content: message,
                        rawContent: raw,
                        createdAt: dateProvider()
                    )
                    print(raw)
                    
                    await chatStore.sendMessage(
                        message,
                        conversationId: chatStore.currentConversation.id,
                        searchResults: searchResults,
                        model: selectedModel
                    )
                }
            }
        )
    }
}
