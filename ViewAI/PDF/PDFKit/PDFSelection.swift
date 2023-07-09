//
//  PDFSelection.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/13/23.
//

import Foundation
import PDFKit

extension PDFSelection: Identifiable {
    
    public var id: String {
        return "\(firstPage.label ?? "0")\(bounds(for: firstPage).origin.x)\(bounds(for: firstPage).origin.y)\(bounds(for: firstPage).size.width)\(bounds(for: firstPage).size.height)"
    }
    
    var firstPage: PDFPage {
        return self.pages.first!
    }
    
    var pageString: String {
        let pageRange = self.pages
        let firstPage = firstPage.label
        return "Page \(firstPage ?? "0")"
    }
    
    var destination: PDFDestination {
        let bounds = self.bounds(for: firstPage)
        return PDFDestination(page: firstPage, at: CGPoint(x: bounds.minX, y: bounds.minY + bounds.height + 5))
    }
    
}
