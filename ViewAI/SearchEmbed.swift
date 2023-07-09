//
//  SearchEmbed.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/8/23.
//

import Foundation

class SearchEmbed {
    let embeddedDocument: EmbeddedDocument
    let k_similar: Int
    
    init(embeddedDocument: EmbeddedDocument, k_similar: Int = 5) {
        self.embeddedDocument = embeddedDocument
        self.k_similar = k_similar
    }
    
    func searchDocument(query: String) {
        let queryEmbedding = self.embedder.embed(text: EmbedDocument.cleanText(text: query))
        let similarities = computeSimilarities(self.embeddedDocument.keys, queryEmbedding)
        let sortedSimilarities = similarities.sorted(by: { $0.similarity > $1.similarity })
        for i in 0..<k_similar {
            print("Similarity: \(sortedSimilarities[i].similarity)")
            print("Text: \(self.embeddedDocument[sortedSimilarities[i].index]!)")
        }
    
    }
    
}
