//
//  MyJson.swift
//  
//
//  Created by Daniel Illescas Romero on 6/5/22.
//

import XCTest
@testable import DynamicJSON

final class MyJsonTests: XCTestCase {
	
	static var allTests = [
		("testJsonInit", testJsonInit),
		("testDictionaryInit", testDictionaryInit),
		("testArrayInit", testArrayInit),
	]
	
	func testJsonInit() throws {
		let json = MyJson(rawJsonString: """
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
			"age": 50.00001,
		}
	],
	"something": {
		"someKey": "someValue",
		"otherKey": {
			"otherOtherKey": "otherValue"
		}
 	}
}
""")
		let nameJsonValue = json.name.getValue()
		if case .string(let nameString) = nameJsonValue {
			XCTAssertEqual(nameString, "Daniel")
		}
		XCTAssertEqual(json.name.getString(), "Daniel")
		XCTAssertTrue(json.name ~= "Daniel")
		XCTAssertTrue(json["."] ~= nil)
		XCTAssertTrue(json[""] ~= nil)
		XCTAssertTrue(json[keyPath: "something.someKey"] ~= "someValue")
		XCTAssertTrue(json[keyPath: "something.otherKey"] ~= ["otherOtherKey": "otherValue"])
		XCTAssertTrue(json[keyPath: "something.otherKey.otherOtherKey"] ~= "otherValue")
		XCTAssertTrue(json.parents[1].age ~= 50)

		XCTAssertTrue(json.age ~= 25)
		XCTAssertTrue(json.age == json.age)

		XCTAssertTrue(
			json.parents.getArray()?[0] ==
			[
				"name": "Mom",
				"age": 50
			]
		)
		XCTAssertTrue(
			json.parents[0] ~=
			[
				"name": "Mom",
				"age": 50
			]
		)
	}
	
	func testDictionaryInit() throws {
		let json = MyJson(json: [
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
		])
		
		XCTAssertTrue(json.something ~= nil)
		XCTAssertTrue(json.getDictionary()?["something"] ~= .null)
		XCTAssertTrue(json.getNSDictionaryWithNull()?["something"] as! NSObject == NSNull())
		XCTAssertTrue(json.isSomething ~= true)

		XCTAssertTrue(json.name ~= "Daniel")
		XCTAssertTrue(json.age ~= 25)
		XCTAssertTrue(json.parents ~= [
			[
				"name": "Mom",
				"age": 50
			],
			[
				"name": "Dad",
				"age": 60
			]
		])
		XCTAssertTrue(json.parents[0] ~= [
			"name": "Mom",
			"age": 50
		])
		XCTAssertTrue(json.parents[1] ~= [
			"name": "Dad",
			"age": 60
		])
		
		XCTAssertNotNil(json.encoded())
		XCTAssertNotNil(json.jsonString())
	}
	
	func testArrayInit() throws {
		let json = MyJson(json: [
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
		
		XCTAssertTrue(json[0].name ~= "Mom")
		XCTAssertTrue(json[1].age ~= 60)

		XCTAssertTrue(json[0] ~= [
			"name": "Mom",
			"age": 50
		])
		XCTAssertTrue(json[1] ~= [
			"name": "Dad",
			"age": 60
		])
		
		XCTAssertFalse(json[0] == json[1])
		XCTAssertTrue(json[1] == json[2])
		XCTAssertTrue(json ~= [
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
		
		XCTAssertTrue((json[1].age.getInteger() ?? 0) >= 50)
		XCTAssertTrue((json[1].age.getInteger() ?? 0) < 100)
	}
}