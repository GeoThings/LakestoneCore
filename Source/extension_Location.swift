//
//  extension_Location.swift
//  geoBingAnKit
//
//  Created by Taras Vozniuk on 10/25/16.
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

#if COOPER
	import android.location
#else
	import CoreLocation
#endif

extension Location {
	
	#if COOPER
	
	public var latitude: Double {
		return self.getLatitude()
	}
	
	public var longitude: Double {
		return self.getLongitude()
	}
	
	public init(latitude: Double, longitude: Double){
		let targetLocation = Location("LakestoneCore.Location")
		targetLocation.setLatitude(latitude)
		targetLocation.setLongitude(longitude)
		return targetLocation
	}
	
	#endif
	
	public func adding(meters: Double) -> Location {
	
		let earthRadius: Double = 6371 * 1000
		
		#if COOPER
			let pi = Math.PI
		#else
			let pi = Double.pi
		#endif
	
		let newLatitude = self.latitude + (meters / earthRadius) * (180.0 / pi)
	
		#if COOPER
			let newLongitude = self.longitude + (meters / earthRadius) * (180.0 / pi) / Math.cos(self.latitude * pi / 180.0)
		#else
			let newLongitude = self.longitude + (meters / earthRadius) * (180.0 / pi) / cos(self.latitude * pi / 180.0)
		#endif

		return Location(latitude: newLatitude, longitude: newLongitude)
	}
}
