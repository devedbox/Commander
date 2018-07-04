import XCTest
@testable import Commander

final class CommanderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Commander().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
