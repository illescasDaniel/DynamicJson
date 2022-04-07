// Logger.swift
// by Daniel Illescas Romero
// Github: @illescasDaniel
// License: MIT

import struct Foundation.Data
import protocol Foundation.NSCopying
import struct Foundation.NSZone
import class Foundation.NSDictionary
import class Foundation.JSONSerialization
import class Foundation.JSONEncoder
import class Foundation.JSONDecoder
import func Foundation.NSSelectorFromString
import func os.os_log
import struct os.log.OSLogType

fileprivate class Box<T> {
	var value: T
	init(value: T) {
		self.value = value
	}
}

@dynamicMemberLookup
public struct Json {
	
	private let parent: (String, Box<Json>)?
	private var jsonObject: Any
	
	public static var null: Json {
		return Json()
	}
	
	// MARK: - Initializers
	
	public init(data: Data) {
		let decodedJson = try? JSONSerialization.jsonObject(with: data, options: [])
		self.init(value: decodedJson, parent: nil)
	}
	
	public init<T>(_ object: T?) {
		self.init(object, parent: nil)
	}
	
	public init(raw rawJson: String) {
		if let jsonData = rawJson.data(using: .utf8) {
			self.init(data: jsonData)
		} else {
			self.init(value: rawJson, parent: nil)
		}
	}
	
	// MARK: Private initializers
	
	private init() {
		self.jsonObject = NSDictionary()
		self.parent = nil
	}
	
	private init(data: Data, parent: (String, Box<Json>)?) {
		let decodedJson = try? JSONSerialization.jsonObject(with: data, options: [])
		self.init(value: decodedJson, parent: parent)
	}
	
	private init(value: Any?, parent: (String, Box<Json>)?) {
		if let validValue = value {
			self.jsonObject = validValue
		} else {
			self.jsonObject = NSDictionary()
		}
		self.parent = parent
	}
	
	private init<T>(_ object: T?, parent: (String, Box<Json>)?) {
		if object is Json, let json = object as? Json {
			self.init(json)
		} else if object is Data, let data = object as? Data {
			self.init(data: data)
		} else if let object = object, JSONSerialization.isValidJSONObject(object) {
			self.init(value: object, parent: parent)
		} else { // mmmmm
			self.init(value: object, parent: parent)
		}
	}
	
	// MARK: - Subscripts
	
	public subscript(dynamicMember member: String) -> Json {
		get {
			if let dictionary = self.jsonObject as? [String: Any] {
				let value = dictionary[member]
				if value == nil {
					if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
						os_log("Json - Member not found for key \"%@\"", type: .error, member)
					}
				}
				return Json(value, parent: (member, Box(value: self)))
			}
			
			let value: [String: Any]? = nil
			return Json(value, parent: (member, Box(value: self)))
		}
		set(newValue) {
			if var dictionary = self.jsonObject as? [String: Any] {
				dictionary[member] = newValue.jsonObject
				self.jsonObject = dictionary
			} else {
				self.jsonObject = [member: newValue.jsonObject]
			}
			if let (key, json) = self.parent {
				json.value[dynamicMember: key] = Json(self.jsonObject)
			}
			
		}
	}
	
	public subscript(dynamicMember member: String) -> Any {
		get {
			return self[dynamicMember: member] as Json
		} set(newValue) {
			if newValue is Json {
				self[dynamicMember: member] = newValue
			} else {
				self[dynamicMember: member] = Json(newValue)
			}
		}
	}
	
	public subscript(_ index: Int) -> Json {
		get {
			if let jsonArray = self.jsonObject as? [Any] {
				let value = jsonArray[index]
				return Json(value)
			}
			if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
				os_log("Json - Value \"%@\" is not an array", type: .error, "\(self.jsonObject)")
			}
			return Json.null
		}
		set {
			if var jsonArray = self.jsonObject as? [Any] {
				jsonArray[index] = newValue.jsonObject
				self.jsonObject = jsonArray
			}
			if let (key, json) = self.parent {
				json.value[dynamicMember: key] = Json(self.jsonObject)
			}
		}
	}
	
	public subscript(_ index: Int) -> Any {
		get {
			return self[index] as Json
		} set {
			self[index] = Json(newValue)
		}
	}
	
	public subscript(_ keyPath: KeyPath<Json.MemberStub, Json.MemberStub>) -> Json {
		let member = MemberStub()
		let key = member[keyPath: keyPath].key
		if let value: Any? = self[key] {
			return Json(value)
		}
		return Json.null
	}
	
	public subscript<T>(_ keyPath: String) -> T? {
		return self.nsdictionary?.value(forKeyPath: keyPath) as? T
	}
	
	// MARK: - Codable
	
	public func decoded<T: Decodable>() -> T? {
		if let jsonData = self.encoded() {
			return try? JSONDecoder().decode(T.self, from: jsonData)
		}
		return nil
	}
	
	public func encoded() -> Data? {
		if JSONSerialization.isValidJSONObject(self.jsonObject),
			let jsonData = try? JSONSerialization.data(withJSONObject: self.jsonObject, options: .prettyPrinted) {
			return jsonData
		}
		return nil
	}
	
	// MARK: -
	
	public var string: String? {
		return self.jsonObject as? String
	}
	public var int: Int? {
		return self.jsonObject as? Int
	}
	public var bool: Bool? {
		return self.jsonObject as? Bool
	}
	public var double: Double? {
		return self.jsonObject as? Double
	}
	public var array: [Any]? {
		return self.jsonObject as? [Any]
	}
	func array<T>(of type: T.Type) -> [T]? {
		let selfArray = self.array
		let mappedArray = selfArray?.map { $0 as? T }
		return mappedArray?.count == selfArray?.count ? mappedArray?.compactMap { $0 } : nil
	}
	public var dictionary: [String: Any]? {
		return self.jsonObject as? [String: Any]
	}
	public var nsdictionary: NSDictionary? {
		return self.jsonObject as? NSDictionary
	}
	public var any: Any {
		return self.jsonObject
	}
	public var json: Json {
		return self
	}
	
	//
	
	public var isJsonEmpty: Bool {
		return self.dictionary?.isEmpty == true
	}
}

extension Json: CustomStringConvertible {
	public var description: String {
		return String(describing: self.jsonObject)
	}
}

// MARK: - Details

public extension Json {
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
//
//public protocol JsonConvertible {
//	var json: Json { get }
//}
//public extension JsonConvertible {
//	var json: Json {
//		return Json(self)
//	}
//}
//
//extension String: JsonConvertible {}
//extension Int: JsonConvertible {}
//extension Bool: JsonConvertible {}
//extension Double: JsonConvertible {}
//extension Array: JsonConvertible {}
//extension Dictionary: JsonConvertible {}
//
//public extension Encodable {
//	var inJson: Json {
//		return Json(self)
//	}
//}