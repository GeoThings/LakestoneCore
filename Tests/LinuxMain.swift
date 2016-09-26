import XCTest
@testable import LakestoneCoreTests

XCTMain([
    testCase(TestHTTP.allTests),
    testCase(TestData.allTests)
])
