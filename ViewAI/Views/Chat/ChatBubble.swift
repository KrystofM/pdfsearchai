//
//  ChatBubble.swift
//  ViewAI
//
//  Created by Krystof Mitka on 6/15/23.
//

import Foundation
import SwiftUI

struct ChatBubble: View {
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
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(assistantBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
