import XCTest
@testable import CompositionalList

final class CompositionalListTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CompositionalList().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
