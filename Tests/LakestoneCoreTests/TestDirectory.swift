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
	
	@testable import LakestoneCore
	
#endif

public class TestDirectory: Test {

	var workingDirectoryPath: String!
	
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
			self.workingDirectoryPath = MainActivity.currentInstance.getFilesDir().getCanonicalPath()
		#elseif os(iOS) || os(watchOS) || os(tvOS)
			if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false).first {
				self.workingDirectoryPath = (documentsDirectoryPath as NSString).expandingTildeInPath
			}
		#else
			self.workingDirectoryPath = FileManager.default.currentDirectoryPath
		#endif
	}
	
	public func testDirectoryOperations(){
		
		let testDirectoryURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("TestDirectory")
		let testDirectory = Directory(directoryURL: testDirectoryURL)
        let testCopyDirectoryURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("TestCopyDirectory")
        let testCopyDirectory = Directory(directoryURL: testCopyDirectoryURL)
        let testMoveDirectoryURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("TestMoveDirectory")
        let testMoveDirectory = Directory(directoryURL: testMoveDirectoryURL)
		
		do {
			
			if testDirectory.exists {
				try testDirectory.remove()
				Assert.IsFalse(testDirectory.exists)
			}
            if testCopyDirectory.exists {
                try testCopyDirectory.remove()
                Assert.IsFalse(testCopyDirectory.exists)
            }
            if testMoveDirectory.exists {
                try testMoveDirectory.remove()
                Assert.IsFalse(testMoveDirectory.exists)
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
			
            // MARK: Directory copy and move tests
            try testCopyDirectory.create()
            try testMoveDirectory.create()
            var newLocation = try testDirectory.copy(to: testCopyDirectory, overwrites: true)
            let copiedDirectory = Directory(directoryURL: newLocation.url)
            Assert.AreEqual(testDirectory.name, copiedDirectory.name)
            Assert.AreEqual(testDirectory.filesAndSubdirectories.count, copiedDirectory.filesAndSubdirectories.count)
            Assert.AreEqual(testDirectory.subdirectories.count, copiedDirectory.subdirectories.count)
            
            newLocation = try copiedDirectory.move(to: testMoveDirectory, overwrites: true)
            Assert.AreEqual(testCopyDirectory.filesAndSubdirectories.count, 0)
            let movedDirectory = Directory(directoryURL: newLocation.url)
            Assert.AreEqual(testDirectory.name, movedDirectory.name)
            Assert.AreEqual(testDirectory.filesAndSubdirectories.count, movedDirectory.filesAndSubdirectories.count)
            Assert.AreEqual(testDirectory.subdirectories.count, movedDirectory.subdirectories.count)
            
            guard let parentCopyDirectory = copiedDirectory.parentDirectoryº else {
                Assert.Fail("Cannot get parent dir of copied directory")
                return
            }
            Assert.AreEqual(parentCopyDirectory,testCopyDirectory)
            
            guard let parentMoveDirectory = movedDirectory.parentDirectoryº else {
                Assert.Fail("Cannot get parent dir of moved directory")
                return
            }
            Assert.AreEqual(parentMoveDirectory,testMoveDirectory)
            
            // MARK: cleanup
			try testDirectory.remove()
			Assert.IsFalse(file1.exists)
			Assert.IsFalse(subdirectory1.exists)
			Assert.AreEqual(testDirectory.filesAndSubdirectories.count, 0)
			Assert.IsFalse(testDirectory.exists)
            try testCopyDirectory.remove()
            Assert.IsFalse(testCopyDirectory.exists)
            try testMoveDirectory.remove()
            Assert.IsFalse(testMoveDirectory.exists)
            Assert.AreEqual(testMoveDirectory.filesAndSubdirectories.count, 0)
			
			guard let parentDirectory = testDirectory.parentDirectoryº else {
				Assert.Fail("Cannot retrieve parent directory (already root)")
				return
			}
			
			Assert.AreEqual(parentDirectory.path, self.workingDirectoryPath ?? String())
			Assert.AreEqual(parentDirectory, Directory(path: self.workingDirectoryPath))
			
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
