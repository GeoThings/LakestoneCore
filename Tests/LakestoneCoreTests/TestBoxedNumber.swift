//
//  TestBoxedNumber.swift
//  LakestoneCore
//
//  Created by Volodymyr Andriychenko on 10/17/16.
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

public class TestStruct<T: Comparable> {
    
    public var a: T
    public var b: T
    
    public init(a: T, b: T){
        self.a = a
        self.b = b
    }
}

public class TestBoxedNumber: Test {
    
    public func testNumber() {
        
        var testInt: TestStruct<IntProxy>
        var testDouble: TestStruct<DoubleProxy>
        
        let newInt = IntProxy(4)
        let newDouble = DoubleProxy(3.5)

        testInt = TestStruct(a: IntProxy(3), b: IntProxy(5))
        testDouble = TestStruct(a: DoubleProxy(3.5), b: DoubleProxy(4.5))
        
        Assert.IsTrue(newInt > testInt.a)
        Assert.IsTrue(newInt <= testInt.b)
        
        testInt = TestStruct (a: newInt, b: newInt)
        Assert.IsTrue(testInt.b == testInt.a)
        
        Assert.AreEqual(newDouble, testDouble.a)
        Assert.IsTrue(newDouble >= testDouble.a)
        Assert.IsTrue(newDouble < testDouble.b)
    
    }
}

#if !COOPER
    extension TestBoxedNumber {
        static var allTests : [(String, (TestBoxedNumber) -> () throws -> Void)] {
            return [
                ("testNumber", testNumber)
            ]
        }
    }
#endif
