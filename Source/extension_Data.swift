//
//  extension_Data.swift
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

#if COOPER
	import java.nio.charset
	import java.util
	import java.io
#else
	import Foundation
#endif

extension Data {
	
	public static func from(utf8EncodedString: String) -> Data? {
		#if COOPER
			return Data.wrap(utf8EncodedString.getBytes(Charset.forName("UTF-8")))
		#else
			return utf8EncodedString.data(using: String.Encoding.utf8)
		#endif
	}
	
	#if COOPER
	
	public static func from(inputStream: InputStream) throws -> Data {
		
		let readBatchSize = 16384
		let outputStream = ByteArrayOutputStream()
		
		let bytes = java.lang.reflect.Array.newInstance(Byte.self, readBatchSize) as! ByteStaticArray
		var nRead: Int
		while ( (nRead = inputStream.read(bytes, 0, readBatchSize)) != -1){
			outputStream.write(bytes, 0, nRead)
		}
		
		let completeData = Data.wrap(outputStream.toByteArray())
		inputStream.close()
		outputStream.close()
		
		return completeData			   
	}
	
	public var plainBytes: SByteStaticArray {
	
		//apple swift doesn't allow Type[] syntax
		var bytes: SByteStaticArray
		if self.hasArray() {
			bytes = self.array()
		} else {
			bytes = java.lang.reflect.Array.newInstance(SByte.self, self.remaining()) as! SByteStaticArray
			self.`get`(bytes as! SByteStaticArray)
		}
	
		return bytes as! SByteStaticArray
	}
	
	#endif
	
	public var bytes: [Int8] {
		
		#if COOPER
		
			let targetArrayList = ArrayList<SByte>()
			for index in 0 ..< self.plainBytes.length {
				targetArrayList.add(self.plainBytes[index])
			}
		
			//Collections.addAll(targetArrayList, self.plainBytes)
			
			return targetArrayList
			
		#else
			
			return self.withUnsafeBytes {
				[Int8](UnsafeBufferPointer(start: $0, count: self.count))
			}
		
		#endif
	}
	
	
	public var utf8EncodedStringRepresentation: String? {
		
		#if COOPER

			return java.lang.String(self.plainBytes, Charset.forName("UTF-8"))
			
		#else
			
			return String(data: self, encoding: String.Encoding.utf8)
			
		#endif
		
	}
	
	public var littleEndianLongRepresentation: Int64? {
		
		#if COOPER
			
			if (self.capacity() == 8){
				
				let preservedOrder = self.order()
				
				self.order(java.nio.ByteOrder.LITTLE_ENDIAN)
				let targetLongValue = self.getLong()
				//restore original order
				self.order(preservedOrder)
				
				return targetLongValue
				
			} else {
				return nil
			}
			
		#else
			
			if self.count == 8 {
				var longValue: Int64 = 0
				_ = self.copyBytes(to: UnsafeMutableBufferPointer(start: &longValue, count: 1))
				return longValue
			} else {
				return nil
			}
			
		#endif
	}

}
