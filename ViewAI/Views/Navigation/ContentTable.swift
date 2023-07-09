//
//  ContentTable.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/11/23.
//

import Foundation
import SwiftUI
import PDFKit

struct ContentTable: View {
    let document: PDFDocument
    @Binding var selectedOutline: PDFOutline?
    @State var selectedOutlineID: String?
    var outlines: [PDFOutline] {
        document.outlineRoot?.children ?? []
    }
    
    func searchOutlines(outlines: [PDFOutline]) -> PDFOutline? {
        for outline in outlines {
            if outline.id == selectedOutlineID {
                return outline
            }
            if let child = searchOutlines(outlines: outline.children ?? []) {
                return child
            }
        }
        return nil
    }
    
    var body: some View {
        List(outlines, children: \.children, selection: $selectedOutlineID) { item in
            Text(item.label!)
                .font(.system(size: 11))
                .padding(.leading, 5)
                .padding(.vertical, 5)
        }
        .onChange(of: selectedOutlineID) { newValue in
            selectedOutline = searchOutlines(outlines: outlines)
        }   
        .navigationTitle("ContentTable")
        .frame(minWidth: 300)
        .padding(.top, 24)
    }
    
}
