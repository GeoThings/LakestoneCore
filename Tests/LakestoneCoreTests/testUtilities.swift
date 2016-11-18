//
//  testUtilities.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/22/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//
// --------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#if COOPER
	import remobjects.elements.eunit
	import lakestonecore.android
#else
	import XCTest
	import Foundation
	import LakestoneCore
	import PerfectThread
#endif


#if COOPER
	typealias AwaitToken = IAwaitToken
#else
	typealias AwaitToken = XCTestExpectation
	public typealias Test = XCTestCase
#endif


#if !COOPER
	
public class Assert {
		
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
	
	static func AreNotEqual<T: Equatable>(_ lhs: T, _ rhs: T){
		XCTAssertNotEqual(lhs, rhs)
	}
	
	static func AreNotEqual<T: Equatable>(_ lhs: [T], _ rhs: [T]){
		
		if lhs.count != rhs.count {
			return
		}
		
		for (index, element) in lhs.enumerated() {
			Assert.AreNotEqual(element, rhs[index])
		}
	}
	
	static func AreEqual<T: Equatable>(_ lhs: [T], _ rhs: [T]){
		
		if lhs.count != rhs.count {
			Assert.Fail("Sequences differ in length")
			return
		}
		
		for (index, element) in lhs.enumerated() {
			Assert.AreEqual(element, rhs[index])
		}
	}
	
	static func IsTrue(_ expression: Bool){
		XCTAssertTrue(expression)
	}
	
	static func IsFalse(_ expression: Bool){
		XCTAssertFalse(expression)
	}
	
	static func IsNil(_ expression: Any?){
		XCTAssertNil(expression)
	}
	
	static func IsNotNil(_ expression: Any?){
		XCTAssertNotNil(expression)
	}
}
	
#endif

extension AwaitToken {
	
	static func perform(for test: Test, withTimeout timeout: Double, asynchClosure: @escaping (AwaitToken) -> Void){
		
		let awaitToken = AwaitToken.with(description: "Asynchronous await token", for: test)
        asynchClosure(awaitToken)
        awaitToken.waitFor(timeout: timeout, for: test)
	}
	
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
