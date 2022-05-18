//
//  File.swift
//  
//
//  Created by Daniel Illescas Romero on 18/5/22.
//

import XCTest
@testable import DynamicJSON

final class MutableJsonTests: XCTestCase {
	
	static var allTests = [
		("testJsonInit", testJsonInit),
		("testDictionaryInit", testDictionaryInit),
		("testArrayInit", testArrayInit),
		("testMutability", testMutability)
	]
	
	func testJsonInit() throws {
		let json = MutableJson(rawJsonString: """
{
	"name": "Daniel",
	"age": 25,
	"parents": [
		{
			"name": "Mom",
			"age": 50
		},
		{
			"name": "Dad",
			"age": 50
		}
	]
}
""")
		let nameJsonValue = json.name.getValue()
		if case .string(let nameString) = nameJsonValue.value {
			XCTAssertEqual(nameString, "Daniel")
		}
		XCTAssertEqual(json.name.getString(), "Daniel")
		XCTAssertTrue(json.name == "Daniel")
		
		XCTAssertTrue(json.age == 25)
		XCTAssertTrue(json.age == json.age)
		XCTAssertTrue(json.parents[0]["age"] >= json.age)
		XCTAssertTrue(json.parents[0]["age"] >= 40)
		
		XCTAssertTrue(
			json.parents.getArray()?[0] ==
			[
				"name": "Mom",
				"age": 50
			]
		)
		XCTAssertTrue(
			json.parents[0] ==
			[
				"name": "Mom",
				"age": 50
			]
		)
	}
	
	func testDictionaryInit() throws {
		let json: MutableJson = [
			"name": "Daniel",
			"age": 25,
			"parents": [
				[
					"name": "Mom",
					"age": 50
				],
				[
					"name": "Dad",
					"age": 60
				]
			],
			"something": nil,
			"isSomething": true
		]
		
		XCTAssertTrue(json.something == nil)
		XCTAssertTrue(json.getDictionary()?["something"] == JsonValue(.null))
		XCTAssertTrue(json.getNSDictionary()?["something"] as! NSObject == NSNull())
		XCTAssertTrue(json.isSomething == true)

		XCTAssertTrue(json.name == "Daniel")
		XCTAssertTrue(json.age == 25)
		XCTAssertTrue(json.parents == [
			[
				"name": "Mom",
				"age": 50
			],
			[
				"name": "Dad",
				"age": 60
			]
		])
		XCTAssertTrue(json.parents[0] == [
			"name": "Mom",
			"age": 50
		])
		XCTAssertTrue(json.parents[1] == [
			"name": "Dad",
			"age": 60
		])
		
		XCTAssertNotNil(json.encoded())
		XCTAssertNotNil(json.jsonString())
	}
	
	func testArrayInit() throws {
		let json: MutableJson = [
			[
				"name": "Mom",
				"age": 50
			],
			[
				"name": "Dad",
				"age": 60
			],
			[
				"name": "Dad",
				"age": 60
			]
		]
		
		XCTAssertTrue(json[0].name == "Mom")
		XCTAssertTrue(json[1].age == 60)

		XCTAssertTrue(json[0] == [
			"name": "Mom",
			"age": 50
		])
		XCTAssertTrue(json[1] == [
			"name": "Dad",
			"age": 60
		])
		
		XCTAssertFalse(json[0] == json[1])
		XCTAssertTrue(json[1] == json[2])
		XCTAssertTrue(json == [
			[
				"name": "Mom",
				"age": 50
			],
			[
				"name": "Dad",
				"age": 60
			],
			[
				"name": "Dad",
				"age": 60
			]
		])
		
		XCTAssertTrue(json[1].age >= 50)
		XCTAssertTrue(json[1].age < 100)
	}
	
	func testMutability() {
//		var json = MutableJson(array: [1,2,3,4])
//		json[0] = 5
//		XCTAssertTrue(json[0] == 5)
//		XCTAssertEqual(json[0].getInteger(), 5)
//		
//		json[10] = 9
//		XCTAssertFalse(json[10] == 9)
//		
		var json2 = MutableJson(dictionary: [
			"name": "Daniel",
			"age": 25,
			"other": [
				"aaa": 90.34
			]
		])
		json2.age = ["birthdate": 131212122, "currentAge": 25]
		XCTAssertTrue(json2["age.birthdate"] == 131212122)
		XCTAssertTrue(json2["age.currentAge"] == 25)
	}
}
