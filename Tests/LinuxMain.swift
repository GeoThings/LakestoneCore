import XCTest
@testable import LakestoneCoreTests

XCTMain([
    testCase(TestHTTP.allTests),
    testCase(TestData.allTests),
    testCase(TestString.allTests),
    testCase(TestDate.allTests),
    testCase(TestUUID.allTests),
    testCase(TestURL.allTests),
    testCase(TestFile.allTests),
    testCase(TestDirectory.allTests),
    testCase(TestJSONSerialization.allTests),
    testCase(TestCustomSerialization.allTests),
    testCase(TestPersistentPropertyList.allTests)
])
