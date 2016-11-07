//
//  Directory.swift
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

#else
	import Foundation
	#if os(OSX) || os(Linux)
		import PerfectThread
	#endif
#endif

public class Directory: AnyFileOrDirectory {
	
	#if COOPER
	private let _fileEntity: File
	#else
	public let path: String
	#endif
	
	public init(path: String){
		#if COOPER
			_fileEntity = File(path: path)
		#else
			self.path = path
		#endif
	}
	
	public init(directoryURL: URL){
		#if COOPER
			_fileEntity = File(fileURL: directoryURL)
		#else
			self.path = directoryURL.path
		#endif
	}
	
	#if COOPER
	
	public var path: String {
		return _fileEntity.path
	}
	
	public var exists: Bool {
		return _fileEntity.exists
	}
	
	public var isDirectory: Bool {
		return _fileEntity.isDirectory
	}
	
	public var lastModificationDateº: Date? {
		return _fileEntity.lastModificationDateº
	}
	
	#endif
	
	public var url: URL {
		return URL(fileURLWithPath: self.path)
	}
	
	public var name: String {
		#if COOPER
			return _fileEntity.getName()
		#else
			return self.url.lastPathComponent
		#endif
	}
	
	public var size: Int64 {
		
		var accumulativeSize: Int64 = 0
		for entity in self.filesAndSubdirectories {
			accumulativeSize += entity.size
		}
		
		return accumulativeSize
	}
	
	public func getSize(completionHandler: @escaping (Int64) -> Void){
		
		let sizeRetrievalQueue = Threading.serialQueue(withLabel: "lakestone.core.size-retrieval-queue")
		sizeRetrievalQueue.dispatch {
			let targetSize = self.size
			completionHandler(targetSize)
		}
	}
	
	/// Creates a directory corresponfing to current Directory object
	/// - Throws: Creation error
	public func create() throws {
		#if COOPER
			if (!_fileEntity.mkdir()){
				throw Error.CreationFailed
			}
		#else
			return try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: false, attributes: nil)
		#endif
	}
	
	/// Creates a new directory within the given one
	/// - Parameters:
	///   - named: Subdirectory name
	/// - Throws: Creation error
	/// - Returns: Subdirectory object
	public func createSubdirectory(named: String) throws -> Directory {
		let subdirectory = Directory(directoryURL: self.url.appendingPathComponent(named))
		try subdirectory.create()
		return subdirectory
	}
    
    public func subdirectory(named: String) throws -> Directory {
        let subdirectory = Directory(directoryURL: self.url.appendingPathComponent(named))
        if subdirectory.exists {
            return subdirectory
        } else {
            return try self.createSubdirectory(named: named)
        }
    }
	
	public var filesAndSubdirectories: [AnyFileOrDirectory] {
		
		#if COOPER
			let names = [String](_fileEntity.list())
		#else
			guard let names = try? FileManager.default.contentsOfDirectory(atPath: self.path) else {
				return []
			}
		#endif
		
		return [AnyFileOrDirectory](names.map { self.url.appendingPathComponent($0) } .map { FileOrDirectory(with: $0) })
	}
	
	public var files: [File] {
		return [File](self.filesAndSubdirectories.filter { !$0.isDirectory }.map { File(path: $0.path) })
	}
	
	public var subdirectories: [Directory] {
		return [Directory](self.filesAndSubdirectories.filter { $0.isDirectory }.map { Directory(path: $0.path) })
	}
	
	/// Removes the target with all files and subdirectories
	/// - Throws: remove error
	public func remove() throws {
		for entity in self.filesAndSubdirectories {
			try entity.remove()
		}
		
		#if COOPER
			try _fileEntity.remove()
		#else
			try FileManager.default.removeItem(atPath: self.path)
		#endif
	}
	
	/// Asynchronous calling of remove function
	public func remove(completionHandler: @escaping (ThrowableError?) -> Void){
		
		let deletionQueue = Threading.serialQueue(withLabel: "lakestone.core.file-deletion-queue")
		deletionQueue.dispatch {
			do {
				try self.remove()
				completionHandler(nil)
			} catch {
				// in Java silver error has Object type, so conditionals to avoid warning for redundant as! in Swift
				#if COOPER
					completionHandler(error as! ThrowableError)
				#else
					completionHandler(error)
				#endif
			}
		}
	}
	
	/// - Returns: nil if already at root directory or Directory object based on target's url without ending
	public var parentDirectoryº: Directory? {
		return (self.path == "/") ? nil : Directory(directoryURL: self.url.deletingLastPathComponent())
	}
	
	/// Copies the current folder with all files and subfolders into a new folder location
	/// - Parameters:
	///   - destination: Parent directory for new target folder location
	///   - overwrites: True to overwrite or false to throw exception if any file exists at the new location
	/// - Throws: Error occurs when the destination doesn't exist or is not a folder; 
	/// when the new folder cannot be created at the new location; 
	/// when copying or overwriting fails
	/// - Returns: The new folder location as AnyFileOrDirectory
	/// - Note: recursively copies all subfolders, thus may take long time to complete
	public func copy(to destination: AnyFileOrDirectory, overwrites: Bool) throws -> AnyFileOrDirectory {
		
		var destinationFolder: Directory
		if destination.isDirectory {
			destinationFolder = Directory (directoryURL: destination.url)
		} else { throw Error.WrongDestination }
		
		// create new subdirectory if necessary
		let copyDirectory = Directory(directoryURL: destinationFolder.url.appendingPathComponent(self.name))
		if (!copyDirectory.exists) { try copyDirectory.create() }
		
		for entity in self.filesAndSubdirectories {
			#if COOPER
				if (entity.isDirectory){
					_ = try Directory(path: entity.path).copy(to: copyDirectory, overwrites: overwrites)
				} else {
					_ = try File(path: entity.path).copy(to: copyDirectory, overwrites: overwrites)
				}
			#else
				_ = try entity.copy(to: copyDirectory, overwrites: overwrites)
			#endif
		}
		
		return copyDirectory
	}
	
	/// Asynchronous calling of copy function
	public func copy(to destination: AnyFileOrDirectory, overwrites: Bool, completionHandler: @escaping (ThrowableError?, AnyFileOrDirectory?) -> Void){
		
		let copyQueue = Threading.serialQueue(withLabel: "lakestone.core.filedir-copy-queue")
		copyQueue.dispatch {
			do {
				let copyDirectory = try self.copy(to: destination, overwrites: overwrites)
				completionHandler(nil, copyDirectory)
			} catch {
				// in Java silver error has Object type, so conditionals to avoid warning for redundant as! in Swift
				#if COOPER
					completionHandler(error as! ThrowableError, nil)
				#else
					completionHandler(error, nil)
				#endif
			}
		}
	}

	/// Moves the current folder with all files and subfolders into a new folder location by copying and then removing original
	/// - Parameters:
	///   - destination: Parent directory for new target folder location
	///   - overwrites: True to overwrite or false to throw exception if any file exists at the new location
	/// - Throws: Error occurs when the destination doesn't exist or is not a folder; 
	/// when the new folder cannot be created at the new location; 
	/// when copying, overwriting or deletion fails
	/// - Returns: The new folder location as AnyFileOrDirectory
	/// - Note: recursively moves all subfolders, thus may take long time to complete
	public func move(to destination: AnyFileOrDirectory, overwrites: Bool) throws -> AnyFileOrDirectory {
		
		let destinationFolder = try self.copy(to: destination, overwrites: overwrites)
		
		if self.exists { try self.remove() }
		
		return destinationFolder
	}
	
	/// Asynchronous calling of move function
	public func move(to destination: AnyFileOrDirectory, overwrites: Bool, completionHandler: @escaping (ThrowableError?, AnyFileOrDirectory?) -> Void){
		
		let moveQueue = Threading.serialQueue(withLabel: "lakestone.core.filedir-move-queue")
		moveQueue.dispatch {
			do {
				let destinationFolder = try self.move(to: destination, overwrites: overwrites)
				completionHandler(nil, destinationFolder)
			} catch {
				// in Java silver error has Object type, so conditionals to avoid warning for redundant as! in Swift
				#if COOPER
					completionHandler(error as! ThrowableError, nil)
				#else
					completionHandler(error, nil)
				#endif
			}
		}
	}

	#if COOPER
	
	public static func applicationDefault(inContext context: android.content.Context) -> Directory {
		return Directory(path:context.getFilesDir().getCanonicalPath())
	}
	
	public static func applicationCache(inContext context: android.content.Context) -> Directory? {
		return Directory(path:context.getCacheDir().getCanonicalPath())
	}
	
	#else
	
	public static var applicationDefault: Directory {
		#if os(iOS) || os(watchOS) || os(tvOS)
			if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
				return Directory(path: documentsDirectoryPath)
			} else {
				return Directory(path: FileManager.default.currentDirectoryPath)
			}
		#else
			return Directory(path: FileManager.default.currentDirectoryPath)
		#endif
	}
	
	public static var applicationCache: Directory? {
		
		#if os(iOS) || os(watchOS) || os(tvOS)
			guard let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
				return nil
			}
			
			let cacheDirectory = Directory(path: cacheDirectoryPath)
		#else
			let cacheDirectory = Directory(directoryURL: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("cache"))
		#endif
		
		if !cacheDirectory.exists {
			do {
				try cacheDirectory.create()
			} catch {
				print("Failed to created cache directory: \(error)")
				return nil
			}
		}

		return cacheDirectory
	}
		
	#endif
	
	public func file(withName nameWithExtension: String) -> File {
		return File(fileURL: self.url.appendingPathComponent(nameWithExtension))
	}
	
	/// in Java temp gets appended with .tmp extension
	public func cacheFile(withName nameWithExtension: String) -> File {
		
		#if COOPER
			var cacheFile = self.file(withName: nameWithExtension.appending(".tmp"))
			if cacheFile.exists {
				return cacheFile
			}
			
			//cacheFile = File.createTempFile(nameWithExtension, nil, _fileEntity)
			//return cacheFile
			return self.file(withName: nameWithExtension)
		#else
			return self.file(withName: nameWithExtension)
		#endif
	}
	
	public func containsFile(withName nameWithExtension: String) -> Bool {
		let file = self.file(withName: nameWithExtension)
		return file.exists
	}
	
	public func containsCacheFile(withName nameWithExtension: String) -> Bool {
		let tempFile = self.file(withName: nameWithExtension.appending(".tmp"))
		return tempFile.exists
	}
}

extension Directory: CustomStringConvertible {
	public var description: String {
		return self.path
	}
}
extension Directory {
	//prevent name collision with Foundation.Error that is used in remove(completionHandler:)
	public class Error {
		static let CreationFailed = LakestoneError.with(stringRepresentation: "Directory creation failed")
		static let DeletionFailed = LakestoneError.with(stringRepresentation: "Directory deletion failed")
		static let WrongDestination = LakestoneError.with(stringRepresentation: "Provided destination is not a folder or doesn't exist")
		public static let OverwriteFailed = LakestoneError.with(stringRepresentation: "File(s) already exists. You need to explicitly allow overwriting, if desired.")
	}
}

extension Directory: Equatable {

	#if COOPER
	public override func equals(_ o: Object!) -> Bool {
		
		guard let other = o as? Self else {
			return false
		}
		
		return (self == other)
	}
	#endif
}

public func ==(lhs: Directory, rhs: Directory) -> Bool {
	return lhs.path == rhs.path
}
