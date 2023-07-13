//
//  ViewAIApp.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/1/23.
//

import SwiftUI

@main
struct MainApp: App {
    @StateObject private var dataController = DataController()
    let idProvider: () -> String
    let dateProvider: () -> Date
    
    init() {
        self.idProvider = {
            UUID().uuidString
        }
        self.dateProvider = Date.init
    }
    
    var body: some Scene {
        DocumentGroup(newDocument: PDFReadWrite()) { file in
            AppView(pdf: file.$document, idProvider: idProvider, dateProvider: dateProvider)
                .onAppear {
                    NSApp.windows.first?.setContentSize(NSScreen.main?.frame.size ?? NSSize(width: 800, height: 600))
                }
        }
         
        
        .commands {
            // Commands
        }
        
        Settings {
            SettingsView()
        }
    }
}
