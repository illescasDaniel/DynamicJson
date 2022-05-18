//
//  JsonValue.swift
//  
//
//  Created by Daniel Illescas Romero on 6/5/22.
//

import XCTest
@testable import DynamicJSON

final class JSONValueTests: XCTestCase {
	
	static var allTests = [
		("testValues", testValues),
		("testMultipleValues", testMultipleValues)
	]
	
	func testValues() throws {
		let jsonValue1: JsonValue = 1
		XCTAssertEqual(jsonValue1.integer, 1 as Int)
		
		let jsonValue2: JsonValue = 1.5
		XCTAssertEqual(jsonValue2.double, 1.5 as Double)
		
		let jsonValue3: JsonValue = "hi"
		XCTAssertEqual(jsonValue3.string, "hi" as String)
		
		let jsonValue4: JsonValue = false
		XCTAssertEqual(jsonValue4.boolean, false as Bool)
		
		let jsonValue5: JsonValue = nil
		XCTAssertTrue(jsonValue5.isNull)
		
		let jsonValue6: JsonValue = [1,2,3]
		XCTAssertEqual(jsonValue6.anyArray as? [Int], [1,2,3] as [Int])
		
		let jsonValue7: JsonValue = [1.5, 2.6, 3.3]
		XCTAssertEqual(jsonValue7.anyArray as? [Double], [1.5, 2.6, 3.3] as [Double])
		
		let jsonValue8: JsonValue = ["aaa", "bb"]
		XCTAssertEqual(jsonValue8.anyArray as? [String], ["aaa", "bb"] as [String])
		
		let jsonValue9: JsonValue = ["aaa", 1.5, 6]
		let jsonValue9Array = try XCTUnwrap(jsonValue9.value.array)
		XCTAssertEqual(jsonValue9Array[0].string, "aaa" as String)
		XCTAssertEqual(jsonValue9Array[1].double, 1.5 as Double)
		XCTAssertEqual(jsonValue9Array[2].integer, 6 as Int)
		
		let jsonValue10: JsonValue = [1,2,3]
		XCTAssertEqual(jsonValue10.value.arrayValue(), [1,2,3] as [Int])
		
		let jsonValue11: JsonValue = [1,2,nil]
		XCTAssertEqual(jsonValue11.value.arrayValue(), [1,2,nil] as [Int?])
		
		let jsonValue12: JsonValue = [1,2,nil]
		XCTAssertEqual(jsonValue12.value.compactArrayValue(), [1,2] as [Int])
	}
	
	func testMultipleValues() {
		let values: [JsonValue] = [1, 3, 1.4, [1, 4.5, "aa"], nil, nil, ["key": 1]]
		XCTAssertEqual(values[0].integer, 1 as Int)
		XCTAssertEqual(values[1].integer, 3 as Int)
		XCTAssertEqual(values[2].double, 1.4 as Double)
		XCTAssertEqual(((values[3].array)?[0].integer), 1 as Int)
		XCTAssertEqual(((values[3].array)?[1].double), 4.5 as Double)
		XCTAssertEqual(((values[3].array)?[2].string), "aa" as String)
		XCTAssertTrue(values[4].isNull)
		XCTAssertTrue(values[5].isNull)
		XCTAssertEqual((values[6].dictionary)?["key"]?.integer, 1 as Int )
	}
}
