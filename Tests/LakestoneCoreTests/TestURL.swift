﻿//
//  TestURL.swift
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
	
	@testable import LakestoneCore
	
#endif

public class TestURL: Test {

	public func testURLUtilities(){
		
		let testPath = "/usr/path/to/some/resource.test"
		
		//Assert.IsNil(URL(string: "ººº"))
		Assert.IsNotNil(URL(string: "file://" + testPath))
		
		let url = URL(fileURLWithPath: testPath)
		Assert.AreEqual(url.path, testPath)
		Assert.AreEqual(url.pathComponents, ["/","usr", "path", "to", "some", "resource.test"])
		Assert.AreEqual(url.lastPathComponent, "resource.test")
		Assert.AreEqual(url.pathExtension, "test")
		
		let rootURL = URL(fileURLWithPath: "/")
		Assert.AreEqual(rootURL.path, "/")
		Assert.AreEqual(rootURL.pathComponents, ["/"])
		Assert.AreEqual(rootURL.lastPathComponent, "/")
		Assert.AreEqual(rootURL.pathExtension, "")
		
		let folderPath = "/usr/path/to/some/resource/"
		let folderURL = URL(fileURLWithPath: folderPath)
		Assert.AreEqual(folderURL.path, folderPath.substring(to: folderPath.index(before: folderPath.endIndex)))
		Assert.AreEqual(folderURL.pathComponents, ["/", "usr", "path", "to", "some", "resource"])
		Assert.AreEqual(folderURL.lastPathComponent, "resource")
		Assert.AreEqual(folderURL.pathExtension, "")
		
		let folderPathWithExtraComponent = folderURL.appendingPathComponent("anotherDir", isDirectory: true)
		let expectedPath = folderPath + "anotherDir"
		Assert.AreEqual(folderPathWithExtraComponent.path, expectedPath)
		
		Assert.IsTrue(url.isFileURL)
		Assert.IsFalse(URL(string: "http://someresource.com")!.isFileURL)
		
		Assert.AreEqual(url.deletingLastPathComponent().path, "/usr/path/to/some")
		
		guard let sampleToAddQueryParams = URL(string: "http://getsomestuff.com:8080/from/here") else {
			Assert.Fail("Cannot create URL from string")
			return
		}
		
		guard let sampleWithSingleParam = sampleToAddQueryParams.appendingQueryParameter(withKey: "my", value: nil),
			  let sampleWithSpacedParameter = sampleToAddQueryParams.appendingQueryParameters(["spacedParam":"spaced parameter"])
		else {
			Assert.Fail("Cannot append query parameter")
			return
		}
		
		Assert.AreEqual(sampleWithSingleParam.absoluteString, "http://getsomestuff.com:8080/from/here?my")
		Assert.AreEqual(sampleWithSpacedParameter.absoluteString, "http://getsomestuff.com:8080/from/here?spacedParam=spaced%20parameter")
	}
}
