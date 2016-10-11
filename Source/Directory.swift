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
	
	public init(fileURL: URL){
		#if COOPER
			_fileEntity = File(fileURL: fileURL)
		#else
			self.path = fileURL.path
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
	
	public var name: String {
		#if COOPER
			return _fileEntity.getName()
		#else
			return URL(fileURLWithPath: self.path).lastPathComponent
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
	
	public func create() throws {
		#if COOPER
			if (!_fileEntity.mkdir()){
				throw Error.DeletionFailed
			}
		#else
			return try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: false, attributes: nil)
		#endif
	}
	
	public func createSubdirectory(named: String) throws -> Directory {
		let subdirectory = Directory(fileURL: URL(fileURLWithPath: self.path).appendingPathComponent(named))
		try subdirectory.create()
		return subdirectory
	}
	
	public var filesAndSubdirectories: [AnyFileOrDirectory] {
		
		#if COOPER
			let names = [String](_fileEntity.list())
		#else
			guard let names = try? FileManager.default.contentsOfDirectory(atPath: self.path) else {
				return []
			}
		#endif
		
		return [AnyFileOrDirectory](names.map { URL(fileURLWithPath: self.path).appendingPathComponent($0) } .map { FileOrDirectory(with: $0) })
	}
	
	public var files: [File] {
		return [File](self.filesAndSubdirectories.filter { !$0.isDirectory }.map { File(path: $0.path) })
	}
	
	public var subdirectories: [Directory] {
		return [Directory](self.filesAndSubdirectories.filter { $0.isDirectory }.map { Directory(path: $0.path) })
	}
	
	
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
	
	public func remove(completionHandler: @escaping (ThrowableError?) -> Void){
		
		let deletionQueue = Threading.serialQueue(withLabel: "lakestone.core.file-deletion-queue")
		deletionQueue.dispatch {
			do {
				try self.remove()
				completionHandler(nil)
			} catch {
				// in Java silver error has Object type, so conditionals to avoid warning for redundant as! in Swift
				#if COOPER
					completionHandler(error as! Error)
				#else
					completionHandler(error)
				#endif
			}
		}
	}
    
    public var parentDirectoryº: Directory? {
        return (self.path == "/") ? nil : Directory(fileURL: URL(fileURLWithPath: self.path).deletingLastPathComponent())
    }
    
    public func copy(to destinationPath: AnyFileOrDirectory, overwrites: Bool) throws {
        
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
		static let DeletionFailed = LakestoneError.with(stringRepresentation: "Directory deletion failed")
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
