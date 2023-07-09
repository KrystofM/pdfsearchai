//
//  PDFEmbedToStore.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/15/23.
//

import Foundation
import PDFKit

// item: [ [ [1, 2, 3] ], [ [0, 150], [0, 200] ] ]

func pdfEmbedToStore(embed: PDFEmbed) -> EmbeddedPDFStoreFormat {
    let embeddings = embed.embeddings
    var selectionRanges: [[[Int]]] = []
    for selectionRange in embed.selectionRanges {
        selectionRanges.append([])
        selectionRanges[selectionRanges.count - 1].append([])
        for page in selectionRange.pages {
            selectionRanges[selectionRanges.count - 1][0].append(page)
        }
        selectionRanges.append([])
        for range in selectionRange.ranges {
            selectionRanges[selectionRanges.count - 1].append([range.location, range.length])
        }
    }
    return EmbeddedPDFStoreFormat(sR: selectionRanges, e: embeddings)
}

func storeToPdfEmbed(embed: PDFEmbed, store: EmbeddedPDFStoreFormat) -> Void {
    embed.embeddings = store.e
    var selectionRanges: [PDFSelectionRanges] = []
    store.sR.enumerated().forEach({ (i, value) in
        
        if i % 2 == 0 {
            // pages
            selectionRanges.append(PDFSelectionRanges())
            selectionRanges[selectionRanges.count - 1].pages.append(contentsOf: value[0])
        } else {
            // ranges
            for range in value {
                selectionRanges[selectionRanges.count - 1].ranges.append(NSRange(location: range[0], length: range[1]))
            }
        }
    })
    embed.selectionRanges = selectionRanges
}

