//
//  alliases.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/20/16.
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
//  Set of common types alliases.
//  Platform-independent types are achieved by alliasing platform-specific types
//  to the same name and then providing the extension to this alliased type
//
//  Since you extend the allias type, each platform-specific type will get extended
//  The extension will the provide each platform specific implementation for a given common interface
//  Before new NS-errased Foundation framework shipped with Swift 3.0, 
//  example abstraction of ByteBuffer and NSData will look the following way:
//
//	  #if COOPER
//		  public typealias Data = java.nio.ByteBuffer
//	  #else
//		  public typealias Data = NSData
//	  #endif
//
//	  extension Data {
//
//		  public static func from(utf8EncodedString: String) -> Data? {
//			  #if COOPER
//				  return Data.wrap(utf8EncodedString.getBytes(Charset.forName("UTF-8")))
//			  #else
//				  return utf8EncodedString.data(using: String.Encoding.utf8)
//			  #endif
//		  }
//	  }
//
//  Data type and its method `from(utfEncodedString:)` is now platform-errased.
//  Implementing unified interfaces on existing allised types is recommended way
//  to abstract away platform specifics if sementically corresponding types exist on each platform
//
//  That is both java.util.Date and NSDate are sementically correspondant.
//
//  However java.io.File doesn't have a sementically correspondent type in Cocoa.
//  therefore alliasing String(which is how files are identified in cocoa with their pathes)
//  is NOT the best idea.
//
//  Instead consider using two approaches in this situation:
//
//	  1. Provide the wrapper type that provides corresponding interfaces to other platforms corresponded type
//	  2. Implement corresponding type on the missing platform.
//
//  Method 1 is often prefered and differs from 2 in the way that existing API implementations is reused
//  instead of being written from ground up. The next example illustates this:
//
//	  #if COOPER
//		  public typealias File = java.io.File
//
//	  #else
//
//		  public class File {
//			  let path: String
//
//			  init(filepath: String){
//				  self.path = filepath
//			  }
//		  }
//
//	  #endif
//
//	  extension File {
//		  #if COOPER
//
//		  init(filepath: String){
//			  self(filepath)
//		  }
//
//		  #endif
//
//		  public func remove() throws {
//             #if COOPER
//                  if (!self.delete()){
//                      throw Error.DeletionFailed
//                  }
//             #else
//                  return try FileManager.default.removeItem(atPath: self.path)
//             #endif
//        }
//	  }
//
//  Preceeding File implementation is container type for the file path
//  and it wraps up existing FileManager APIs to do the file related operations.
//
//
//  You need to be extremely careful with what is considered to be semantically correspondent.
//  The first example demonstated alliasing ByfeBuffer and Foundation.Data to the same type,
//  however they have important semantic difference:
//  ByteBuffer has a stream-related semantics such that IO-related operations are relative to
//  current ByteBuffer position (byte offset), while Foundation.Data has not.
//  Failure to account for such a semantic difference can lead to unexpected buggy behaviour on
//  specific platform.
//
//  Also same set of APIs can have signification platform-specific behaviour differences.
//  Example of such include MapboxSDK, Realm. So be extremely caution and careful when abstracting
//  these. Avoid abstractions that result in essentially different internal state if possible.
//

#if !COOPER
	
	import Foundation
	#if os(iOS) || os(watchOS) || os(tvOS)
		import UIKit
	#else
		
	#endif
	
#endif

#if COOPER

	public typealias URL = java.net.URL
	public typealias Data = java.nio.ByteBuffer
	public typealias Date = java.util.Date
	public typealias UUID = java.util.UUID
	public typealias File = java.io.File
	public typealias Error = java.lang.Throwable
    
    public typealias AnyHashable = java.lang.Object
    
	
#else

	
	
#endif
