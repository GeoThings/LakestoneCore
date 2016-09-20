import XCTest
@testable import LakestoneCore

class LakestoneCoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testSynchronousHTTPRequest() {
        
        guard let rasterStyleURL = URL(string: "http://52.76.15.94/raster-digitalglobe.json") else {
            XCTFail()
            return
        }
        
        let request = HTTP.Request(url: rasterStyleURL)
        guard let response = try? request.performSync() else {
            XCTFail()
            return
        }
        
        guard let data = response.dataº,
              let dataString = String(data: data, encoding: String.Encoding.utf8)
        else {
            XCTFail()
            return
        }
        
        print(dataString)
    }

}

extension LakestoneCoreTests {
    static var allTests : [(String, (LakestoneCoreTests) -> () throws -> Void)] {
        return [
            ("testSynchronousHTTPRequest", testSynchronousHTTPRequest)
        ]
    }
}
