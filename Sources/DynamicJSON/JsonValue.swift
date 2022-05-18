//
//  File.swift
//  
//
//  Created by Daniel Illescas Romero on 6/5/22.
//

import Foundation

extension JsonValue.InternalValue {
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
	var null: ()? {
		if case .null = self {
			return nil
		}
		return ()
	}
}

@dynamicMemberLookup
public struct JsonValue {
	
	public enum InternalValue {
		case integer(Int)
		case double(Double)
		case string(String)
		case boolean(Bool)
		case array([InternalValue])
		case dictionary([String: InternalValue])
		case null
	}
	
	public let value: InternalValue

	public init?(any: Any?) {
		switch any {
		case let value as Int: self.init(value)
		case let value as Double: self.init(value)
		case let value as String: self.init(value)
		case let value as Bool: self.init(value)
		case let array as [Any]:
			var values: [JsonValue] = []
			for value in array {
				if let jsonValue = JsonValue(any: value) {
					values.append(jsonValue)
				} else {
					return nil
				}
			}
			self.init(values)
		case let value as [String: Any]:
			self.init(value.compactMapValues {
				JsonValue(any: $0)
			})
		case nil:
			self.init(nil)
		default:
			return nil
		}
	}
	
	public init(_ internalValue: InternalValue) {
		self.value = internalValue
	}
	
	public init(_ integer: Int) {
		self.init(.integer(integer))
	}
	
	public init(_ double: Double) {
		self.init(.double(double))
	}
	
	public init(_ string: String) {
		self.init(.string(string))
	}
	
	public init(_ boolean: Bool) {
		self.init(.boolean(boolean))
	}
	
	public init(_ array: [JsonValue]) {
		self.init(.array(array.map(\.value)))
	}
	
	public init(_ dictionary: [String: JsonValue]) {
		let dictionary: [String: InternalValue] = dictionary.mapValues { jsonValue in
			jsonValue.value
		}
		self.init(.dictionary(dictionary))
	}
	
	public init(_ null: ()?) {
		self.init(.null)
	}
	
	public subscript<T>(dynamicMember member: KeyPath<InternalValue, T>) -> T {
		return value[keyPath: member]
	}
}

extension JsonValue: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Int
	public init(integerLiteral value: IntegerLiteralType) {
		self.value = .integer(value)
	}
}

extension JsonValue: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Double
	public init(floatLiteral value: FloatLiteralType) {
		self.value = .double(value)
	}
}

extension JsonValue: ExpressibleByStringLiteral {
	public typealias StringLiteralType = String
	public init(stringLiteral value: StringLiteralType) {
		self.value = .string(value)
	}
}

extension JsonValue: ExpressibleByBooleanLiteral {
	public typealias BooleanLiteralType = Bool
	public init(booleanLiteral value: BooleanLiteralType) {
		self.value = .boolean(value)
	}
}

extension JsonValue: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = JsonValue
	
	public init(arrayLiteral elements: ArrayLiteralElement...) {
		self.init(elements)
	}
}

extension JsonValue: ExpressibleByDictionaryLiteral {
	public typealias Key = String
	public typealias Value = JsonValue
	
	public init(dictionaryLiteral elements: (Key, Value)...) {
		self.init(Dictionary.init(elements, uniquingKeysWith: { first, last in last }))
	}
}

extension JsonValue: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self.value = .null
	}
}

extension JsonValue: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.value == rhs.value
	}
}

extension JsonValue.InternalValue: Equatable {
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
