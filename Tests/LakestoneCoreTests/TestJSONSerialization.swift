//
//  TestJSONSerialization.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 10/1/16.
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


class TestJSONSerialization: Test {

	var jsonData: Data!
	
	#if COOPER
	override func Setup(){
		super.Setup()
		self.commonSetup()
	}
	#else
	override func setUp() {
		super.setUp()
		self.commonSetup()
	}
	#endif
	
	func commonSetup() {
		
		#if COOPER
			
			let jsonResourceStream = MainActivity.currentInstance.getResources().openRawResource(R.raw.raster_digitalglobe)
			guard let jsonData = try? Data.from(inputStream: jsonResourceStream) else {
				Assert.Fail("Cannot retrieve raw resource data")
				return
			}
			
			self.jsonData = jsonData
			
		#elseif os(iOS) || os(watchOS) || os(tvOS)
			
			guard let resourcePath = Bundle(for: type(of: self)).path(forResource: "raster_digitalglobe", ofType: "json") else {
				XCTFail("Cannot find desired resource in current bundle")
				return
			}
			
			guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: resourcePath)) else {
				XCTFail("Cannot read from reasouce path: \(resourcePath)")
				return
			}
			
			self.jsonData = jsonData
			
		#else
		
			guard let rasterStyleFileURL = URL(string: "http://52.76.15.94/raster-digitalglobe.json") else {
				Assert.Fail("Remote resource URL has invalid format")
				return
			}
			
			let request = HTTP.Request(url: rasterStyleFileURL)
			
			var response: HTTP.Response
			do {
				response = try request.performSync()
			} catch {
				Assert.Fail("\(error)")
				return
			}
		
			guard let responseData = response.dataº else {
				Assert.Fail("Response data is nil while expected")
				return
			}
			
			self.jsonData = responseData
			
		#endif
	}
	
	public func testJSONSerialization(){
		
		do {
			
			let jsonObject = try JSONSerialization.jsonObject(with: self.jsonData)
			guard let jsonDictionary = jsonObject as? [String: Any] else {
				Assert.Fail("Serialized json is not a dictionary")
				return
			}
		
			Assert.AreEqual((jsonDictionary["version"] as? Int) ?? 0, 7)
			Assert.AreEqual((jsonDictionary["layers"] as? [Any])?.count ?? 0, 29)
			
			guard let stopsEntity = ((jsonDictionary["constants"] as? [String: Any])?["@road-width-major"] as? [String:Any])?["stops"] as? [Any] else {
				Assert.Fail("Cannot retrieve the stops entity")
				return
			}
			
			Assert.AreEqual(((stopsEntity.first as? [Any])?.first as? Int) ?? 0, 5)
			
            //TODO: Investigate java.lang.InterruptedException cause
			/* 
             completes gracefully,
             but keeps throwing java.lang.InterruptedException
             
			let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
			Assert.AreEqual(jsonData.bytes.count, 13461)
			
			let parsedBackjsonObject = try JSONSerialization.jsonObject(with: jsonData)
			guard let parsedBackJsonDictionary = parsedBackjsonObject as? [String: Any] else {
				Assert.Fail("Serialized json is not a dictionary")
				return
			}
			
			Assert.AreEqual((parsedBackJsonDictionary["version"] as? Int) ?? 0, 7)
			guard let parsedBackStopsEntity = ((parsedBackJsonDictionary["constants"] as? [String: Any])?["@road-width-major"] as? [String:Any])?["stops"] as? [Any] else {
				Assert.Fail("Cannot retrieve the stops entity")
				return
			}
 
			Assert.AreEqual(((parsedBackStopsEntity.first as? [Any])?.first as? Int) ?? 0, 5)
			*/
			
		} catch {
			Assert.Fail("JSON parsing failed: \(error))")
		}
		
	}

}
