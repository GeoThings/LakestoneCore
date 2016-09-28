import XCTest
@testable import LakestoneCoreTests

XCTMain([
    testCase(TestHTTP.allTests),
    testCase(TestData.allTests),
    testCase(TestString.allTests),
    testCase(TestDate.allTests),
    testCase(TestUUID.allTests),
    testCase(TestURL.allTests)
])
