// JsonValue.swift
// by Daniel Illescas Romero
// Github: @illescasDaniel
// License: MIT

import Foundation

public enum JsonValue {
	case integer(Int)
	case double(Double)
	case string(String)
	case boolean(Bool)
	case array([JsonValue])
	case dictionary([String: JsonValue])
	case null
}
