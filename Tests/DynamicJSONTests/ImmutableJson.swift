//
//  ImmutableJson.swift
//  
//
//  Created by Daniel Illescas Romero on 6/5/22.
//

import XCTest
@testable import DynamicJSON

final class ImmutableJsonTests: XCTestCase {
	
	static var allTests = [
		("testJsonInit", testJsonInit),
		("testDictionaryInit", testDictionaryInit),
		("testArrayInit", testArrayInit),
	]
	
	func testJsonInit() throws {
		let json: ImmutableJson = """
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
"""
		let nameJsonValue = json.name.getValue()
		if case .string(let nameString) = nameJsonValue.value {
			XCTAssertEqual(nameString, "Daniel")
		}
		XCTAssertEqual(json.name.getString(), "Daniel")
		XCTAssertTrue(json.name == "Daniel")
		
		XCTAssertTrue(json.age == 25)
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
		let json: ImmutableJson = [
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
		let json: ImmutableJson = [
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
		
//		XCTAssertFalse(json[0] == json[1])
//		XCTAssertTrue(json[1] == json[2])
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
}
