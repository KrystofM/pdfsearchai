//
//  PDFDocument.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/13/23.
//

import Foundation
import PDFKit

extension PDFDocument {
    
    static var searchAnnotationColor: NSColor {
       return .yellow
    }
    
    func annotateSearchResults(_ selections: [PDFSelection]) {
        selections.forEach { selection in
            let annotation = PDFAnnotation(bounds: selection.bounds(for: selection.pages[0]), forType: .highlight, withProperties: nil)
            annotation.color = PDFDocument.searchAnnotationColor
            annotation.endLineStyle = .square
            annotation.startLineStyle = .square
            annotation.contents = selection.string
            selection.pages[0].addAnnotation(annotation)
        }
    }
    
    func removeSearchResults() {
        for i in 0..<self.pageCount {
            if let page = self.page(at: i) {
                page.annotations.forEach { annotation in
                    // @TODO: this is very scuffed
                    if annotation.color == PDFDocument.searchAnnotationColor {
                        page.removeAnnotation(annotation)
                    }
                }
            }
        }
    }
}
