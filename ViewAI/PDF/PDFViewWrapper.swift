//
//  PDFViewWrapper.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/5/23.
//

import Foundation
import PDFKit
import SwiftUI

struct PDFViewWrapper: NSViewRepresentable {
    typealias NSViewType = PDFView
    
    let document: PDFDocument
    var pdfDestination: PDFDestination?
    var defaultDestination: PDFDestination {
        return PDFDestination(page: document.page(at: 0)!, at: CGPoint(x: 0, y: document.page(at: 0)!.bounds(for: .mediaBox).height))
    }
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.backgroundColor = NSColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)
        return pdfView
    }
        
    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.go(to: pdfDestination ?? defaultDestination)
    }
    
    
}
