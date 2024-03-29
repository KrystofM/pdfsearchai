//
//  ChatBubble.swift
//  ViewAI
//
//  Created by Krystof Mitka on 6/15/23.
//

import Foundation
import SwiftUI
import PDFKit

struct ChatBubble: View {
    let selectReference: (PDFSelection) -> Void
    let message: Message

    private var assistantBackgroundColor: Color {
        return Color(nsColor: NSColor.lightGray)
    }

    private var userForegroundColor: Color {
        return Color(nsColor: NSColor.white)
    }

    private var userBackgroundColor: Color {
        return Color(nsColor: NSColor.systemBlue)
    }

    var body: some View {
        HStack {
            switch message.role {
            case .assistant:
                VStack {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(assistantBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    if let selections = message.selections {
                        HStack {
                            ForEach(selections, id: \.self) { selection in
                                Button(action: {
                                    selectReference(selection)  
                                }) {
                                    Text("\(selection.firstPageString)")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                    }
                }
                Spacer(minLength: 24)
            case .user:
                Spacer(minLength: 24)
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .foregroundColor(userForegroundColor)
                    .background(userBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            case .function:
                EmptyView()
            case .system:
                EmptyView()
            }
        }
    }
}
