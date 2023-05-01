//
//  ContentView.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/1/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ViewAIDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(ViewAIDocument()))
    }
}
