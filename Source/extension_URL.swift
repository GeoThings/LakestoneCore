//
//  extension_URL.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/21/16.
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

extension URL {
	
	#if COOPER
	/// in Java nil will be returned if the URL doesn't have a valid URL format
	/// with a valid known protocol, in Foundation.URL however only strings with
	//  URL-invalid characters will result in nil returned
	public init?(string: String) {
		
		var initedSelf: URL
		do {
			initedSelf = try self.init(string)
		} catch {
			return nil
		}
		
		return initedSelf
	}
	
	public init(fileURLWithPath path: String){
		self.init("file://" + path) 
	}
	
	public var absoluteString: String {
		return self.toString()
	}
	
	public var isFileURL: Bool {
		return self.getProtocol() == "file"
	}
	
	public var path: String {
		// Foundation.URL removes trailing '/'
		return (self.getPath() != "/" && self.getPath().hasSuffix("/")) ? self.getPath().substring(to: self.getPath().index(before: self.getPath().endIndex)) : self.getPath()
	}
	
	public var pathComponents: [String] {
		if self.path == "/" || self.path.isEmpty {
			return [self.path]
		} else {
			return [String](self.path.components(separatedBy: "/").map { ($0.isEmpty) ? "/" : $0 })
		}
	}
	
	public var lastPathComponent: String {
		return self.pathComponents.last ?? String()
	}

	public var pathExtension: String {
		guard let extensionSeperatorRange = self.lastPathComponent.range(of: ".", searchBackwards: true) else {
			return String()
		}
	
		return self.lastPathComponent.substring(from: self.lastPathComponent.index(after: extensionSeperatorRange.lowerBound))
	}
	
	/// remark: logic defers from Foundation's conterpart
	///		 available at https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSURL.swift#L762
	public func appendingPathComponent(_ str: String, isDirectory: Bool = false) -> URL {
	
		let componentPart = (isDirectory) ? str + "/" : str
		if self.absoluteString.hasSuffix("/"){
			return self.init?(string: self + componentPart)
		} else {
			return self.init?(string: self + "/" + componentPart)
		}
	}
	
	public func deletingLastPathComponent() -> URL {
	
		guard let prelastComponentStart = self.path.range(of: "/", searchBackwards: true) else {
			return self
		}
	
		return URL(fileURLWithPath: self.path.substring(to: prelastComponentStart.lowerBound))
	}
	
	//TODO: Resolve a relative URL into absolute in Java
	
	/// - warning: in JAVA doesn't resolve the relative URL into absolute
	///			Available now only for compatibility
	public var absoluteURL: URL {
		return self
	}

	#endif
	
}

extension URL: StringRepresentable {
    public var stringRepresentation: String {
        return self.absoluteString
    }
}
