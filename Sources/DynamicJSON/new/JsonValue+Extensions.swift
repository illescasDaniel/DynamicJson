//
//  File.swift
//  
//
//  Created by Daniel Illescas Romero on 21/5/22.
//

import Foundation

public extension JsonValue {
	init?(any: Any?) {
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
		case let dictionary as [String: Any]:
			var jsonValueDictionary: [String: JsonValue] = [:]
			for (key, value) in dictionary {
				if let jsonValue = JsonValue(any: value) {
					jsonValueDictionary[key] = jsonValue
				} else {
					return nil
				}
			}
			self.init(jsonValueDictionary)
		case nil:
			self.init(nil)
		default:
			return nil
		}
	}
	
	init(anyIgnoringErrors any: Any?) {
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
					values.append(.null)
				}
			}
			self.init(values)
		case let dictionary as [String: Any]:
			self.init(dictionary.compactMapValues {
				JsonValue(any: $0)
			})
		case nil:
			self.init(nil)
		default:
			self.init(nil)
		}
	}
	
	init(_ integer: Int) {
		self = .integer(integer)
	}
	
	init(_ double: Double) {
		self = .double(double)
	}
	
	init(_ string: String) {
		self = .string(string)
	}
	
	init(_ boolean: Bool) {
		self = .boolean(boolean)
	}
	
	init(_ array: [JsonValue]) {
		self = .array(array)
	}
	
	init(_ dictionary: [String: JsonValue]) {
		self = .dictionary(dictionary)
	}
	
	init(_ null: ()?) {
		self = .null
	}
}

extension JsonValue: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Int
	public init(integerLiteral value: IntegerLiteralType) {
		self.init(value)
	}
}

extension JsonValue: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Double
	public init(floatLiteral value: FloatLiteralType) {
		self.init(value)
	}
}

extension JsonValue: ExpressibleByStringLiteral {
	public typealias StringLiteralType = String
	public init(stringLiteral value: StringLiteralType) {
		self.init(value)
	}
}

extension JsonValue: ExpressibleByBooleanLiteral {
	public typealias BooleanLiteralType = Bool
	public init(booleanLiteral value: BooleanLiteralType) {
		self.init(value)
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
		self.init(nil)
	}
}

public extension JsonValue {
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
			return array
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
			return dictionary
		}
		return nil
	}
	var nsDictionary: NSDictionary? {
		if case .dictionary(let dictionary) = self {
			let dictionaryWithNulls = dictionary.compactMapValues { value -> Any? in
				if case .null = value {
					return nil
				} else {
					return value
				}
			}
			return NSDictionary(dictionary: dictionaryWithNulls)
		}
		return nil
	}
	var nsDictionaryWithNull: NSDictionary? {
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
	var anyDictionary: [String: Any?]? {
		if case .dictionary(let dictionary) = self {
			return dictionary.mapValues { $0.any }
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
		case .integer(let value): return value
		case .double(let value): return value
		case .string(let value): return value
		case .boolean(let value): return value
		case .array(let value):
			return value.map { $0.any }
		case .dictionary(let value):
			return value.compactMapValues { $0.any }
		case .null: return nil
		}
	}
	var isNull: Bool {
		if case .null = self {
			return true
		}
		return false
	}
}

extension JsonValue: Equatable {
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
	
	public func seemsEqual(to other: Self) -> Bool {
		if self == other {
			return true
		}
		
		switch (self, other) {
		case (.integer(let integer), .double(let double)):
			return Double(integer) == double
		case (.double(let double), .integer(let integer)):
			return double == Double(integer)
		case (.string(let string), .integer(let integer)):
			return string == String(integer)
		case (.integer(let integer), .string(let string)):
			return String(integer) == string
		case (.boolean(let boolean), .integer(let integer)):
			return (boolean == true ? 1 : 0) == integer
		case (.integer(let integer), .boolean(let boolean)):
			return integer == (boolean == true ? 1 : 0)
		case (.array(let array1), .array(let array2)):
			return zip(array1, array2).contains { values in
				!values.0.seemsEqual(to: values.1)
			} ? false : true
		case (.dictionary(let dictionary1), .dictionary(let dictionary2)):
			guard Set(dictionary1.keys) == Set(dictionary2.keys) else {
				return false
			}
			for key in dictionary1.keys {
				if let value1 = dictionary1[key],
				   let value2 = dictionary2[key],
				   !value1.seemsEqual(to: value2)
				{
					return false
				}
			}
			return true
		default:
			return false
		}
	}
}

