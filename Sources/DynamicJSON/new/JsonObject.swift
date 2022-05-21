//
//  File.swift
//  
//
//  Created by Daniel Illescas Romero on 21/5/22.
//

import Foundation

public enum JsonObject {
	case array([JsonValue])
	case dictionary([String: JsonValue])
}

extension JsonObject: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = JsonValue
	public init(arrayLiteral elements: JsonValue...) {
		self = .array(elements)
	}
}

extension JsonObject: ExpressibleByDictionaryLiteral {
	public typealias Key = String
	public typealias Value = JsonValue
	
	public init(dictionaryLiteral elements: (String, JsonValue)...) {
		self = .dictionary(Dictionary(elements, uniquingKeysWith: { $1 }))
	}
}
