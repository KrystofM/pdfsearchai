//
//  EmbedDocument.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/6/23.
//

import Foundation
import PDFKit

struct PDFSelectionRanges: Codable {
    var ranges: [NSRange] = []
    var pages: [Int] = []
}

class PDFEmbed {
    let document: PDFDocument
    let embedder: Embedder
    public var embeddings: [[Float]]
    public var selectionRanges: [PDFSelectionRanges]
    
    init(document: PDFDocument, embedder: Embedder) {
        self.document = document
        self.embedder = embedder
        self.embeddings = []
        self.selectionRanges = []
    }
    
    func searchDocument(query: String, k_similar: Int = 4) async throws -> [PDFSelection] {
        let startTime = DispatchTime.now()
        print("Starting embedding of query")
        let queryEmbedding = try await self.embedder.embed(chunks: [query])[0]
        let embeddingTime = DispatchTime.now()
        print("Embedding time: \(Double(embeddingTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000) seconds")
        print("Computing similarities")
        let similarities = computeSimilarities(self.embeddings, queryEmbedding)
        let similarityTime = DispatchTime.now()
        print("Similarity time: \(Double(similarityTime.uptimeNanoseconds - embeddingTime.uptimeNanoseconds) / 1_000_000_000) seconds")
        print("Sorting similarities")
        let sortedSimilarities = similarities.sorted(by: { $0.similarity > $1.similarity })
        let sortTime = DispatchTime.now()
        print("Sort time: \(Double(sortTime.uptimeNanoseconds - similarityTime.uptimeNanoseconds) / 1_000_000_000) seconds")
        var selectionResults: [PDFSelection] = []
        print("Adding best results to array")
        for i in 0..<min(k_similar, sortedSimilarities.count) {
            selectionResults.append(selectionRangeToPDFSelection(self.selectionRanges[sortedSimilarities[i].index]))
        }
        let selectionTime = DispatchTime.now()
        print("Selection time: \(Double(selectionTime.uptimeNanoseconds - sortTime.uptimeNanoseconds) / 1_000_000_000) seconds")
        print("Finished!")
        let endTime = DispatchTime.now()
        print("Total time: \(Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000) seconds")
        return selectionResults
    }
    
    func embedDocument() async throws -> Void {
        let chunks: [String]
        chunks = splitDocumentIntoPages(self.document)
        print("Total chunks: \(chunks.count)")
        self.embeddings = try await self.embedder.embed(chunks: chunks)
    }
    
    
    func selectionRangeToPDFSelection(_ selectionRange: PDFSelectionRanges) -> PDFSelection {
        let selection = PDFSelection(document: self.document)
        for i in 0..<selectionRange.ranges.count {
            let range = selectionRange.ranges[i]
            let page = self.document.page(at: selectionRange.pages[i])
            selection.add((page?.selection(for: range))!)
        }
        return selection
    }
    
    func splitDocumentIntoPages(_ document: PDFDocument) -> [String] {
        var pages: [String] = []
        let pageCount = document.pageCount
        
        for pageIndex in 0..<pageCount {
            guard let page = document.page(at: pageIndex) else {
                print("page retrieval failed")
                continue
            }

            let string = page.string ?? ""
            pages.append(string)

            let nsRange = NSRange(location: 0, length: string.count)
            var pdfSelectionRanges = PDFSelectionRanges()
            pdfSelectionRanges.ranges.append(nsRange)
            pdfSelectionRanges.pages.append(pageIndex)
            selectionRanges.append(pdfSelectionRanges)
        }
        
        return pages
    }

    
    func splitDocumentIntoSelections(_ document: PDFDocument) -> [String] {
        var chunks: [String] = []
        let wordCountLimit = 150
        let pageCount = document.pageCount
        
        // print(document.string?.count)
        
        for pageIndex in 0..<pageCount {
            guard let page = document.page(at: pageIndex) else {
                print("page fuckup")
                continue
            }
            // print("Page index: \(pageIndex)")
            let string = page.string ?? ""
            // print(page.attributedString?.length)
            let words = string.components(separatedBy: .whitespaces)
            // print("Words on page: \(words.count)")
            // print("First word: \(words[0])")
            // print("Second word: \(words[1])")
            var selectionString = ""
            
            for word in words {
                if selectionString.split(separator: " ").count >= wordCountLimit {
                    
                    if let selectionRange = string.range(of: selectionString, options: .caseInsensitive, range: string.startIndex..<string.endIndex, locale: nil) {
                        let nsRange = NSRange(selectionRange, in: string)
                        chunks.append(selectionString)
                        var pdfSelectionRanges = PDFSelectionRanges()
                        pdfSelectionRanges.ranges.append(nsRange)
                        pdfSelectionRanges.pages.append(pageIndex)
                        selectionRanges.append(pdfSelectionRanges)
                    }
                    selectionString = ""
                }
                selectionString += word + " "
            }
            
            if !selectionString.isEmpty {
                if let selectionRange = string.range(of: selectionString, options: .caseInsensitive, range: string.startIndex..<string.endIndex, locale: nil) {
                    let nsRange = NSRange(selectionRange, in: string)
                    chunks.append(selectionString)
                    var pdfSelectionRanges = PDFSelectionRanges()
                    pdfSelectionRanges.ranges.append(nsRange)
                    pdfSelectionRanges.pages.append(pageIndex)
                    selectionRanges.append(pdfSelectionRanges)
                }
            }
        }
        
        return chunks
    }
    
    func computeSimilarities(_ embeddings: [[Float]], _ given: [Float]) -> [(index: Int, similarity: Float)] {
        var similarities = [(index: Int, similarity: Float)]()
        for i in 0..<embeddings.count {
            let similarity = cosineSimilarity(embeddings[i], given)
            similarities.append((index: i, similarity: similarity))
        }
        return similarities
    }
    
    func cosineSimilarity(_ vectorA: [Float], _ vectorB: [Float]) -> Float {
        let dotProduct = zip(vectorA, vectorB).map { $0 * $1 }.reduce(0, +)
        let magnitudeA = sqrt(vectorA.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(vectorB.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (magnitudeA * magnitudeB)
    }
}
