import XCTest
@testable import DynamicJSON

final class DynamicJSONTests: XCTestCase {
	
	let jsonString1 = """
	{
		"fullName": {
			"firstName": "Daniel",
			"lastName": "Illescas",
			"someNumber": 22.3,
			"values": [1.2, 5.3, 78323.23],
			"parent": {
				"fullName": {
					"firstName": "Peter",
					"lastName": "Illescas",
					"someValue": 223.123
				}
			}
		},
		"age": 22
	}
	"""
	
	func testJSONString() {
		let json = Json(raw: jsonString1)
		jsonValueTypeChecks(json)
		jsonMutability(json: json)
	}
	
	func testJSONData() {
		let json = Json(data: Data(jsonString1.utf8))
		jsonValueTypeChecks(json)
		jsonMutability(json: json)
	}
	
	func testJSONObject() {
		let json = Json([
			"fullName": [
				"firstName": "Daniel",
				"lastName": "Illescas",
				"someNumber": 22.3,
				"values": [1.2, 5.3, 78323.23],
				"parent": [
					"fullName": [
						"firstName": "Peter",
						"lastName": "Illescas",
						"someValue": 223.123
					]
				]
			],
			"age": 22
		])
		jsonValueTypeChecks(json)
		jsonMutability(json: json)
	}
	
	private func jsonValueTypeChecks(_ json: Json) {
		XCTAssertNotNil(json.dictionary)
		XCTAssertNotNil(json.nsdictionary)
		XCTAssertNil(json.string)
		XCTAssertNil(json.int)
		XCTAssertNil(json.double)
		XCTAssertNil(json.array)
		XCTAssertNil(json.bool)
		
		XCTAssertNotNil(json.fullName.dictionary)
		XCTAssertNotNil(json.fullName.nsdictionary)
		XCTAssertNil(json.fullName.string)
		XCTAssertNil(json.fullName.int)
		XCTAssertNil(json.fullName.double)
		XCTAssertNil(json.fullName.array)
		XCTAssertNil(json.fullName.bool)
		
		XCTAssertEqual(
			json.fullName.values.array?.compactMap { $0 as? Double },
			json.fullName.values.array(of: Double.self)
		)
		XCTAssertEqual(
			json.fullName.values.array?.compactMap { $0 as? Double },
			[1.2, 5.3, 78323.23]
		)
		
		let arrayJson: Json = json.fullName.values
		XCTAssertNotNil(arrayJson.array)
		XCTAssertNil(arrayJson.double)
		XCTAssertNil(arrayJson.dictionary)
		XCTAssertNil(arrayJson.nsdictionary)
		XCTAssertNil(arrayJson.string)
		XCTAssertNil(arrayJson.int)
		XCTAssertNil(arrayJson.bool)
		
		let arrayValue: Json = json.fullName.values[1]
		XCTAssertNotNil(arrayValue.double)
		XCTAssertNil(arrayValue.array)
		XCTAssertNil(arrayValue.dictionary)
		XCTAssertNil(arrayValue.nsdictionary)
		XCTAssertNil(arrayValue.string)
		XCTAssertNil(arrayValue.int)
		XCTAssertNil(arrayValue.bool)
		
		let someValue: Json = json.fullName.parent.fullName.someValue
		XCTAssertNotNil(someValue.double)
		XCTAssertNil(someValue.dictionary)
		XCTAssertNil(someValue.nsdictionary)
		XCTAssertNil(someValue.string)
		XCTAssertNil(someValue.int)
		XCTAssertNil(someValue.array)
		XCTAssertNil(someValue.bool)
		
		let someValueJSONFastTraversal: Json = json[\.fullName.parent.fullName.someValue]
		XCTAssertNotNil(someValueJSONFastTraversal.double)
		XCTAssertNil(someValueJSONFastTraversal.dictionary)
		XCTAssertNil(someValueJSONFastTraversal.nsdictionary)
		XCTAssertNil(someValueJSONFastTraversal.string)
		XCTAssertNil(someValueJSONFastTraversal.int)
		XCTAssertNil(someValueJSONFastTraversal.array)
		XCTAssertNil(someValueJSONFastTraversal.bool)
		
		let fullNameFastTraversal: Any? = json["fullName"]
		XCTAssertNotNil(fullNameFastTraversal)
		
		let someValueFastTraversal: Double? = json["fullName.parent.fullName.someValue"]
		XCTAssertNotNil(someValueFastTraversal)
		
		let randomStringJSONFastTraversal: Json = json[\.asdkjhafsd.asdjhlfasdf.kh.j.j.j.asdf]
		XCTAssertNil(randomStringJSONFastTraversal.double)
		let dict = randomStringJSONFastTraversal.dictionary
		XCTAssertTrue(dict == nil || dict?.isEmpty == true)
		let otherDict = randomStringJSONFastTraversal.nsdictionary
		XCTAssertTrue(otherDict == nil || otherDict == [:] || otherDict?.count == 0)
		XCTAssertNil(randomStringJSONFastTraversal.string)
		XCTAssertNil(randomStringJSONFastTraversal.int)
		XCTAssertNil(randomStringJSONFastTraversal.array)
		XCTAssertNil(randomStringJSONFastTraversal.bool)
		
		let randomStringFastTraversal: NSObject? = json["asdkjhafsd.asdjhlfasdf.kh.j.j.j.asdf"]
		XCTAssertNil(randomStringFastTraversal)
	}
	
	private func jsonMutability(json: Json) {
		
		let jsonCopy: Json = json.jsonCopy()
		let jsonCopy2: Json = json.copy() as! Json
		json.fullName.parent.fullName.someValue = 0.1
		
		XCTAssertEqual(
			json.fullName.parent.fullName.someValue.double,
			0.1
		)
		XCTAssertNotEqual(
			json.fullName.parent.fullName.someValue.double,
			jsonCopy.fullName.parent.fullName.someValue.double
		)
		XCTAssertNotEqual(
			json.fullName.parent.fullName.someValue.double,
			jsonCopy2.fullName.parent.fullName.someValue.double
		)
		
		//
		
		let anyValues: [Any] = ["cosa", 32.2, "something"]
		json.fullName.values = anyValues
		
		XCTAssertEqual(
			json.fullName.values.array?.compactMap { $0 as? AnyHashable },
			["cosa", 32.2, "something"]
		)
		XCTAssertNotEqual(
			json.fullName.values.array?.compactMap { $0 as? AnyHashable },
			["cosa", 32.21, "something"]
		)
		XCTAssertEqual(
			json.fullName.values.array?.compactMap { $0 as? AnyHashable },
			json.fullName.values.array(of: AnyHashable.self)
		)
		XCTAssertNotEqual(
			json.fullName.values.array?.compactMap { $0 as? AnyHashable },
			json.fullName.values.array(of: String.self)
		)
		
		json.fullName.parent = "pepe"
		jsonCopy.fullName.parent = (json.fullName.parent.string ?? "") + "_"
		
		XCTAssertEqual(
			json.fullName.parent.string,
			"pepe"
		)
		XCTAssertEqual(
			jsonCopy.fullName.parent.string,
			"pepe_"
		)
		
		jsonCopy2.fullName.parent = jsonCopy.fullName.parent.json
		XCTAssertEqual(
			jsonCopy2.fullName.parent.string,
			"pepe_"
		)
		
		json.fullName.somethingNew = "22"
		XCTAssertEqual(
			json.fullName.somethingNew.string,
			"22"
		)
		XCTAssertNotEqual(
			json.fullName.somethingNew.int,
			22
		)
		
		json.fullName.anotherJson = jsonCopy.json
		XCTAssertEqual(
			json.fullName.anotherJson.fullName.parent.string,
			"pepe_"
		)
	}
	
	static var allTests = [
		("testJSONString", testJSONString),
		("testJSONData", testJSONData),
	]
}
