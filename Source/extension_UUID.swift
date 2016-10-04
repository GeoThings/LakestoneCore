//
//  extension_UUID.swift
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

#if !COOPER
	import Foundation
#endif

extension UUID {
	
	#if COOPER
	
	public init(){
		return UUID.randomUUID()
	}
	
	public init?(uuidString: String){
		return UUID.fromString(uuidString)
	}
	
	public var uuidString: String {
		return self.toString()
	}
	
	#endif
}

#if COOPER

extension UUID: Equatable {
	public override func equals(_ o: Object!) -> Bool {
		
		guard let other = o as? Self else {
			return false
		}
		
		return (self == other)
	}
}
	
public func ==(lhs: UUID, rhs: UUID) -> Bool {
	return (lhs.compareTo(rhs) == 0)
}
	
#endif
