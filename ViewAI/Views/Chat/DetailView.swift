//
//  DetailView.swift
//  ViewAI
//
//  Created by Krystof Mitka on 6/15/23.
//

import Foundation
import AppKit
import OpenAI
import SwiftUI
import PDFKit

struct DetailView: View {
    @State var inputText: String = ""
    @FocusState private var isFocused: Bool
    @State private var showsModelSelectionSheet = false
    @State private var selectedChatModel: Model = .gpt4_1106_preview

    private let availableChatModels: [Model] = [.gpt4, .gpt4_1106_preview]

    let conversation: Conversation
    let error: Error?
    let sendMessage: (String, Model) -> Void
    let selectReference: (PDFSelection) -> Void

    private var fillColor: Color {
        return Color(nsColor: NSColor.textBackgroundColor)
    }

    private var strokeColor: Color {
        return Color(nsColor: NSColor.lightGray)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    List {
                        ForEach(conversation.messages) { message in
                            ChatBubble(selectReference: selectReference, message: message)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .animation(.default, value: conversation.messages)
                    if let error = error {
                        errorMessage(error: error)
                    }

                    inputBar(scrollViewProxy: scrollViewProxy)
                }
                .navigationTitle("Chat")
                .safeAreaInset(edge: .top) {
                    HStack {
                        Text(
                            "Model: \(selectedChatModel)"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .confirmationDialog(
                    "Select model",
                    isPresented: $showsModelSelectionSheet,
                    titleVisibility: .visible,
                    actions: {
                        ForEach(availableChatModels, id: \.self) { model in
                            Button {
                                selectedChatModel = model
                            } label: {
                                Text(model)
                            }
                        }

                        Button("Cancel", role: .cancel) {
                            showsModelSelectionSheet = false
                        }
                    },
                    message: {
                        Text(
                            "View https://platform.openai.com/docs/models/overview for details"
                        )
                        .font(.caption)
                    }
                )
            }
        }
    }

    @ViewBuilder private func errorMessage(error: Error) -> some View {       
        Text(
            error.localizedDescription
        )
        .font(.caption)
        .foregroundColor({
            return Color(.systemRed)
        }())
        .padding(.horizontal)
    }

    @ViewBuilder private func inputBar(scrollViewProxy: ScrollViewProxy) -> some View {
        HStack(alignment: .center, spacing: 8) {
            TextField(
                "Ask the document",
                text: $inputText                
            )
            .font(.system(size: 16))
            .foregroundColor(.primary)
            .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
            .onSubmit {
                withAnimation {
                    tapSendMessage(scrollViewProxy: scrollViewProxy)
                }
            }

            Button(action: {
                withAnimation {
                    tapSendMessage(scrollViewProxy: scrollViewProxy)
                }
            }) {
                Image(systemName: "paperplane")
                   .resizable()
                   .frame(width: 16, height: 16)
                   .padding(12)
            }
            .disabled(inputText == "")
            .buttonStyle(CustomButtonStyle())
            .onHover { isHovered in
                if (isHovered) {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(EdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12))
    }
    
    private func tapSendMessage(
        scrollViewProxy: ScrollViewProxy
    ) {
        sendMessage(inputText, selectedChatModel)
        inputText = ""
    }
}



struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)        
    }
}
