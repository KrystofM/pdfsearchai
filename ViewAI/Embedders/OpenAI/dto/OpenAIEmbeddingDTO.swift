//
//  OpenAIEmbeddingDTO.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/7/23.
//

import Foundation

struct OpenAIEmbeddingDTO: Decodable {
    let usage: OpenAIUsageDTO;
    let data: [OpenAIDataEmbeddingDTO];
}
