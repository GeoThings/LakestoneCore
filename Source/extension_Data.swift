//
//  extension_Data.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/21/16.
//
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
		
		let bytes = java.lang.reflect.Array.newInstance(Byte.Type, readBatchSize) as! ByteStaticArray 
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
			bytes = java.lang.reflect.Array.newInstance(SByte.Type, self.remaining()) as! SByteStaticArray
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
			
			return [Int8](targetArrayList)
			
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
