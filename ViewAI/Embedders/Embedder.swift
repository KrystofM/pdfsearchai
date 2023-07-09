//
//  Embedder.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/8/23.
//

import Foundation

protocol Embedder {
    func embed(chunks: [String]) async throws -> [[Float]]
}
