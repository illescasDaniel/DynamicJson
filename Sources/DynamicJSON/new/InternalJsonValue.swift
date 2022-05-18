//
//  File.swift
//  
//
//  Created by Daniel Illescas Romero on 18/5/22.
//

import Foundation

public enum InternalJsonValue {
	case integer(Int)
	case double(Double)
	case string(String)
	case boolean(Bool)
	case array([InternalJsonValue])
	case dictionary([String: InternalJsonValue])
	case null
}

public extension InternalJsonValue {
	var integer: Int? {
		if case .integer(let integer) = self {
			return integer
		}
		return nil
	}
	var double: Double? {
		if case .double(let double) = self {
			return double
		}
		return nil
	}
	var boolean: Bool? {
		if case .boolean(let boolean) = self {
			return boolean
		}
		return nil
	}
	var string: String? {
		if case .string(let string) = self {
			return string
		}
		return nil
	}
	var array: [JsonValue]? {
		if case .array(let array) = self {
			return array.map { JsonValue($0) }
		}
		return nil
	}
	func arrayValue<T>() -> [T?]? {
		if case .array(let array) = self {
			return array.map { $0.any as? T }
		}
		return nil
	}
	func compactArrayValue<T>() -> [T]? {
		if case .array(let array) = self {
			return array.compactMap { $0.any as? T }
		}
		return nil
	}
	var anyArray: [Any?]? {
		if case .array(let array) = self {
			return array.map { $0.any }
		}
		return nil
	}
	var anyCompactArray: [Any]? {
		if case .array(let array) = self {
			return array.compactMap { $0.any }
		}
		return nil
	}
	var dictionary: [String: JsonValue]? {
		if case .dictionary(let dictionary) = self {
			return dictionary.mapValues { JsonValue($0) }
		}
		return nil
	}
	var nsDictionary: NSDictionary? {
		if case .dictionary(let dictionary) = self {
			let dictionaryWithNulls = dictionary.mapValues { value -> Any in
				if case .null = value {
					return NSNull()
				} else {
					return value
				}
			}
			return NSDictionary(dictionary: dictionaryWithNulls)
		}
		return nil
	}
	var anyCompactDictionary: [String: Any]? {
		if case .dictionary(let dictionary) = self {
			return dictionary.compactMapValues { $0.any }
		}
		return nil
	}
	var any: Any? {
		switch self {
		case .integer(let value):
			return value
		case .double(let value):
			return value
		case .string(let value):
			return value
		case .boolean(let value):
			return value
		case .array(let value):
			return value.map { $0.any }
		case .dictionary(let value):
			return value.compactMapValues { $0.any }
		case .null:
			return nil
		}
	}
	var isNull: Bool {
		if case .null = self {
			return true
		}
		return false
	}
}

extension InternalJsonValue: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.integer(let integer1), .integer(let integer2)):
			return integer1 == integer2
		case (.double(let double1), .double(let double2)):
			return double1 == double2
		case (.string(let string1), .string(let string2)):
			return string1 == string2
		case (.boolean(let boolean1), .boolean(let boolean2)):
			return boolean1 == boolean2
		case (.array(let array1), .array(let array2)):
			return array1 == array2
		case (.dictionary(let dictionary1), .dictionary(let dictionary2)):
			return dictionary1 == dictionary2
		case (.null, .null):
			return true
		default:
			return false
		}
	}
}

