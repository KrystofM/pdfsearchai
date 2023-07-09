//
//  ViewAIDocument.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/1/23.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

extension UTType {
    static var pdf: UTType {
        UTType(importedAs: "com.adobe.pdf")
    }
}

struct PDFReadWrite: FileDocument {
    var document: PDFDocument
    var documentId: String
    var lastUpdated: Date?
    
    init() {
        self.document = PDFDocument()
        self.documentId = ""
        self.lastUpdated = Date()
    }

    static var readableContentTypes: [UTType] { [.pdf] }

    init(configuration: ReadConfiguration) throws {
        print("Reading the file: \(configuration.file.filename!)")
        guard let fileData = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        document = PDFDocument(data: fileData)!
        var documentIdentificationPointer: CGPDFStringRef?
        CGPDFArrayGetString((document.documentRef?.fileIdentifier)!, 0, &documentIdentificationPointer)
        documentId = (CGPDFStringCopyTextString(documentIdentificationPointer!)! as String).unicodeScalars.map { String($0.value) }.joined()
        lastUpdated = document.documentAttributes?[AnyHashable("ModDate")] as? Date
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: self.document.dataRepresentation()!)
    }
}
