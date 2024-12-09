//
//  OpenAIChatStreamingDeltaBlockTests.swift
//  AIProxy
//
//  Created by Murilo Araujo on 09/12/24.
//

import XCTest
@testable import AIProxy

final class OpenAIChatStreamingDeltaBlockTests: XCTestCase {
    func testTextDeltaIsDecodable() {
        let line = """
        data: {"id":"chatcmpl-9jAXUtD5xAKjjgo3XBZEawyoRdUGk","object":"chat.completion.chunk","created":1720552300,"model":"gpt-3.5-turbo-0125","system_fingerprint":null,"choices":[{"index":0,"delta":{"content":"FINDME"},"logprobs":null,"finish_reason":null}],"usage":null}
        """
        let res = OpenAIChatStreamingDeltaBlock.from(line: line)
        XCTAssertEqual("FINDME", res?.choices.first?.delta.content)
    }
    
    func testToolCallDeltaIsDecodable() {
        let line = """
        data: {"id":"chatcmpl-123","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"tool_calls":[{"index":0,"id":"call_123","function":{"name":"get_weather","arguments":"{\\\"location\\\":\\\"San Francisco\\\"}"}}]},"finish_reason":null}]}
        """
        let res = OpenAIChatStreamingDeltaBlock.from(line: line)
        XCTAssertEqual("get_weather", res?.choices.first?.delta.toolCalls?.first?.function?.name)
        XCTAssertEqual("{\"location\":\"San Francisco\"}", res?.choices.first?.delta.toolCalls?.first?.function?.arguments)
    }
    
    func testPartialToolCallDeltaIsDecodable() {
        let line = """
        data: {"id":"chatcmpl-123","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"tool_calls":[{"index":0,"function":{"arguments":"\\"}}]},"finish_reason":null}]}
        """
        let res = OpenAIChatStreamingDeltaBlock.from(line: line)
        XCTAssertEqual("\"", res?.choices.first?.delta.toolCalls?.first?.function?.arguments)
    }
}
