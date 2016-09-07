//
//  FileManager.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 6/2/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
    import android.os
    import android.content
    import java.io
    import java.nio
#else
    import Foundation
#endif

public class FileManager {
	
	#if COOPER
	private let _applicationContext: Context
	public init(applicationContext: Context){
		_applicationContext = applicationContext
	}
	#else
	public init(){}
	#endif
	
	public class func availableInternalStorageBytes() -> UInt64? {
		
		#if !COOPER
            
            guard let attributes = try? Foundation.FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            else {
                return nil
            }
		
            
            guard let freeSize = (attributes[.systemFreeSize] as AnyObject?)?.uint64Value else {
                return nil
            }
		
            //this will return around 200Mb more that is displayed in Settings, since I think iOS reserves around 200mb for internal use
            return freeSize
		
		#else
		
            let dataDirectory = Environment.getDataDirectory()
            let fileSystemStat = StatFs(dataDirectory.getPath())
            return UInt64(fileSystemStat.getAvailableBlocksLong() * fileSystemStat.getBlockSizeLong())
		
		#endif
	}
	
	public func doesFileExist(_ file: File) -> Bool {
		#if COOPER
            return file.exists()
		#else
            return Foundation.FileManager.default.fileExists(atPath: file)
		#endif
	}
	
	public func internalStorageDirectory(withName name:String) -> File? {
		
		#if COOPER
            let internalDirectory = _applicationContext.getFilesDir()
            return self.subdirectory(withName: name, forDirectory: internalDirectory)
			
		#else
            
            let documentsSearchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            guard let documentDirectoryPath = documentsSearchPaths.first else {
                return nil
            }
            return self.subdirectory(withName: name, forDirectory: documentDirectoryPath)
            
		#endif
	}
	
	public func internalStorageCacheDirectory() -> File? {
        
		#if COOPER
            return _applicationContext.getCacheDir()
			
		#else
            
            let cacheSearchPaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            guard let cacheDirectoryPath = cacheSearchPaths.first else {
                return nil
            }
            
            var isDirectoryPath: ObjCBool = ObjCBool(false)
            if !Foundation.FileManager.default.fileExists(atPath: cacheDirectoryPath, isDirectory: &isDirectoryPath) && isDirectoryPath.boolValue == false {
                if (try? Foundation.FileManager.default.createDirectory(atPath: cacheDirectoryPath, withIntermediateDirectories: false, attributes: nil)) == nil {
                    return nil
                }
            }
			
            return cacheDirectoryPath
            
		#endif
	}
	
	public func internalStorageCacheSubdirectory(withName name: String) -> File? {
		
		guard let cacheDirectory = self.internalStorageCacheDirectory() else {
			return nil
		}
	
		return self.subdirectory(withName: name, forDirectory: cacheDirectory)
	}
	
	public func subdirectory(withName name: String, forDirectory directory: File) -> File? {
		
		#if COOPER
		
		let targetSubdirectory = File("\(directory.getAbsolutePath())/\(name)")
		
		var didCreateSuccesfully: Bool = true
		if !targetSubdirectory.exists() {
			didCreateSuccesfully = targetSubdirectory.mkdir()
		}
			
		return (didCreateSuccesfully) ? targetSubdirectory : nil
			
		#else
			
		let targetSubdirectoryPath = (directory as NSString).appendingPathComponent(name)
			
		var isDirectoryPath: ObjCBool = ObjCBool(false)
		if !Foundation.FileManager.default.fileExists(atPath: targetSubdirectoryPath, isDirectory: &isDirectoryPath) && isDirectoryPath.boolValue == false {
			if (try? Foundation.FileManager.default.createDirectory(atPath: targetSubdirectoryPath, withIntermediateDirectories: false, attributes: nil)) != nil {
				return targetSubdirectoryPath
			} else {
				return nil
			}
		} else {
			return (isDirectoryPath.boolValue) ? targetSubdirectoryPath : nil
		}

		#endif
	}
	
	public func createCacheFile(withData data: Data, filename: String, inDirectory directory: File) throws -> File {
		
		#if COOPER
		
            let cacheFile = try File.createTempFile(filename, nil, directory)
            let outputFileChannel = try FileOutputStream(cacheFile, false).getChannel()
            
            data.position(0)
            try outputFileChannel.write(data)
            try outputFileChannel.close()
            
            return cacheFile
            
            
		#else
		
            let filepath = (directory as NSString).appendingPathComponent(filename)
            try data.write(to: URL(fileURLWithPath: filepath), options: .atomic)
            return filepath
            
		#endif
	}
	
	public func createCacheFile(withName filename: String, inDirectory directory: File) throws -> File {  
		#if COOPER
            return try File.createTempFile(filename, nil, directory)
		#else
            return (directory as NSString).appendingPathComponent(filename)
		#endif
	}
	
	public func copyFile(fromSource sourceFile: File, toDestination destinationFile: File) throws {
		
		#if COOPER
            if (!destinationFile.exists()){
                destinationFile.createNewFile()
            }
            
            let inputChannel = try FileInputStream(sourceFile).getChannel()
            let outputChannel = try FileOutputStream(destinationFile).getChannel()
            try outputChannel.transferFrom(inputChannel, 0, inputChannel.size())
            
		#else
		
            try Foundation.FileManager.default.copyItem(atPath: sourceFile, toPath: destinationFile)
		
		#endif
	}
	
	public func allFiles(forDirectory directory: File) -> [File] {
		
		#if COOPER
		
            var files = [File]()
            if directory.isDirectory(){
                for file in directory.listFiles() {
                    files.append(file)
                }
                return files
                
            } else {
                return []
            }
            
		#else
		
		var isDirectoryPath: ObjCBool = ObjCBool(false)
        if Foundation.FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectoryPath) && isDirectoryPath.boolValue == true {
			
            guard let directoryContent = try? Foundation.FileManager.default.contentsOfDirectory(atPath: directory) else {
				return []
			}
			return directoryContent.map { (directory as NSString).appendingPathComponent($0) }
			
		} else {
			return []
		}
		
		#endif
	}
	
	public func allFiles(forDirectory directory: File, whoseNameContain string: String) -> [File] {
		
		var matchingFiles = [File]()
		for file in self.allFiles(forDirectory: directory){
			#if COOPER
                
                if file.getName().contains(string){
                    matchingFiles.append(file)
                }
                
			#else
                
                if (file as NSString).lastPathComponent.contains(string){
                    matchingFiles.append(file)
                }
                
			#endif
		}
		
		return matchingFiles
	}
}
