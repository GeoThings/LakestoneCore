//
//  TestHTTP.swift
//  LakestoneCoreTests
//
//  Created by Taras Vozniuk on 9/7/16.
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
	
	import java.util
	import java.io
	import remobjects.elements.eunit
	
#else

	import XCTest
	import Foundation

	@testable import LakestoneCore
	
	#if COOPER
	#elseif os(Linux) || os(OSX)
		import PerfectThread
	#endif
	
#endif


public class TestHTTP: Test {
		
	var expectedResourceString: String!
	
	#if COOPER
	override func Setup(){
		super.Setup()
		self.commonSetup()
	}
	#else
	override public func setUp() {
		super.setUp()
		self.commonSetup()
	}
	#endif
	
	func commonSetup() {
		
		#if COOPER
			
			let jsonResourceStream = MainActivity.currentInstance.getResources().openRawResource(R.raw.raster_digitalglobe)
			guard let jsonData = try? Data.from(inputStream: jsonResourceStream),
				  var jsonResourceString = jsonData.utf8EncodedStringRepresentationº
			else {
				Assert.Fail("Cannot interpret the raw resource as string")
				return
			}
			
			Assert.IsNotEmpty(jsonResourceString)
			//raw resource stream will contain extra ByteOrderMark in the beginning, remove it
			//commenting out the comparison until SwiftBaseLibrary NativeString will be fixed
			/*
			if jsonResourceString.characters.getItem(0).toString() == "\u{feff}" {
				jsonResourceString = jsonResourceString.substring(1)
			}
			*/
			
			self.expectedResourceString = jsonResourceString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\t", with: "")
			
		#elseif os(iOS) || os(watchOS) || os(tvOS)
			
			guard let resourcePath = Bundle(for: type(of: self)).path(forResource: "raster_digitalglobe", ofType: "json") else {
				XCTFail("Cannot find desired resource in current bundle")
				return
			}
			
			guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: resourcePath)) else {
				XCTFail("Cannot read from reasouce path: \(resourcePath)")
				return
			}
			
			guard let jsonResourceString = jsonData.utf8EncodedStringRepresentationº else {
				XCTFail("Cannot interpret the raw resource as string")
				return
			}
			
			self.expectedResourceString = jsonResourceString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\t", with: "")
			
		#endif
	}
	
	
	public func testSynchronousHTTPRequest(){
		
		guard let rasterStyleFileURL = URL(string: "http://52.76.15.94/raster-digitalglobe.json") else {
			Assert.Fail("Remote resource URL has invalid format")
			return
		}
		
		let request = HTTP.Request(url: rasterStyleFileURL)
		let awaitToken = AwaitToken.with(description: "Request completion token", for: self)
		let newQueue = Threading.serialQueue(withLabel: "testQueue")
		newQueue.dispatch {
			
			var response: HTTP.Response
			do {
				response = try request.performSync()
			} catch {
				Assert.Fail("\(error)")
				return
			}
			
			awaitToken.fulfillAfter {
				
				guard let responseData = response.dataº else {
					Assert.Fail("Response data is nil while expected")
					return
				}
				guard let responseDataString = responseData.utf8EncodedStringRepresentationº else {
					Assert.Fail("Data cannot be represented as UTF8 encoded string")
					return
				}
				
				
				let sanitizedResponseString = responseDataString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\t", with: "")
						
				#if COOPER
					Assert.AreEqual(self.expectedResourceString, sanitizedResponseString)
				#elseif os(iOS) || os(watchOS) || os(tvOS)
					Assert.AreEqual(self.expectedResourceString, sanitizedResponseString)
				#else
					//TODO: Full string comparison from locally loaded resource as above
					let expectedSize = 18771
					Assert.AreEqual(responseData.count, expectedSize)
					Assert.IsTrue(sanitizedResponseString.contains("mapbox://mapbox.satellite"))
				#endif
			}
		}
		
		awaitToken.waitFor(timeout: 10.0, for: self)
	}
    
    public func testAsynchronousHTTPRequest(){
        
        guard let rasterStyleFileURL = URL(string: "http://52.76.15.94/raster-digitalglobe.json") else {
            Assert.Fail("Remote resource URL has invalid format")
            return
        }
        
        let request = HTTP.Request(url: rasterStyleFileURL)
        let awaitToken = AwaitToken.with(description: "Request completion token", for: self)
        
        request.perform { (errorº: ThrowableError?, responseº: HTTP.Response?) in
            awaitToken.fulfillAfter {
                
                guard let responseData = responseº?.dataº else {
                    Assert.Fail("Response data is nil while expected")
                    return
                }
                guard let responseDataString = responseData.utf8EncodedStringRepresentationº else {
                    Assert.Fail("Data cannot be represented as UTF8 encoded string")
                    return
                }
                
                
                let sanitizedResponseString = responseDataString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\t", with: "")
                
                #if COOPER
                    Assert.AreEqual(self.expectedResourceString, sanitizedResponseString)
                #elseif os(iOS) || os(watchOS) || os(tvOS)
                    Assert.AreEqual(self.expectedResourceString, sanitizedResponseString)
                #else
                    //TODO: Full string comparison from locally loaded resource as above
                    let expectedSize = 18771
                    Assert.AreEqual(responseData.count, expectedSize)
                    Assert.IsTrue(sanitizedResponseString.contains("mapbox://mapbox.satellite"))
                #endif
            }
        }
        
        awaitToken.waitFor(timeout: 10.0, for: self)
    }
}

#if !COOPER
extension TestHTTP {
	static var allTests : [(String, (TestHTTP) -> () throws -> Void)] {
		return [
			("testSynchronousHTTPRequest", testSynchronousHTTPRequest),
            ("testAsynchronousHTTPRequest", testAsynchronousHTTPRequest)
		]
	}
}
#endif
