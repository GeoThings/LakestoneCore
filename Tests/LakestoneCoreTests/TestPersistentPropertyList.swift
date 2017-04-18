//
//  TestPersistentPropertyList.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 10/9/16.
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


public class TestPersistentPropertyList: Test {

	public func testPersistentPropertyList() {
		
		#if COOPER
			let persistentPropertyList = PersistentPropertyList(applicationContext: MainActivity.currentInstance)
		#else
			let persistentPropertyList = PersistentPropertyList()
		#endif
		
        // UserDefaults is not fully implemented on Linux with 3.0.0 shipped Foundation
        // object(forKey: ) will yield nil in Linux for now
		persistentPropertyList.setBool(true, forKey: "boolTest")
		persistentPropertyList.setInt(26, forKey: "intTest")
		persistentPropertyList.setFloat(Float(26.0), forKey: "floatTest")
		persistentPropertyList.setDouble(26.0, forKey: "doubleTest")
        persistentPropertyList.setString("testString", forKey: "stringTest")
		persistentPropertyList.setStringSet(Set<String>(["string1", "string2", "string3"]), forKey: "stringSetTest")
		persistentPropertyList.setArray([Int]([1,2,3,4,5,6,7,8]), forKey: "arrayTest")
		persistentPropertyList.setSet(Set<Int>([1,2,3,3]), forKey: "setTest")
		persistentPropertyList.setDictionary(["string": "String",
									"decimal": Int(35),
									//if storing 36.0, JSONObject will parse it back as Int
									"double": 36.2],
								   forKey: "dictionaryTest")
		persistentPropertyList.setDate(Date(timeIntervalSince1970: 1472688000.0), forKey: "dateTest")
		persistentPropertyList.setURL(URL(string: "http://google.com")!, forKey: "urlTest")
		persistentPropertyList.setUUID(UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, forKey: "uuidTest")
		persistentPropertyList.synchronize()
		
        //for now UserDefaults object(forKey:) will fail
		Assert.AreEqual(persistentPropertyList.bool(forKey: "boolTest") ?? false, true)
		Assert.AreEqual(persistentPropertyList.integer(forKey: "intTest") ?? 0, 26)
		Assert.AreEqual(persistentPropertyList.float(forKey: "floatTest") ?? Float(0.0), Float(26.0))
		Assert.AreEqual(persistentPropertyList.double(forKey: "doubleTest") ?? 0.0, 26.0)
		Assert.AreEqual(persistentPropertyList.string(forKey: "stringTest") ?? "", "testString")
		
		guard let stringSet = persistentPropertyList.stringSet(forKey: "stringSetTest") else {
			Assert.Fail("Persistent property list doesn't contain string set for 'stringSetTest' key")
			return
		}
		
		Assert.IsTrue(stringSet.contains("string1"))
		Assert.IsTrue(stringSet.contains("string2"))
		Assert.IsTrue(stringSet.contains("string3"))
		
		Assert.AreEqual(persistentPropertyList.array(forKey: "arrayTest") as? [Int] ?? [Int](), [Int]([1,2,3,4,5,6,7,8]))
		
		guard let set = persistentPropertyList.set(forKey: "setTest") as? Set<Int> else {
			Assert.Fail("Persistent property list doesn't contain set for 'setTest' key")
			return
		}
		
		Assert.IsTrue(set.contains(1))
		Assert.IsTrue(set.contains(2))
		Assert.IsTrue(set.contains(3))
		
		guard let testDictionary = persistentPropertyList.dictionary(forKey: "dictionaryTest") else {
			Assert.Fail("Persistent property list doesn't contain dictionary for 'dictionaryTest' key")
			return
		}
		
		Assert.AreEqual(testDictionary["string"] as? String ?? "", "String")
		Assert.AreEqual(testDictionary["decimal"] as? Int ?? 0, 35)
		
		// serialized double with .0 will be deserialized as Int in JSONObject
		Assert.AreEqual(testDictionary["double"] as? Double ?? 0.0, 36.2)
		
		Assert.AreEqual(persistentPropertyList.date(forKey: "dateTest") ?? Date(), Date(timeIntervalSince1970: 1472688000.0))
		Assert.AreEqual(persistentPropertyList.url(forKey: "urlTest") ?? URL(string: "http://not.com")!, URL(string: "http://google.com")!)
		Assert.AreEqual(persistentPropertyList.uuid(forKey: "uuidTest") ?? UUID(), UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!)
		
		persistentPropertyList.removeObject(forKey: "boolTest")
		persistentPropertyList.removeObject(forKey: "intTest")
		persistentPropertyList.removeObject(forKey: "floatTest")
		persistentPropertyList.removeObject(forKey: "doubleTest")
		persistentPropertyList.removeObject(forKey: "stringTest")
		persistentPropertyList.removeObject(forKey: "stringSetTest")
		persistentPropertyList.removeObject(forKey: "arrayTest")
		persistentPropertyList.removeObject(forKey: "setTest")
		persistentPropertyList.removeObject(forKey: "dictionaryTest")
		persistentPropertyList.removeObject(forKey: "urlTest")
		persistentPropertyList.removeObject(forKey: "uuidTest")
		
		persistentPropertyList.synchronize()
		
		Assert.IsFalse(persistentPropertyList.contains(key: "boolTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "intTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "floatTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "doubleTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "stringTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "stringSetTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "arrayTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "setTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "dictionaryTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "urlTest"))
		Assert.IsFalse(persistentPropertyList.contains(key: "uuidTest"))
	}
}
