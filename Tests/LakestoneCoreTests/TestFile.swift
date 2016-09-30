//
//  TestFile.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/29/16.
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

class TestFile: Test {
	
	var workingDirectoryPath: String!
	
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
			self.workingDirectoryPath = MainActivity.currentInstance.getFilesDir().getCanonicalPath()
		#elseif os(iOS) || os(watchOS) || os(tvOS)
			self.workingDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false)
		#else
			self.workingDirectoryPath = FileManager.default.currentDirectoryPath
		#endif
	}
	
	public func testFileOperations(){
		
		
		let sampleText = "Just come text for this test...º"
		let andSomeMoreText = "Yeah... more and more text"
		let overwriteText = "Text to overwrite"
		
		let testFileURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("testFile.txt")
		let testFile = File(fileURL: testFileURL)
		
		
		do {
			if testFile.exists {
				try testFile.remove()
				Assert.IsFalse(testFile.exists)
			}
			
			try testFile.overwrite(with: sampleText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), sampleText)
			try testFile.overwrite(with: overwriteText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), overwriteText)
			try testFile.overwrite(with: sampleText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), sampleText)
			try testFile.append(utf8EncodedString: andSomeMoreText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), sampleText + andSomeMoreText)
			
			Assert.AreEqual(testFile.name, "testFile")
			Assert.AreEqual(testFile.extension, "txt")
			Assert.IsFalse(testFile.isDirectory)
			
			//'º' is only character two bytes in size
			Assert.AreEqual(testFile.size, (sampleText + andSomeMoreText).characterCount + 1)
			guard let modificationDate = testFile.lastModificationDateº else {
				Assert.Fail("Cannot retrieve file last modification date")
				return
			}
			
			Assert.IsTrue(modificationDate.timeIntervalSince1970 < Date().timeIntervalSince1970 + 60.0)
			
			let sameFileInitedWithPath = File(path: testFileURL.path)
			Assert.IsTrue(sameFileInitedWithPath.exists)
			Assert.AreEqual(sameFileInitedWithPath.name, "testFile")
			Assert.AreEqual(sameFileInitedWithPath.extension, "txt")
			Assert.IsFalse(sameFileInitedWithPath.isDirectory)
			
			try sameFileInitedWithPath.remove()
			Assert.IsFalse(sameFileInitedWithPath.exists)
			
            guard let parentDirectory = testFile.parentDirectoryº else {
                Assert.Fail("Cannot retrieve parent directory (already root)")
                return
            }
            
            Assert.AreEqual(parentDirectory.path, self.workingDirectoryPath)

            let sameTestFile = File(fileURL: testFileURL)
            Assert.AreEqual(sameTestFile, testFile)
            
		} catch {
			Assert.Fail("File operation failed: \(error)")
		}
		
	}
	
}

#if !COOPER
extension TestFile {
	static var allTests : [(String, (TestFile) -> () throws -> Void)] {
		return [
			("testFileOperations", testFileOperations)
		]
	}
}
#endif
