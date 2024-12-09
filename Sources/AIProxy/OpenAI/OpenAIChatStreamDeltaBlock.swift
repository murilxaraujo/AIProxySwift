//
//  OpenAIAsynkChunks.swift
//  AIProxy
//
//  Created by Murilo Araujo on 09/12/24.
//

import Foundation

internal struct OpenAIChatStreamingDeltaBlock: Decodable {
    let choices: [OpenAIDeltaChoice]
    let usage: OpenAIChatUsage?
    
    static func from(line: String) -> Self? {
        guard line.hasPrefix("data: ") else {
            return nil
        }
        
        guard line != "data: [DONE]" else {
            return nil
        }
        
        guard let chunkJSON = line.dropFirst(6).data(using: .utf8),
              let chunk = try? JSONDecoder().decode(Self.self, from: chunkJSON) else {
            aiproxyLogger.warning("Received unexpected JSON from OpenAI: \(line)")
            return nil
        }
        
        return chunk
    }
}

struct OpenAIDeltaChoice: Decodable {
    let delta: OpenAIDelta
    let finishReason: String?
    
    private enum CodingKeys: String, CodingKey {
        case delta
        case finishReason = "finish_reason"
    }
}

struct OpenAIDelta: Decodable {
    let role: String?
    let content: String?
    let toolCalls: [OpenAIToolCallDelta]?
    
    private enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
    }
}

struct OpenAIToolCallDelta: Decodable {
    let index: Int
    let id: String?
    let function: OpenAIFunctionDelta?
    let type: String?
}

struct OpenAIFunctionDelta: Decodable {
    let name: String?
    let arguments: String?
}
