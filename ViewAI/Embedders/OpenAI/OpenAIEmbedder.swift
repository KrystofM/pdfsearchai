//
//  OpenAIEmbedder.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/6/23.
//

import Foundation


class OpenAIEmbedder: Embedder {
    static let embedEndpoint: String = "https://api.openai.com/v1/embeddings"
    static let embedModel: String = "text-embedding-ada-002"
    let OPENAI_KEY: String
    
    init(openai_key: String) {
        self.OPENAI_KEY = openai_key
    }
    
    func embed(chunks: [String]) async throws -> [[Float]] {
        let req = self.createEmbedRequest(chunks: chunks)
        let (data, _) = try await URLSession.shared.data(for: req)
        let embeddings = try JSONDecoder().decode(OpenAIEmbeddingDTO.self, from: data)
        
        return embeddings.data.map { $0.embedding }
    }
    
    private func createEmbedRequest(chunks: [String]) -> URLRequest {
        var request = URLRequest(url: URL(string: OpenAIEmbedder.embedEndpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(self.OPENAI_KEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = ["input": chunks, "model": OpenAIEmbedder.embedModel] as [String : Any]
        let requestBodyData = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = requestBodyData
        
        return request
    }
    
    
}
