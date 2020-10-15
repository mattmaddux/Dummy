import XCTest
@testable import Dummy

final class DummyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Dummy().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
