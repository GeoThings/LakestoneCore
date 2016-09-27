//
//  TestDate.swift
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

class TestDate: Test {
	
	public func testDateInstantiation(){
		
		let sept2016Epoch:Double = 1472688000.0
		
		let testDate = Date(timeIntervalSince1970: sept2016Epoch)
		guard let comparisonDate = Date.from(year: 2016, month: 9, day: 1) else {
			Assert.Fail("Cannot create date with given calendar components")
			return
		}
		
		let currentTimezoneOffset = comparisonDate.currentTimezoneOffsetFromGMT
		let comparisonDateUTC = comparisonDate.addingTimeInterval(currentTimezoneOffset)
		
		Assert.IsTrue(testDate == comparisonDateUTC)
		
		guard let comparisonDate2UTC = Date.from(xsdGMTDateTimeString: "2016-09-01T00:00:00Z") else {
			Assert.Fail("Cannot derive a date from string, format invalid")
			return
		}
		
		Assert.IsTrue(testDate == comparisonDate2UTC)
	}
	
	public func testDateConversion(){
		
		let dateString = "2016-09-01T00:00:00Z"
		guard let parsedDate = Date.from(xsdGMTDateTimeString: dateString) else {
			Assert.Fail("Cannot derive a date from string, format invalid")
			return
		}
		
		let convertedBackDateString = parsedDate.xsdGMTDateTimeString
		
		Assert.AreEqual(convertedBackDateString, dateString)
	}
}

#if !COOPER
extension TestDate {
    static var allTests : [(String, (TestDate) -> () throws -> Void)] {
        return [
            ("testDateConversion", testDateConversion),
            ("testDateInstantiation", testDateInstantiation)
        ]
    }
}
#endif

