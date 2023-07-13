//
//  Message.swift
//  DemoChat
//
//  Created by Sihao Lu on 3/25/23.
//

import Foundation
import OpenAI

struct Message {
    var id: String
    var role: Chat.Role
    var content: String
    var rawContent: String?
    var name: String?
    var functionCall: ChatFunctionCall?
    var createdAt: Date
}

extension Message: Equatable, Codable, Identifiable {}
