//
//  TestCustomSerialization.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 10/3/16.
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

public class InternalSomething: CustomSerializable {
	var argument1 = String()
	var argument2 = false
	var argument3 = Double()
	
	required public init(){}
	
	required public init(variableMap: [String : Any]) throws {
		self.argument1 = variableMap["argument1"] as! String
		self.argument2 = variableMap["argument2"] as! Bool
		self.argument3 = variableMap["argument3"] as! Double
	}
	
	public static var ignoredVariableNames: Set<String> {
		return Set<String>()
	}
	
	public static var allowedTypeDifferentVariableNames: Set<String> {
		return Set<String>()
	}
	
	public var manuallySerializedValues: [String : Any] {
		return [String: Any]()
	}
	
}

public class TestSomething: CustomSerializable {
	
	var testString: String? = String()
	var testInt = Int()
	var testDouble = Double()
	var testDate = Date()
	var testSomething = InternalSomething()
	var testArray = [Int]()
	var testSomethingArray = [InternalSomething]()
	
	var ignoredString = "ignored sample"
	
	required public init(){}
	
	required public init(variableMap: [String : Any]) throws {
		self.testString = variableMap["testString"] as? String
		self.testInt = variableMap["testInt"] as! Int
		self.testDouble = variableMap["testDouble"] as! Double
		self.testSomething = variableMap["testSomething"] as! InternalSomething
		self.testArray = variableMap["testArray"] as! [Int]
		self.testSomethingArray = variableMap["testSomethingArray"] as! [InternalSomething]
		self.testDate = Date.with(xsdGMTDateTimeString: (variableMap["testDate"] as! String))!
	}
	
	public static var ignoredVariableNames: Set<String> {
		return Set<String>(["ignoredString"])
	}
	
	public static var allowedTypeDifferentVariableNames: Set<String> {
		return Set<String>(["testDate"])
	}
	
	// Method 2: Provide your own serialization
	// These values will be presented in a resulting serialized dictionary
	// No type check or additional processing will be done for these values
	public var manuallySerializedValues: [String : Any] {
		return ["testDate": self.testDate.xsdGMTDateTimeString]
	}
}

/*

// Method 1: Conform to SerializableTypeRepresentable,
// which will allow CustomSerialization serialize object to it by itself
extension Date: SerializableTypeRepresentable {
	public var serializableRepresentation: Any {
		return self.xsdGMTDateTimeString
	}
}
 
*/


public class TestCustomSerialization: Test {
	
	
	public func testCustomSerialization(){
		
		do {
			
			// Silver recognizes Int as java.lang.Long,
			// 26 constant by itself will interpretet as 32bit java.lang.Integer
			let customDict: [String: Any] =
				["testString": "someString",
					"testInt": Int(26),
				 "testDouble": 26.0,
				  "testArray": [Int]([26, 12, 42, 53, 12]),
				  "testDate": "2016-09-01T00:00:00Z",
			  "testSomething": ["argument1": "someString",
								"argument2": false,
								"argument3": 26.0],
			  "testSomethingArray": [["argument1": "someString",
									  "argument2": false,
									  "argument3": 12.0],
									 ["argument1": "someOtherString",
									  "argument2": true,
									  "argument3": 26.0],
									 ["argument1": "oneMoreString",
									  "argument2": false,
									  "argument3": 14.0]],
			  "someOtherVariable": Int(12)
				
				 ]
			
			let dictAfter = try CustomSerialization.applyCustomSerialization(ofCustomTypes: [TestSomething.self, InternalSomething.self], to: customDict)
			Assert.IsTrue(dictAfter is TestSomething)
			guard let testSomething = dictAfter as? TestSomething else {
				Assert.Fail("The serialization didn't yield expected type")
				return
			}
			
			Assert.AreEqual(testSomething.testSomethingArray.first?.argument3 ?? 0, 12.0)
			Assert.AreEqual(testSomething.testSomethingArray.last?.argument3 ?? 0, 14.0)
			Assert.AreEqual(testSomething.testDouble, 26.0)
			Assert.AreEqual(testSomething.testString ?? "", "someString")
			Assert.AreEqual(testSomething.testInt, 26)
			Assert.AreEqual(testSomething.testArray.first ?? 0, 26)
			Assert.AreEqual(testSomething.testArray.last ?? 0, 12)
 
			Assert.AreEqual(testSomething.testDate, Date(timeIntervalSince1970: 1472688000.0))
			
			do {
				let serializedDict = try CustomSerialization.dictionary(from: testSomething)
				Assert.AreEqual(serializedDict["testString"] as? String ?? "", "someString")
				Assert.AreEqual(serializedDict["testInt"] as? Int ?? 0, 26)
				Assert.AreEqual(serializedDict["testDouble"] as? Double ?? 0.0, 26.0)
				Assert.AreEqual(serializedDict["testDate"] as? String ?? "", "2016-09-01T00:00:00Z")
				
				try JSONSerialization.data(withJSONObject: serializedDict)
				
                let serializedArray = try CustomSerialization.array(from: testSomething.testSomethingArray)
                Assert.AreEqual(serializedArray.first?["argument1"] as? String ?? "", "someString")
                Assert.AreEqual(serializedArray.first?["argument2"] as? Bool ?? true, false)
                Assert.AreEqual(serializedArray.first?["argument3"] as? Double ?? 0.0, 12.0)
                
                try JSONSerialization.data(withJSONObject: serializedArray)
                
			} catch let error as LakestoneError {
				if let containerError = error.representation as? CustomSerialization.SerializationError {
					Assert.Fail("Serialization failed because type:\(containerError.typeName) is not serializable")
				} else {
					Assert.Fail("\(error)")
				}
			} catch {
				Assert.Fail("\(error)")
			}
			
		} catch {
			Assert.Fail("\(error)")
		}
	}
	
}

#if !COOPER
extension TestCustomSerialization {
	static var allTests : [(String, (TestCustomSerialization) -> () throws -> Void)] {
		return [
			("testCustomSerialization", testCustomSerialization)
		]
	}
}
#endif
