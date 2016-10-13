//
//  File.swift
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
	import java.io
#else
	import Foundation
#endif


#if !COOPER

public class File: AnyFileOrDirectory {
	
	public let path: String
	public init(path: String){
		self.path = path
	}
	
	public init(fileURL: URL){
		self.path = fileURL.path
	}
}
	
#else
	
extension File: AnyFileOrDirectory {}
	
#endif

extension File {
	
	#if COOPER
	
	public init(path: String){
		self.init(path)
	}
	
	public init(fileURL: URL){
		self.init(fileURL.toURI())
	}
	
	public var path: String {
		return self.getCanonicalPath()
	}
	
	public var exists: Bool {
		return self.exists()
	}
	
	public var isDirectory: Bool {
		return self.isDirectory()
	}
	
	public var lastModificationDateº: Date? {
		return Date(self.lastModified())
	}
	#endif
	
    public var url: URL {
        return URL(fileURLWithPath: self.path)
    }
    
	public var name: String {
		#if COOPER
			let nameWithExtension = self.getName()
			guard let extensionSeperatorRange = nameWithExtension.range(of: ".", searchBackwards: true) else {
				return nameWithExtension
			}
		#else
			let nameWithExtension = self.url.lastPathComponent
			guard let extensionSeperatorRange = nameWithExtension.range(of: ".", options: .backwards) else {
				return nameWithExtension
			}
		#endif
		
		return nameWithExtension.substring(to: extensionSeperatorRange.lowerBound)
	}
	
	public var `extension`: String {
		return self.url.pathExtension
	}
	
	public var size: Int64 {
		
		#if COOPER
			return self.length()
			
		#else
			guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: self.path) else {
				return -1
			}
			
			return (fileAttributes[FileAttributeKey.size] as? NSNumber)?.int64Value ?? -1
			
		#endif
	}
	
	public func readData() throws -> Data {
		
		#if COOPER
			return try Data.from(inputStream: FileInputStream(self))
		#else
			return try Data(contentsOf: self.url)
		#endif
	}
	
	public func readUTF8EncodedString() throws -> String {
		
		let data = try self.readData()
		guard let targetString = data.utf8EncodedStringRepresentationº else {
			throw Data.Error.NonUTF8Encoding
		}
		
		return targetString
	}
	
	public var dataº: Data? {
		return try? self.readData()
	}
	
	public var utf8EncodedStringDataRepresentationº: String? {
		return try? self.readUTF8EncodedString()
	}
	
	public func overwrite(with data: Data) throws {
		
		#if COOPER
			let outputChannel = FileOutputStream(self, false).getChannel()
			outputChannel.write(data)
			outputChannel.close()
			
		#else
			try data.write(to: self.url)
		#endif
	}
	
	public func overwrite(with utf8EncodedString: String) throws {
		
		guard let utf8Data = Data.with(utf8EncodedString: utf8EncodedString) else {
			throw Data.Error.UTF8IncompatibleString
		}
		
		try self.overwrite(with: utf8Data)
	}
	
	public func append(data: Data) throws {
		
		#if COOPER
			
			let outputChannel = FileOutputStream(self, true).getChannel()
			outputChannel.write(data)
			outputChannel.close()
		
		#else
			
			if let fileHandle = FileHandle(forWritingAtPath: self.path){
				_ = fileHandle.seekToEndOfFile()
				fileHandle.write(data)
				fileHandle.closeFile()
			} else {
				try self.overwrite(with: data)
			}
			
		#endif
	}
	
	public func append(utf8EncodedString: String) throws {
		
		guard let utf8Data = Data.with(utf8EncodedString: utf8EncodedString) else {
			throw Data.Error.UTF8IncompatibleString
		}
		
		try self.append(data: utf8Data)
	}
	
	public func remove() throws {
		#if COOPER
			if (!self.delete()){
				throw Error.DeletionFailed
			}
		#else
			return try FileManager.default.removeItem(atPath: self.path)
		#endif
	}
	
	public var parentDirectoryº: Directory? {
		return (self.path == "/") ? nil : Directory(directoryURL: self.url.deletingLastPathComponent())
	}

	///Copies the current file to a new file or folder location
	/// - Parameters:
	///   - destination: New file location following AnyFileOrDirectory protocol
	///   - overwrites: True to overwrite or false to throw exception if the file exists at the new location
	/// - Returns: The new file location as AnyFileOrDirectory
    /// - Throws: Copying or overwriting error
	/// - Note: FileChannel copy in Java won't copy files over 2GB
	public func copy(to destination: AnyFileOrDirectory, overwrites: Bool) throws -> AnyFileOrDirectory {
		
		var destinationFile: File
		if destination.isDirectory {
			destinationFile = File(fileURL: destination.url.appendingPathComponent(self.url.lastPathComponent))
		} else {
			destinationFile = File(path: destination.path)
		}

		#if COOPER
			
			if (!destinationFile.exists){
				destinationFile.createNewFile()
			} else if !overwrites {
				throw Error.OverwriteFailed
			}
			
			let inputStream: FileInputStream = FileInputStream(self)
			let outputStream: FileOutputStream = FileOutputStream(destinationFile)
			defer {
				outputStream.close()
				inputStream.close()
			}
			
			let inputChannel = inputStream.getChannel()
			let outputChannel = outputStream.getChannel()
			
			// this can throw exception and streams should be closed by deferred funcs
			outputChannel.transferFrom(inputChannel, 0, inputChannel.size())
			
		#else
			
			if destinationFile.exists {
				if overwrites {
					try self.readData().write(to: destinationFile.url)
				} else { throw Error.OverwriteFailed }
			} else {
				try FileManager.default.copyItem(atPath: self.path, toPath: destinationFile.path)
			}
			
		#endif
		
		return destinationFile
	}

	/// Moves the current file to a new file or folder location by copying and then removing original file
	/// - Parameters:
	///   - destination: New file location following AnyFileOrDirectory protocol
	///   - overwrites: True to overwrite or false to throw exception if the file exists at the new location
	/// - Returns: The new file location as AnyFileOrDirectory
	/// - Throws: Copying, overwriting or deletion error
	/// - Note: FileChannel copy in Java won't copy files over 2GB
	public func move(to destination: AnyFileOrDirectory, overwrites: Bool) throws -> AnyFileOrDirectory {
		
		let destinationFile = try self.copy(to: destination, overwrites: overwrites)
				
		if self.exists { try self.remove() }
		
		return destinationFile
	}

}

extension File: CustomStringConvertible {
	public var description: String {
		return self.path
	}
}

extension File {
	
	public class Error {

		public static let DeletionFailed = LakestoneError.with(stringRepresentation: "File deletion failed")
		public static let OverwriteFailed = LakestoneError.with(stringRepresentation: "File already exists. You need to explicitly allow overwriting, if desired.")
	}
}

extension File: Equatable {}
public func ==(lhs: File, rhs: File) -> Bool {
	return lhs.path == rhs.path
}



