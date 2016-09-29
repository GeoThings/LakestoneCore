//
//  TestData.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/26/16.
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
	
#else
	
	import XCTest
	import Foundation
	
	#if os(iOS) || os(watchOS) || os(tvOS)
		@testable import LakestoneCoreIOS
	#else
		@testable import LakestoneCore
	#endif
	
#endif

class TestData: Test {
	
	public func testNumericConversion(){
		
		let testNumber: Int64 = 534098634643643
		
		let littleEndianData = Data.with(long: testNumber, usingLittleEndianEncoding: true)
		let bigEndianData = Data.with(long: testNumber, usingLittleEndianEncoding: false)
		
		guard let targetLENumber = littleEndianData.longRepresentation(withLittleEndianByteOrder: true),
			  let targetBENumber = bigEndianData.longRepresentation(withLittleEndianByteOrder: false)
		else {
			Assert.Fail("Data cannot be represented in long decimal")
			return
		}
		
		let testNumberBytesBE = [Int8]([0x00, 0x01, 0xE5, 0xC2, 0x87, 0x64, 0x98, 0xBB].map {
			Int8(bitPattern: $0)
		})
		
		Assert.AreEqual(littleEndianData.bytes, testNumberBytesBE.reversed())
		Assert.AreEqual(bigEndianData.bytes, testNumberBytesBE)
		
		Assert.AreEqual(targetLENumber, testNumber)
		Assert.AreEqual(targetBENumber, testNumber)   
	}
	
	public func testUTF8StringWrapping(){
		
		let testString = "ºººUTF-8 TestStringººº"
		let testData = Data.with(utf8EncodedString: testString)
		guard let targetString = testData?.utf8EncodedStringRepresentation else {
			Assert.Fail("Data cannot be represented as utf8-encoded string")
			return
		}
		
		Assert.AreEqual(testString, targetString)
	}
	
}

#if !COOPER
extension TestData {
	static var allTests : [(String, (TestData) -> () throws -> Void)] {
		return [
			("testNumericConversion", testNumericConversion),
			("testUTF8StringWrapping", testUTF8StringWrapping)
		]
	}
}
#endif
