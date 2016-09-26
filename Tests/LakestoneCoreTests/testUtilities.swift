//
//  testUtilities.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/22/16.
//
//

#if COOPER
	import remobjects.elements.eunit
#else
	import XCTest
	import Foundation
#endif


#if COOPER
	typealias AwaitToken = IAwaitToken
#else
	typealias AwaitToken = XCTestExpectation
	typealias Test = XCTestCase
#endif


#if !COOPER
	
class Assert {
		
	static func Fail(_ message: String? = nil){
		if let msg = message {
			XCTFail(msg)
		} else {
			XCTFail()
		}
	}
	
	static func AreEqual<T: Equatable>(_ lhs: T, _ rhs: T){
		XCTAssertEqual(lhs, rhs)
	}
	
	static func IsTrue(_ expression: Bool){
		XCTAssertTrue(expression)
	}
}
	
#endif

extension AwaitToken {
	
	static func with(description: String, for testCase: Test) -> AwaitToken {
		#if COOPER
			return TokenProvider.CreateAwaitToken()
		#else
			return testCase.expectation(description: description)
		#endif
	}
	
	func fulfillAfter(_ closure: () -> Void){
		#if COOPER
			self.Run { closure() }
		#else
			closure()
			self.fulfill()
		#endif
	}
	
	/// timeout is not yet supported for EUnit tests
	func waitFor(timeout: Double, for testCase: Test) {
		
		#if COOPER
		
			self.WaitFor()
		
		#else
		
			testCase.waitForExpectations(timeout: timeout, handler: nil)
			
		#endif
	}
}
