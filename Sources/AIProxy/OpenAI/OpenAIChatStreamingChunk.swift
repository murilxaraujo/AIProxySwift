//
//  OpenAIChatStreamingChunk.swift
//  AIProxy
//
//  Created by Murilo Araujo on 09/12/24.
//

import Foundation

public enum OpenAIChatStreamingChunk {
    /// The String argument is the chat completion response text "delta", meaning the new bit
    /// of text that just became available. It is not the full message.
    case text(String)
    
    /// The name of the tool that the model wants to call, and a buffered input to the function.
    /// The input argument is not a "delta". Internally to this lib, we accumulate the tool
    /// call deltas and map them to [String: Any] once all tool call deltas have been received.
    case toolCall(name: String, id: String, arguments: [String: Any])
}
