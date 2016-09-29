//
//  TestDirectory.swift
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

class TestDirectory: Test {

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
	
	public func testDirectoryOperations(){
		
		
		
		let testDirectoryURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("testDirectory")
		let testDirectory = Directory(fileURL: testDirectoryURL)
		
		do {
			
			if testDirectory.exists {
				try testDirectory.remove()
				Assert.IsFalse(testDirectory.exists)
			}
			
			try testDirectory.create()
			Assert.IsTrue(testDirectory.isDirectory)
			Assert.IsTrue(testDirectory.exists)
			
			let file1 = File(fileURL: testDirectoryURL.appendingPathComponent("file1.txt"))
			let file2 = File(fileURL: testDirectoryURL.appendingPathComponent("file2.txt"))
			let file3 = File(fileURL: testDirectoryURL.appendingPathComponent("file3.txt"))
			
			try file1.overwrite(with: "file-1")
			try file2.overwrite(with: "file-2")
			try file3.overwrite(with: "file-3")
			
			Assert.AreEqual(testDirectory.filesAndSubdirectories.count, 3)
			
			let subdirectory1 = try testDirectory.createSubdirectory(named: "subdir1")
			let subdirectory2 = try testDirectory.createSubdirectory(named: "subdri2")
		
			Assert.IsTrue(subdirectory1.exists)
			Assert.IsTrue(subdirectory2.exists)
			Assert.IsTrue(subdirectory1.isDirectory)
			Assert.IsTrue(subdirectory2.isDirectory)
			
			Assert.AreEqual(testDirectory.filesAndSubdirectories.count, 5)
			Assert.AreEqual(testDirectory.subdirectories.count, 2)
			
			for entity in testDirectory.filesAndSubdirectories {
				if entity.isDirectory {
					Assert.IsTrue(entity is Directory)
				} else {
					//Assert.IsTrue(entity is File)
				}
			}
			
			try testDirectory.remove()
			Assert.IsFalse(file1.exists)
			Assert.IsFalse(subdirectory1.exists)
			Assert.AreEqual(testDirectory.filesAndSubdirectories.count, 0)
			Assert.IsFalse(testDirectory.exists)
			
		} catch {
			Assert.Fail("Directory operation failed: \(error)")
		}
		
	}
}

#if !COOPER
extension TestDirectory {
	static var allTests : [(String, (TestDirectory) -> () throws -> Void)] {
		return [
			("testDirectoryOperations", testDirectoryOperations)
		]
	}
}
#endif
