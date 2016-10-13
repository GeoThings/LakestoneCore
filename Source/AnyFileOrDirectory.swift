//
//  AnyFileOrDirectory.swift
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

#if !COOPER
	import Foundation
#endif

public protocol AnyFileOrDirectory {
	
	var path: String { get }
    var url: URL { get }
	var exists: Bool { get }
	var isDirectory: Bool { get }
	
	var name: String { get }
	var size: Int64 { get }
	var lastModificationDateº: Date? { get }
	
	func remove() throws
	
	var parentDirectoryº: Directory? { get }
	
	// copy the file or directory with subdirectories to new destination; overwrite existing or throw exception
    // returns new location
	func copy(to destination: AnyFileOrDirectory, overwrites: Bool) throws -> AnyFileOrDirectory
	
	// move the file or directory with subdirectories to new destination; overwrite existing or throw exception
    // returns new location
	func move(to destination: AnyFileOrDirectory, overwrites: Bool) throws -> AnyFileOrDirectory
}

#if !COOPER
extension AnyFileOrDirectory {
	
	public var exists: Bool {
		return FileManager.default.fileExists(atPath: self.path)
	}
	
	public var isDirectory: Bool {
		var isDirectoryPath: ObjCBool = ObjCBool(false)
		let doesFileExists = FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectoryPath)
		#if os(Linux)
			return doesFileExists && Bool(isDirectoryPath)
		#else
			return doesFileExists && isDirectoryPath.boolValue
		#endif
	}

	public var lastModificationDateº: Date? {
		guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: self.path) else {
			return nil
		}
		
		return fileAttributes[FileAttributeKey.modificationDate] as? Date
	}
}
#endif


public func FileOrDirectory(with path: String) -> AnyFileOrDirectory {
	let file = File(path: path)
	if (file.isDirectory) {
		return Directory(path: path)
	} else {
		return file
	}
}

public func FileOrDirectory(with fileURL: URL) -> AnyFileOrDirectory {
	let file = File(fileURL: fileURL)
	if (file.isDirectory) {
		return Directory(directoryURL: fileURL)
	} else {
		return file
	}
}

