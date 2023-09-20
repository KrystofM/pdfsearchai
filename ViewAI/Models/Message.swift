//
//  Message.swift
//  DemoChat
//
//  Created by Sihao Lu on 3/25/23.
//

import Foundation
import OpenAI
import PDFKit

struct Message {
    var id: String
    var role: Chat.Role
    var content: String
    var rawContent: String?
    var name: String?
    var functionCall: ChatFunctionCall?
    var createdAt: Date
    var selections: [PDFSelection]?
}

extension Message: Equatable, Identifiable {}
