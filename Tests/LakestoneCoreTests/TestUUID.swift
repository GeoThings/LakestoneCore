//
//  TestUUID.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/28/16.
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

class TestUUID: Test {
	
	public func testUUID(){
		
		let newUUID = UUID()
		
		let uuidString = newUUID.uuidString
		//RFC 4122 UUID: 32 hex digits + 4 dashes
		Assert.AreEqual(newUUID.uuidString.characterCount, 36)
		
		guard let identicalUUID = UUID(uuidString: uuidString) else {
			Assert.Fail("UUID string has invalid format")
			return
		}
		
		Assert.AreEqual(newUUID, identicalUUID)
	}
}

#if !COOPER
extension TestUUID {
	static var allTests : [(String, (TestUUID) -> () throws -> Void)] {
		return [
			("testUUID", testUUID)
		]
	}
}
#endif
