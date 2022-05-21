// MyJson.swift
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
public struct MyJson {
	
	private let jsonValue: JsonValue
	
	public static var null: MyJson {
		MyJson(anyJsonValue: .null)
	}
	
	// MARK: - Initializers
	
	public init(data: Data) {
		let decodedJson = try? JSONSerialization.jsonObject(with: data, options: [])
		if let validDictionary = decodedJson as? [String: Any] {
			self.init(anyJsonValue: JsonValue(any: validDictionary) ?? .null)
		} else {
			self = .null
		}
	}
	
	public init(json: JsonObject) {
		switch json {
		case .array(let jsonValueArray):
			self.init(anyJsonValue: JsonValue(jsonValueArray))
		case .dictionary(let jsonValueDictionary):
			self.init(anyJsonValue: JsonValue(jsonValueDictionary))
		}
	}
	
	public init(rawJsonString: String) {
		let jsonData = Data(rawJsonString.utf8)
		self.init(data: jsonData)
	}
	
	// MARK: Private initializers
	
	private init(anyJsonValue: JsonValue) {
		self.jsonValue = anyJsonValue
	}
	
	// MARK: - Subscripts
	
	// dynamicMemberLookup implementation (e.g.: myJson.name)
	public subscript(dynamicMember member: String) -> MyJson {
		self.jsonValue.dictionary?[member].flatMap(MyJson.init) ?? .null
	}
	
	// array subscript by index (e.g.: myJson[1])
	public subscript(_ index: Int) -> MyJson {
		guard let array = self.jsonValue.array else { return .null }
		return array.indices.contains(index) ? MyJson(anyJsonValue: array[index]) : .null
	}
	
	// keypath subscript using string paths (e.g.: myJson["address.street"]
	public subscript(keyPath keyPath: String) -> MyJson {
		
		// nsdictionary implementation
//		guard let dictionary = self.jsonValue.anyCompactDictionary else { return .null }
//		let value = NSDictionary(dictionary: dictionary).value(forKeyPath: keyPath)
//		return MyJson(anyJsonObject: JsonValue(any: value) ?? JsonValue(.null))
		
		let keys = keyPath.split(separator: ".")
		if keys.isEmpty {
			return self[keyPath]
		}
		var currentJson = self
		for (index, key) in keys.enumerated() {
			if index == keys.count - 1 {
				let jsonValue = currentJson.jsonValue.dictionary?[String(key)] ?? .null
				return MyJson(anyJsonValue: jsonValue)
			} else {
				let jsonChild: MyJson = currentJson[dynamicMember: String(key)]
				if jsonChild.jsonValue.dictionary != nil {
					currentJson = jsonChild
				}
			}
		}
		fatalError()
	}
	
	// keypath subscript using string (e.g.: myJson["address"]
	public subscript(_ key: String) -> MyJson {
		guard let value = self.jsonValue.dictionary?[key] else { return .null }
		return MyJson(anyJsonValue: value)
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
	public func getInteger() -> Int? { jsonValue.integer }
	public func getString() -> String? { jsonValue.string }
	public func getDouble() -> Double? { jsonValue.double }
	public func getArray() -> [JsonValue]? { jsonValue.array }
	public func getAnyArray() -> [Any?]? { jsonValue.anyArray }
	public func getAnyCompactArray() -> [Any]? { jsonValue.anyCompactArray }
	public func getArrayValue<T>() -> [T?]? { jsonValue.arrayValue() }
	public func getCompactArrayValue<T>() -> [T]? { jsonValue.compactArrayValue() }
	public func getBoolean() -> Bool? { jsonValue.boolean }
	public func getIsNull() -> Bool { jsonValue.isNull }
	public func getDictionary() -> [String: JsonValue]? { jsonValue.dictionary }
	public func getNSDictionary() -> NSDictionary? { jsonValue.nsDictionary }
	public func getNSDictionaryWithNull() -> NSDictionary? { jsonValue.nsDictionaryWithNull }
	public func getAnyDictionaryValue() -> [String: Any?]? { jsonValue.anyDictionary }
	public func getCompactDictionaryAnyValue() -> [String: Any]? { jsonValue.anyCompactDictionary }
	
	public var isJsonEmpty: Bool {
		return self.jsonValue.dictionary?.isEmpty == true
	}
}

extension MyJson: CustomStringConvertible {
	public var description: String {
		return "MyJson(\(String(describing: self.jsonValue)))"
	}
}

extension MyJson: Equatable {
	
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.isEqual(to: rhs.jsonValue)
	}
	
	public static func ~= (lhs: Self, rhs: Self) -> Bool {
		return lhs.isAlmostEqual(to: rhs.jsonValue, numberDelta: 0.01)
	}
	
	public static func ~= (lhs: Self, rhs: JsonValue) -> Bool {
		return lhs.isAlmostEqual(to: rhs, numberDelta: 0.01)
	}
	
	public func isEqual(to other: JsonValue) -> Bool {
		return self.jsonValue == other
	}
	
	/// `numberDelta` is only applied when comparing integers and doubles between them
	public func isAlmostEqual(to other: JsonValue, numberDelta: Double? = nil) -> Bool {
		return self.jsonValue.isAlmostEqual(to: other, numberDelta: numberDelta)
	}
}
