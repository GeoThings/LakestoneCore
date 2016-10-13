//
//  TestString.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/27/16.
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
	
	@testable import LakestoneCore
	
#endif

#if !COOPER
public class TestString: Test {
	
	public func testUpperLowerEmptiness(){
		
		let someRandomString = "raNdoM"
		Assert.AreEqual(someRandomString.uppercased(), "RANDOM")
		Assert.AreEqual(someRandomString.lowercased(), "random")
		Assert.IsFalse(someRandomString.isEmpty)
		Assert.IsTrue("".isEmpty)
		Assert.AreEqual(someRandomString.characterCount, 6)
	}
	
	public func testIndexing(){
		
		let someRandomString = "raNdoM"
		Assert.AreEqual(
			someRandomString.distance(from: someRandomString.startIndex, to: someRandomString.endIndex),
			someRandomString.characterCount
		)
		Assert.AreEqual(
			someRandomString.distance(from: someRandomString.startIndex, to: someRandomString.index(after: someRandomString.startIndex)),
			1
		)
		Assert.AreEqual(
			someRandomString.index(someRandomString.startIndex, offsetBy: 5),
			someRandomString.index(before: someRandomString.endIndex)
		)
		Assert.AreEqual(someRandomString[someRandomString.index(before: someRandomString.endIndex)], "M")
		Assert.IsNil(someRandomString.index(someRandomString.startIndex, offsetBy: 6, limitedBy: someRandomString.index(before: someRandomString.endIndex)))
		Assert.IsNil(someRandomString.index(someRandomString.endIndex, offsetBy: -2, limitedBy: someRandomString.index(before: someRandomString.endIndex)))
		Assert.IsNotNil(someRandomString.index(someRandomString.index(after: someRandomString.startIndex), offsetBy: 5, limitedBy: someRandomString.startIndex))
		Assert.IsNotNil(someRandomString.index(someRandomString.index(before: someRandomString.endIndex), offsetBy: -2, limitedBy: someRandomString.endIndex))
	}
	
	public func testOperations(){
		
		let someRandomString = "raNdoM"
		Assert.AreEqual(someRandomString.appending("º"), "raNdoMº")
		Assert.AreEqual(someRandomString.appending(Character("º")), "raNdoMº")
		
		let range = someRandomString.startIndex ..< someRandomString.index(before: someRandomString.endIndex)
		let closedRange = someRandomString.startIndex ... someRandomString.index(before: someRandomString.endIndex)
		
		
		Assert.AreEqual(someRandomString.replacingSubrange(range, with: "º"), "ºM")
		Assert.AreEqual(someRandomString.replacingSubrange(closedRange, with: "º"), "º")
		Assert.AreEqual(someRandomString.inserting(Character("º"), at: someRandomString.index(someRandomString.startIndex, offsetBy: 3)), "raNºdoM")
		Assert.AreEqual(someRandomString.removing(at: someRandomString.index(before: someRandomString.endIndex)), "raNdo")
		Assert.AreEqual(someRandomString.removingSubrange(range), "M")
		Assert.AreEqual(someRandomString.removingSubrange(closedRange), "")
		Assert.AreEqual(someRandomString.removingAll(), "")
		
		Assert.AreEqual(someRandomString.replacingCharacters(in: range, with: "º"), "ºM")
		Assert.AreEqual(someRandomString.replacingOccurrences(of: "Ndo", with: "º"), "raºM")
		Assert.AreEqual(someRandomString.substring(from: someRandomString.index(someRandomString.startIndex, offsetBy: 2)), "NdoM")
		Assert.AreEqual(someRandomString.substring(to: someRandomString.index(someRandomString.endIndex, offsetBy: -2)), "raNd")
		
		let centerRange = someRandomString.index(someRandomString.startIndex, offsetBy: 2) ..< someRandomString.index(someRandomString.endIndex, offsetBy: -2)
		Assert.AreEqual(someRandomString.substring(with: centerRange), "Nd")
		Assert.AreEqual((someRandomString.range(of: "Nd") ?? range), centerRange)
		
		let expectedComponents = ["", "path", "to", "something", "interesting.json", ""]
		let components = "/path/to/something/interesting.json/".components(separatedBy: "/")
		Assert.AreEqual(components, expectedComponents)
		
		let pathWithDotsInName = "/some/path/file.with.dots.test"
		#if COOPER
			let extensionSeperatorRangeº = pathWithDotsInName.range(of: ".", searchBackwards: true)
		#else
			let extensionSeperatorRangeº = pathWithDotsInName.range(of: ".", options: .backwards)
		#endif
		
		guard let extensionSeperatorRange = extensionSeperatorRangeº else {
			Assert.Fail("\(pathWithDotsInName) doesn't contain '.'")
			return
		}
		
		Assert.AreEqual(pathWithDotsInName.substring(from: pathWithDotsInName.index(after: extensionSeperatorRange.lowerBound)), "test")
		
		
		Assert.AreEqual(String.derived(from: 25), "25")
		Assert.AreEqual(String.derived(from: "someString"), "someString")
		Assert.AreEqual(String.derived(from: 25.0), "25.0")
	}
	
	public func testNumericConversions(){
		
		Assert.IsTrue("3219123080918".isNumeric)
		Assert.IsFalse("-3219123080918".isNumeric)
		Assert.IsFalse("12122211221.".isNumeric)
		Assert.IsFalse("".isNumeric)
		Assert.IsFalse("322222d000".isNumeric)
		Assert.IsTrue("-3219123080918".representsLongDecimal)
		Assert.IsFalse("3219123080918".representsDecimal)
		Assert.IsFalse("32232323 ".representsDecimal)
		Assert.IsFalse("32323223.0".representsDecimal)
		
		Assert.IsTrue("0".representsBool)
		Assert.IsTrue("true".representsBool)
		Assert.IsTrue("TrUe".representsBool)
		Assert.IsFalse("2".representsBool)
		
		Assert.IsTrue("-12213".representsFloat)
		Assert.IsTrue("323532.0".representsFloat)
		Assert.IsTrue("12213".representsDouble)
		Assert.IsTrue("-323532.0".representsDouble)
		Assert.IsFalse("322323.0.".representsFloat)
		Assert.IsFalse("322323.0.".representsDouble)
		Assert.IsFalse("322323.0 ".representsFloat)
		Assert.IsFalse("322323.0 ".representsDouble)
		Assert.IsFalse("322323.0\n".representsFloat)
		Assert.IsFalse("322323.0\n".representsDouble)
		Assert.IsFalse(" 322323.0".representsFloat)
		Assert.IsFalse(" 322323.0".representsDouble)
		Assert.IsFalse("\n322323.0".representsFloat)
		Assert.IsFalse("\n322323.0".representsDouble)
		Assert.IsFalse("\t322323.0".representsFloat)
		Assert.IsFalse("\t322323.0".representsDouble)
		
		
		Assert.IsNotNil("1121212".decimalRepresentation)
		Assert.IsNil("111112 ".decimalRepresentation)
		Assert.IsNotNil("-11212121121212".longDecimalRepresentation)
		Assert.IsNil("11212121121212 ".longDecimalRepresentation)
		Assert.IsNotNil("121212.12121212".floatRepresentation)
		Assert.IsNotNil("-121212.12121212".doubleRepresentation)
		Assert.IsNil(" 121212.12121212".floatRepresentation)
		Assert.IsNil(" 121212.12121212".doubleRepresentation)
		
		Assert.IsNotNil("tRue".boolRepresentation)
		Assert.IsNotNil("FaLsE".boolRepresentation)
		Assert.IsNotNil("1".boolRepresentation)
		Assert.IsNotNil("0".boolRepresentation)
		Assert.IsNil("".boolRepresentation)
		Assert.IsNil(" true".boolRepresentation)
	}
}
#endif

#if !COOPER
extension TestString {
	static var allTests : [(String, (TestString) -> () throws -> Void)] {
		return [
			("testUpperLowerEmptiness", testUpperLowerEmptiness),
			("testIndexing", testIndexing),
			("testOperations", testOperations),
			("testNumericConversions", testNumericConversions)
		]
	}
}
#endif
