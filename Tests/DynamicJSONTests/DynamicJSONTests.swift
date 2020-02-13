import XCTest
@testable import DynamicJSON

final class DynamicJSONTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DynamicJSON().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
