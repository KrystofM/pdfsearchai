//
//  SearchResults.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/11/23.
//

import Foundation
import SwiftUI
import PDFKit


struct SearchResults: View {
    var searchResults: [PDFSelection]
    @Binding var selectedSelection: PDFSelection?
    
    var body: some View {
        List(searchResults, selection: $selectedSelection) { selection in
            HStack {
                Text(selection.pageString)
                    .font(.system(size: 11))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                Text(selection.string!)
                    .font(.system(size: 11))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
            }
            .tag(selection)
        }
    }
}
