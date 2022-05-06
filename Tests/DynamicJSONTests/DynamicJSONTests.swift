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
	
	func testNull() {
		XCTAssertTrue(Json.null.isJsonEmpty)
		XCTAssertTrue(Json(dictionary: [:]).isJsonEmpty)
		XCTAssertTrue(Json(rawJsonString: "{}").isJsonEmpty)
		XCTAssertTrue(Json(rawJsonString: "").isJsonEmpty)
	}
	
	func testSpecialNames() {
		let specialJson = """
		{
			"string": {
				"number": 25,
				"int": "something",
				"dictionary": [1.2, 5.3, 78323.23],
				"what are you doing?!": {
					"name": "Daniel"
				}
			},
			"int": 22
		}
		"""
		let json = Json(rawJsonString: specialJson)
		XCTAssertEqual(
			json[\.string].number.int,
			25
		)
		XCTAssertEqual(
			json["string.int"].string,
			"something"
		)
		XCTAssertEqual(
			json["int"].int,
			22
		)
		XCTAssertEqual(
			json["sadjfaj.f.f.f.d.d.f.fskdhfasd"].int,
			nil
		)
		XCTAssertEqual(
			json["^%&$%^#^.."].int,
			nil
		)
		XCTAssertEqual(
			json[""].int,
			nil
		)
		XCTAssertEqual(
			json["......"].int,
			nil
		)
		XCTAssertEqual(
			json[\.asdfasd.asdf.fd.fdf.dfd].int,
			nil
		)
		XCTAssertEqual(
			json["string.what are you doing?!.name"].string,
			"Daniel"
		)
		XCTAssertEqual(
			json["string.dictionary"].array(of: Double.self),
			[1.2, 5.3, 78323.23]
		)
	}
	
	func testJSONString() {
		let json = Json(rawJsonString: jsonString1)
		jsonValueTypeChecks(json)
		
		var json1 = Json(rawJsonString: jsonString1)
		jsonMutability(json: &json1)
	}
	
	func testJSONData() {
		let json = Json(data: Data(jsonString1.utf8))
		jsonValueTypeChecks(json)
		
		var json1 = Json(data: Data(jsonString1.utf8))
		jsonMutability(json: &json1)
	}
	
	func testJSONObject() {
		let json = Json(dictionary: [
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
		
		var json1 = Json(dictionary: [
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
		jsonMutability(json: &json1)
	}
	
	static var allTests = [
		("testJSONString", testJSONString),
		("testJSONData", testJSONData),
	]
	
	// private
	
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
		
		let someValueFastTraversal: Double? = json["fullName.parent.fullName.someValue"].double
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
		
		let randomStringFastTraversal = json["asdkjhafsd.asdjhlfasdf.kh.j.j.j.asdf"]
		XCTAssertTrue(randomStringFastTraversal.isJsonEmpty)
		
		var myJson = Json(dictionary: ["something": ["age": 25]])
		myJson.something.name = "Daniel"
		XCTAssertEqual(
			myJson[\.something.age].int,
			25
		)
		XCTAssertEqual(
			myJson[\.something.name].string,
			"Daniel"
		)
		let name1: String? = myJson["something.name"].string
		XCTAssertEqual(
			myJson[\.something.name].string,
			name1
		)
	}
	
	private func jsonMutability(json: inout Json) {
		
		var jsonCopy: Json = json
		var jsonCopy2: Json = json
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
			json.fullName.values.array(of: String.self) as [AnyHashable]?
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
}
