//
//  OpenAIAsyncChunks.swift
//  AIProxy
//
//  Created by Murilo Araujo on 09/12/24.
//

import Foundation

/// Iterate the streaming chunks using the following pattern:
///
///     let stream = try await openAIService.streamingChatCompletionRequest(...)
///
///     for try await chunk in stream {
///         switch chunk {
///         case .text(let text):
///             print(text)
///         case .toolCall(name: let name, id: let id, arguments: let args):
///             print("Model wants to call tool \(name) with arguments \(args)")
///         }
///     }
public struct OpenAIAsyncChunks: AsyncSequence {
    public typealias Element = OpenAIChatStreamingChunk
    private let asyncLines: AsyncLineSequence<URLSession.AsyncBytes>
    
    internal init(asyncLines: AsyncLineSequence<URLSession.AsyncBytes>) {
        self.asyncLines = asyncLines
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var asyncBytesIterator: AsyncLineSequence<URLSession.AsyncBytes>.AsyncIterator
        
        mutating public func next() async throws -> OpenAIChatStreamingChunk? {
            var toolCallAccumulator: [Int: (id: String?, name: String?, arguments: String?)] = [:]
            
            while let line = try await asyncBytesIterator.next() {
                guard let block = OpenAIChatStreamingDeltaBlock.from(line: line) else {
                    continue
                }
                
                for choice in block.choices {
                    if let content = choice.delta.content {
                        return .text(content)
                    }
                    
                    if let toolCalls = choice.delta.toolCalls {
                        for toolCall in toolCalls {
                            let index = toolCall.index
                            var current = toolCallAccumulator[index] ?? (id: nil, name: nil, arguments: nil)
                            
                            if let id = toolCall.id {
                                current.id = id
                            }
                            if let name = toolCall.function?.name {
                                current.name = name
                            }
                            if let args = toolCall.function?.arguments {
                                current.arguments = (current.arguments ?? "") + args
                            }
                            
                            toolCallAccumulator[index] = current
                            
                            // If we have all necessary parts, emit the tool call
                            if let id = current.id,
                               let name = current.name,
                               let arguments = current.arguments,
                               let argumentsData = arguments.data(using: .utf8),
                               let parsedArguments = try? JSONSerialization.jsonObject(with: argumentsData) as? [String: Any] {
                                toolCallAccumulator.removeValue(forKey: index)
                                return .toolCall(name: name, id: id, arguments: parsedArguments)
                            }
                        }
                    }
                }
            }
            return nil
        }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(asyncBytesIterator: asyncLines.makeAsyncIterator())
    }
}
