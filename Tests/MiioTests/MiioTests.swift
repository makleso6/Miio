import XCTest
@testable import Miio

final class MiioTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let value = 0xff
        print(value)
        print(0xff)
        let expectation = XCTestExpectation(description: "handshake")

        do {
            let service = try UDPNetworkService()
            service.handshake({
                print("handshaked")
                expectation.fulfill()
            })
        } catch {
            print(error)
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
