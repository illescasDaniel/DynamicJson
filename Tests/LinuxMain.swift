import XCTest

import DynamicJSONTests

var tests = [XCTestCaseEntry]()
tests += DynamicJSONTests.allTests()
tests += JSONValueTests.allTests()
XCTMain(tests)
