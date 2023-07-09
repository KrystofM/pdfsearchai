//
//  EmbedDocumentsStore.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/14/23.
//

import Foundation


class EmbedPDFStore {

    private static func fileURL(pdfIdentifier: String) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("\(pdfIdentifier).data")
    }
    
    public static func checkPdfDataFileExists(pdfIdentifier: String) throws -> Bool {
        let fileManager = FileManager.default
        let filePath = try EmbedPDFStore.fileURL(pdfIdentifier: pdfIdentifier)
        return fileManager.fileExists(atPath: filePath.path)
    }

    func load(pdfIdentifier: String) async throws -> EmbeddedPDFStoreFormat {
        let task = Task<EmbeddedPDFStoreFormat, Error> {
            let fileURL = try Self.fileURL(pdfIdentifier: pdfIdentifier)
            guard let data = try? Data(contentsOf: fileURL) else {
                return EmbeddedPDFStoreFormat(sR: [], e: [])
            }
            let embeddedPDF = try JSONDecoder().decode(EmbeddedPDFStoreFormat.self, from: data)
            return embeddedPDF
        }
        return try await task.value
    }
    
    func save(pdfIdentifier: String, embeddedPDF: EmbeddedPDFStoreFormat) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(embeddedPDF)
            let outfile = try Self.fileURL(pdfIdentifier: pdfIdentifier)
            print(outfile)
            try data.write(to: outfile)
            print("written")
        }
        _ = try await task.value
    }
}
