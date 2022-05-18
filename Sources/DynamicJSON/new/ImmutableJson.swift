// ImmutableJson.swift
// by Daniel Illescas Romero
// Github: @illescasDaniel
// License: MIT

import struct Foundation.Data
import class Foundation.NSDictionary
import class Foundation.JSONSerialization
import class Foundation.JSONEncoder
import class Foundation.JSONDecoder
import func os.os_log
import struct os.log.OSLogType

@dynamicMemberLookup
public struct ImmutableJson {
	
	private let jsonValue: JsonValue
	
	public static var null: ImmutableJson {
		ImmutableJson(anyJsonObject: JsonValue(.null))
	}
	
	// MARK: - Initializers
	
	public init(data: Data) {
		let decodedJson = try? JSONSerialization.jsonObject(with: data, options: [])
		if let validDictionary = decodedJson as? [String: Any] {
			self.init(anyJsonObject: JsonValue(any: validDictionary) ?? JsonValue(.null))
		} else {
			self = .null
		}
	}
	
	public init(array: [JsonValue]) {
		self.init(anyJsonObject: JsonValue(array))
	}
	
	public init(dictionary: [String: JsonValue]) {
		self.init(anyJsonObject: JsonValue(dictionary))
	}
	
	public init(rawJsonString: String) {
		let jsonData = Data(rawJsonString.utf8)
		self.init(data: jsonData)
	}
	
	// MARK: Private initializers
	
	private init(anyJsonObject: JsonValue) {
		self.jsonValue = anyJsonObject
	}
	
	// MARK: - Subscripts
	
	// dynamicMemberLookup implementation (e.g.: myJson.name)
	public subscript(dynamicMember member: String) -> ImmutableJson {
		self.jsonValue.value.dictionary?[member].flatMap(ImmutableJson.init) ?? .null
	}
	
	// array subscript by index (e.g.: myJson[1])
	public subscript(_ index: Int) -> ImmutableJson {
		guard let array = self.jsonValue.value.array else { return .null }
		return array.indices.contains(index) ? ImmutableJson(anyJsonObject: array[index]) : .null
	}
	
	// keypath subscript using strings (e.g.: myJson["address.street"]
	public subscript(_ keyPath: String) -> ImmutableJson {
		
		// nsdictionary implementation
//		guard let dictionary = self.jsonValue.anyCompactDictionary else { return .null }
//		let value = NSDictionary(dictionary: dictionary).value(forKeyPath: keyPath)
//		return ImmutableJson(anyJsonObject: JsonValue(any: value) ?? JsonValue(.null))
		
		let keys = keyPath.split(separator: ".")
		if keys.isEmpty {
			return self[dictionaryKey: keyPath]
		}
		var currentJson = self
		for (index, key) in keys.enumerated() {
			if index == keys.count - 1 {
				let jsonValue = currentJson.jsonValue.dictionary?[String(key)] ?? JsonValue(.null)
				return ImmutableJson(anyJsonObject: jsonValue)
			} else {
				let jsonChild: ImmutableJson = currentJson[dynamicMember: String(key)]
				if jsonChild.jsonValue.dictionary != nil {
					currentJson = jsonChild
				}
			}
		}
		fatalError()
	}
	
	// keypath subscript using strings (e.g.: myJson["address.street"]
	public subscript(dictionaryKey key: String) -> ImmutableJson {
		guard let value = self.jsonValue.dictionary?[key] else { return .null }
		return ImmutableJson(anyJsonObject: value)
	}
	
	// keypath subscript using KeyPath (e.g.: myJson[\.address.street]
	subscript(_ keyPath: KeyPath<ImmutableJson.MemberStub, ImmutableJson.MemberStub>) -> ImmutableJson {
		let member = MemberStub()
		let key = member[keyPath: keyPath].key
		return self[key]
	}
	
	// MARK: - Codable
	
	public func decoded<T: Decodable>() -> T? {
		if let jsonData = self.encoded() {
			return try? JSONDecoder().decode(T.self, from: jsonData)
		}
		return nil
	}
	
	public func encoded() -> Data? {
		guard let dictionary = self.jsonValue.anyCompactDictionary else { return nil }
		if JSONSerialization.isValidJSONObject(dictionary),
			let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
			return jsonData
		}
		return nil
	}
	
	public func jsonString() -> String? {
		guard let data = encoded() else { return nil }
		return String(data: data, encoding: .utf8)
	}
	
	// utils
	
	public func getValue() -> JsonValue { jsonValue }
	public func getInteger() -> Int? { jsonValue.value.integer }
	public func getString() -> String? { jsonValue.value.string }
	public func getDouble() -> Double? { jsonValue.value.double }
	public func getArray() -> [JsonValue]? { jsonValue.value.array }
	public func getAnyArray() -> [Any?]? { jsonValue.value.anyArray }
	public func getAnyCompactArray() -> [Any?]? { jsonValue.value.anyArray }
	public func getArrayValue<T>() -> [T?]? { jsonValue.value.arrayValue() }
	public func getCompactArrayValue<T>() -> [T]? { jsonValue.value.compactArrayValue() }
	public func getBoolean() -> Bool? { jsonValue.boolean }
	public func getIsNull() -> Bool { jsonValue.value.isNull }
	public func getDictionary() -> [String: JsonValue]? { jsonValue.value.dictionary }
	public func getNSDictionary() -> NSDictionary? { jsonValue.value.nsDictionary }
	public func getCompactDictionaryAnyValue() -> [String: Any]? { jsonValue.value.anyCompactDictionary }
	
	public var isJsonEmpty: Bool {
		return self.jsonValue.dictionary?.isEmpty == true
	}
}

extension ImmutableJson: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = JsonValue
	
	public init(arrayLiteral elements: ArrayLiteralElement...) {
		self.init(array: elements)
	}
}

extension ImmutableJson: ExpressibleByDictionaryLiteral {
	public typealias Key = String
	public typealias Value = JsonValue
	
	public init(dictionaryLiteral elements: (Key, Value)...) {
		self.init(dictionary: Dictionary.init(elements, uniquingKeysWith: { first, last in last }))
	}
}

extension ImmutableJson: CustomStringConvertible {
	public var description: String {
		return "ImmutableJson(\(String(describing: self.jsonValue)))"
	}
}

extension ImmutableJson: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool { lhs.jsonValue == rhs.jsonValue }
	public static func == (lhs: Self, rhs: ()?) -> Bool { lhs.jsonValue.value.any == nil }
	public static func == (lhs: Self, rhs: Int) -> Bool { lhs.jsonValue.value.integer == rhs }
	public static func == (lhs: Self, rhs: Double) -> Bool { lhs.jsonValue.value.double == rhs }
	public static func == (lhs: Self, rhs: String) -> Bool { lhs.jsonValue.value.string == rhs }
	public static func == (lhs: Self, rhs: Bool) -> Bool { lhs.jsonValue.value.boolean == rhs }
	public static func == (lhs: Self, rhs: [JsonValue]) -> Bool { lhs.jsonValue.value.array == rhs }
	public static func == (lhs: Self, rhs: [String: JsonValue]) -> Bool { lhs.jsonValue.value.dictionary == rhs }
}

extension ImmutableJson: Comparable {
	
	public static func < (lhs: ImmutableJson, rhs: ImmutableJson) -> Bool {
		switch rhs.jsonValue.value {
		case .integer(let value): return lhs < value
		case .double(let value): return lhs < value
		case .string(let value): return lhs < value
		case .boolean(let value): return lhs < value
		case .array, .dictionary, .null: return false
		}
	}
	
	public static func > (lhs: ImmutableJson, rhs: ImmutableJson) -> Bool {
		switch rhs.jsonValue.value {
		case .integer(let value): return lhs > value
		case .double(let value): return lhs > value
		case .string(let value): return lhs > value
		case .boolean(let value): return lhs > value
		case .array, .dictionary, .null: return false
		}
	}
	
	public static func >= (lhs: ImmutableJson, rhs: ImmutableJson) -> Bool {
		switch rhs.jsonValue.value {
		case .integer(let value): return lhs >= value
		case .double(let value): return lhs >= value
		case .string(let value): return lhs >= value
		case .boolean(let value): return lhs >= value
		case .array, .dictionary: return false
		case .null:
			if case .null = lhs.jsonValue.value {
				return true
			}
			return false
		}
	}
	
	public static func < (lhs: ImmutableJson, rhs: Int) -> Bool {
		if case .integer(let integer1) = lhs.jsonValue.value {
			return integer1 < rhs
		}
		return false
	}
	
	public static func > (lhs: ImmutableJson, rhs: Int) -> Bool {
		if case .integer(let integer1) = lhs.jsonValue.value {
			return integer1 > rhs
		}
		return false
	}
	public static func >= (lhs: ImmutableJson, rhs: Int) -> Bool {
		if case .integer(let integer1) = lhs.jsonValue.value {
			return integer1 >= rhs
		}
		return false
	}
	
	public static func < (lhs: ImmutableJson, rhs: Double) -> Bool {
		if case .double(let double1) = lhs.jsonValue.value {
			return double1 < rhs
		}
		return false
	}
	public static func > (lhs: ImmutableJson, rhs: Double) -> Bool {
		if case .double(let double1) = lhs.jsonValue.value {
			return double1 > rhs
		}
		return false
	}
	public static func >= (lhs: ImmutableJson, rhs: Double) -> Bool {
		if case .double(let double1) = lhs.jsonValue.value {
			return double1 >= rhs
		}
		return false
	}
	
	public static func < (lhs: ImmutableJson, rhs: String) -> Bool {
		if case .string(let string1) = lhs.jsonValue.value {
			return string1 < rhs
		}
		return false
	}
	public static func > (lhs: ImmutableJson, rhs: String) -> Bool {
		if case .string(let string1) = lhs.jsonValue.value {
			return string1 > rhs
		}
		return false
	}
	public static func >= (lhs: ImmutableJson, rhs: String) -> Bool {
		if case .string(let string1) = lhs.jsonValue.value {
			return string1 >= rhs
		}
		return false
	}
	
	public static func < (lhs: ImmutableJson, rhs: Bool) -> Bool {
		if case .boolean(let boolean1) = lhs.jsonValue.value {
			return boolean1 == false
		}
		return false
	}
	public static func > (lhs: ImmutableJson, rhs: Bool) -> Bool {
		if case .boolean(let boolean1) = lhs.jsonValue.value {
			return boolean1 == true && rhs == false
		}
		return false
	}
	public static func >= (lhs: ImmutableJson, rhs: Bool) -> Bool {
		if case .boolean(let boolean1) = lhs.jsonValue.value {
			return (boolean1 == true && rhs == false) || boolean1 == rhs
		}
		return false
	}
}

// MARK: - Details

public extension ImmutableJson {
	@dynamicMemberLookup
	class MemberStub {
		var key: String
		init(key: String = "") {
			self.key = key
		}
		public subscript(dynamicMember member: String) -> MemberStub {
			get {
				let validKey: String
				if self.key.isEmpty {
					validKey = member
				} else {
					validKey = "\(self.key).\(member)"
				}
				return MemberStub(key: validKey)
			} set {
				self.key = newValue.key
			}
		}
	}
}