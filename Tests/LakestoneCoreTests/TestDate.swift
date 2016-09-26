//
//  TestDate.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/26/16.
//
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
        
        let sept2016Epoch:Int64 = 1472688000
        #if COOPER
            let timeInterval = Double(sept2016Epoch * 1000)
        #else
            let timeInterval = Double(sept2016Epoch)
        #endif
        
        let testDate = Date(timeIntervalSince1970: timeInterval)
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
        guard let backConvertedString = Date.from(xsdGMTDateTimeString: dateString)?.xsdGMTDateTimeString else {
            Assert.Fail("Cannot derive a date from string, format invalid")
            return
        }
        
        Assert.AreEqual(backConvertedString, dateString)
    }
}
