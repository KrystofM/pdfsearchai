//
//  AppViewModel.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/17/23.
//

import Foundation


class AppViewModel: ObservableObject {
    @Published var isEmbeddingLoaded: Bool
    @Published var embeddedDocument: PDFEmbed?
    let pdf: PDFReadWrite
    var openAIKey: String
    private let embedPDFStore: EmbedPDFStore = EmbedPDFStore()
    
    init(pdf: PDFReadWrite, openAIKey: String) {
        self.pdf = pdf
        self.isEmbeddingLoaded = false
        self.openAIKey = openAIKey
    }
    
    func loadEmbedding() async {
        embeddedDocument = PDFEmbed(
            document: pdf.document,
            embedder: OpenAIEmbedder(
                openai_key: self.openAIKey
            )
        )
        
        do {
            if (try !EmbedPDFStore.checkPdfDataFileExists(pdfIdentifier: pdf.documentId)) {
                try await createEmbeddingAndSave()
            } else {
                try await loadSavedEmbedding()
            }
        } catch {
            print("Failed loading embeddings!")
        }
    }
    
    func updateOpenAIKey(_ newKey: String) {
        self.openAIKey = newKey
        embeddedDocument?.updateEmbedder(embedder: OpenAIEmbedder(
            openai_key: self.openAIKey
        ))
    }
    
    func createEmbeddingAndSave() async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let startTime = Date()
        print("[\(formatter.string(from: startTime))] Embedding document")
        
        try await embeddedDocument?.embedDocument()
        
        let embedTime = Date()
        let embedDuration = embedTime.timeIntervalSince(startTime)
        print("[\(formatter.string(from: embedTime))] Embedding done! [\(embedDuration) sec]")
        
        try await embedPDFStore.save(
            pdfIdentifier: pdf.documentId,
            embeddedPDF: pdfEmbedToStore(embed: embeddedDocument!)
        )
        
        let saveTime = Date()
        let saveDuration = saveTime.timeIntervalSince(embedTime)
        print("[\(formatter.string(from: saveTime))] Embedding saved! [\(saveDuration) sec]")
        
        isEmbeddingLoaded = true
    }
    
    func loadSavedEmbedding() async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let startTime = Date()
        print("[\(formatter.string(from: startTime))] Embedding loading")
        
        let embeddedPDFStore = try await embedPDFStore.load(pdfIdentifier: pdf.documentId)
        
        let loadTime = Date()
        let loadDuration = loadTime.timeIntervalSince(startTime)
        print("[\(formatter.string(from: loadTime))] Embedding loaded from store [\(loadDuration) sec]")
        
        storeToPdfEmbed(embed: embeddedDocument!, store: embeddedPDFStore)
        
        let storeTime = Date()
        let storeDuration = storeTime.timeIntervalSince(loadTime)
        print("[\(formatter.string(from: storeTime))] Embedding stored [\(storeDuration) sec]")
        
        isEmbeddingLoaded = true
    }
 }
