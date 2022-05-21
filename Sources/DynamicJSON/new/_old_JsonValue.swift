//// JsonValue.swift
//// by Daniel Illescas Romero
//// Github: @illescasDaniel
//// License: MIT
//
//import Foundation
//
//@dynamicMemberLookup
//public struct JsonValue {
//	
//	public let value: InternalJsonValue
//
//	public init?(any: Any?) {
//		switch any {
//		case let value as Int: self.init(value)
//		case let value as Double: self.init(value)
//		case let value as String: self.init(value)
//		case let value as Bool: self.init(value)
//		case let array as [Any]:
//			var values: [JsonValue] = []
//			for value in array {
//				if let jsonValue = JsonValue(any: value) {
//					values.append(jsonValue)
//				} else {
//					return nil
//				}
//			}
//			self.init(values)
//		case let value as [String: Any]:
//			self.init(value.compactMapValues {
//				JsonValue(any: $0)
//			})
//		case nil:
//			self.init(nil)
//		default:
//			return nil
//		}
//	}
//	
//	public init(_ internalValue: InternalJsonValue) {
//		self.value = internalValue
//	}
//	
//	public init(_ integer: Int) {
//		self.init(.integer(integer))
//	}
//	
//	public init(_ double: Double) {
//		self.init(.double(double))
//	}
//	
//	public init(_ string: String) {
//		self.init(.string(string))
//	}
//	
//	public init(_ boolean: Bool) {
//		self.init(.boolean(boolean))
//	}
//	
//	public init(_ array: [JsonValue]) {
//		self.init(.array(array.map(\.value)))
//	}
//	
//	public init(_ dictionary: [String: JsonValue]) {
//		let dictionary: [String: InternalJsonValue] = dictionary.mapValues { jsonValue in
//			jsonValue.value
//		}
//		self.init(.dictionary(dictionary))
//	}
//	
//	public init(_ null: ()?) {
//		self.init(.null)
//	}
//	
//	public subscript<T>(dynamicMember member: KeyPath<InternalJsonValue, T>) -> T {
//		return value[keyPath: member]
//	}
//}
//
//extension JsonValue: ExpressibleByIntegerLiteral {
//	public typealias IntegerLiteralType = Int
//	public init(integerLiteral value: IntegerLiteralType) {
//		self.value = .integer(value)
//	}
//}
//
//extension JsonValue: ExpressibleByFloatLiteral {
//	public typealias FloatLiteralType = Double
//	public init(floatLiteral value: FloatLiteralType) {
//		self.value = .double(value)
//	}
//}
//
//extension JsonValue: ExpressibleByStringLiteral {
//	public typealias StringLiteralType = String
//	public init(stringLiteral value: StringLiteralType) {
//		self.value = .string(value)
//	}
//}
//
//extension JsonValue: ExpressibleByBooleanLiteral {
//	public typealias BooleanLiteralType = Bool
//	public init(booleanLiteral value: BooleanLiteralType) {
//		self.value = .boolean(value)
//	}
//}
//
//extension JsonValue: ExpressibleByArrayLiteral {
//	public typealias ArrayLiteralElement = JsonValue
//	
//	public init(arrayLiteral elements: ArrayLiteralElement...) {
//		self.init(elements)
//	}
//}
//
//extension JsonValue: ExpressibleByDictionaryLiteral {
//	public typealias Key = String
//	public typealias Value = JsonValue
//	
//	public init(dictionaryLiteral elements: (Key, Value)...) {
//		self.init(Dictionary.init(elements, uniquingKeysWith: { first, last in last }))
//	}
//}
//
//extension JsonValue: ExpressibleByNilLiteral {
//	public init(nilLiteral: ()) {
//		self.value = .null
//	}
//}
//
//extension JsonValue: Equatable {
//	public static func == (lhs: Self, rhs: Self) -> Bool {
//		return lhs.value == rhs.value
//	}
//}
