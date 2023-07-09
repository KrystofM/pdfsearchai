//
//  EmbeddedPDFStoreFormat.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/15/23.
//

import Foundation


// PDFSelectionRanges: [([NSRange], [Int])] = [[[Int]]]

struct EmbeddedPDFStoreFormat: Codable {
    let sR: [[[Int]]]
    let e: [[Float]]
}
