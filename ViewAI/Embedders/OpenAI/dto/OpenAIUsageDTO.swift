//
//  OpenAIUsageDTO.swift
//  ViewAI
//
//  Created by Krystof Mitka on 5/7/23.
//

import Foundation

struct OpenAIUsageDTO: Decodable {
    let prompt_tokens: Int;
    let total_tokens: Int;
}
