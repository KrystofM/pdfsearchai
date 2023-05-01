//
//  ViewAIApp.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/1/23.
//

import SwiftUI

@main
struct ViewAIApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: ViewAIDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
