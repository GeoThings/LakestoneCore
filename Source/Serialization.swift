//
//  Serialization.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 5/31/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
    import java.io
    import java.util
    import com.esotericsoftware.kryo
    import com.esotericsoftware.kryo.io
    
#else
    import Foundation
    
#endif

public class Serialization {
	
	#if COOPER
    
	public class func deserialize<T>(objectOfType type: Class<T>, fromFile file: File) throws -> T {
		
		let input = try Input(FileInputStream(file))
		let serializer = Kryo()
		let entity = try serializer.readObject(input, type)
		input.close()
		
		return entity
	}
	
	public class func serialize(object: Object, intoFile file: File) throws {
		
		let outputFileStream = FileOutputStream(file)
		let output = Output(outputFileStream)
		let serializer = Kryo()
		serializer.writeObject(output, object)
		output.close()					
	}
    
	#endif
	
	public class func jsonObject(fromData data: Data) throws -> JSONObject {
		
		#if COOPER
            
            guard let utf8DataString = data.toUTF8EncodedString() else {
                throw Exception("Data cannot be presented as UTF8 String")
            }
            
            return try JSONObject(utf8DataString)
            
		#else
            
            return try JSONSerialization.jsonObject(with: data, options: [])
            
		#endif
	}
	
	public class func jsonArray(fromData data: Data) throws -> [JSONObject] {
		
		#if COOPER
		
            guard let utf8DataString = data.toUTF8EncodedString() else {
                throw Exception("Data cannot be presented as UTF8 String")
            }
            
            var targetArray = [JSONObject]()
            
            let jsonArray = try org.json.JSONArray(utf8DataString)
            for i in 0 ..< jsonArray.length() {
                guard let object = jsonArray.optJSONObject(i) else { continue }
                targetArray.append(object)
            }
            
            return targetArray
		
		#else
		
            guard let targetArray = try JSONSerialization.jsonObject(with: data, options: []) as? [JSONObject] else {
                throw ErrorBuilder.from(errorDescription: "GeneralConversionError")
            }
            
            return targetArray
		
		#endif
	}
	
	public class func jsonObject(fromFile file: File) throws -> JSONObject {
	
		#if COOPER
		
            let inputStream = FileInputStream(file)
            var bytes = java.lang.reflect.Array.newInstance(SByte.Type, file.length()) as! SByteStaticArray
            try inputStream.read(bytes)
            try inputStream.close()
            return Self.jsonObject(fromData: Data.wrap(bytes))
            
		#else
		
            guard let fileData = Foundation.FileManager.default.contents(atPath: file) else {
                throw ErrorBuilder.from(errorDescription: "No Such File")
            }
            
            return try JSONSerialization.jsonObject(with: fileData, options: [])
            
		#endif
	}
	
	public class func jsonObjectValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> JSONObject? {
		#if COOPER
            return jsonObject.optJSONObject(key)
		#else
            return (jsonObject as? [String: AnyObject])?[key]
		#endif
	}
	
	public class func intArrayValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> [Int]? {
		
		#if COOPER
            
            let targetIntArray = [Int]()
            
            guard let jsonArray = jsonObject.optJSONArray(key) else { return nil }
            for i in 0 ..< jsonArray.length() {
                guard let intValue = jsonArray.optInt(i) else { continue }
                targetIntArray.append(intValue)
            }
            
            return targetIntArray
            
		#else
            return (jsonObject as? [String: AnyObject])?[key] as? [Int]
            
		#endif
	}
	
	public class func longArrayValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> [Int64]? {
		
		#if COOPER
            
            let targetLongArray = [Int64]()
            
            guard let jsonArray = jsonObject.optJSONArray(key) else { return nil }
            for i in 0 ..< jsonArray.length() {
                guard let longValue = jsonArray.optLong(i) else { continue }
                targetLongArray.append(longValue)
            }
            
            return targetLongArray
            
		#else
        
            var targetNumericalArray = [Int64]()
            if let nsCollection = (jsonObject as? [String: AnyObject])?[key] as? [NSNumber] {
                for number in nsCollection {
                    targetNumericalArray.append(number.int64Value)
                }
            } else {
                return nil
            }
            
            return targetNumericalArray
            
        #endif
	}
	
	public class func arrayValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> [JSONObject]? {
		
		#if COOPER
            
            let targetJSONObjects = [JSONObject]()
            
            guard let jsonArray = jsonObject.optJSONArray(key) else { return nil }
            for i in 0 ..< jsonArray.length() {
                guard let jsonObject = jsonArray.optJSONObject(i) else { continue }
                targetJSONObjects.append(jsonObject)
            }
            
            return targetJSONObjects
            
		#else
		
            return (jsonObject as? [String: AnyObject])?[key] as? [JSONObject]
			
		#endif
	}
	
	public class func stringValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> String? {
		
		#if COOPER
            return jsonObject.optString(key)
		#else
            return (jsonObject as? [String: AnyObject])?[key] as? String
		#endif
	}
	
	public class func boolValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> Bool? {
		
		#if COOPER
            return jsonObject.optBoolean(key)
		#else
            return (jsonObject as? [String: AnyObject])?[key] as? Bool
		#endif
	}
	
	public class func intValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> Int? {
		
		#if COOPER
            return jsonObject.optInt(key)
		#else
            return (jsonObject as? [String: AnyObject])?[key] as? Int
		#endif
	}
	
	public class func longValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> Int64? {
		
        #if COOPER
            return jsonObject.optLong(key)
		#else
            return ((jsonObject as? [String: AnyObject])?[key] as? NSNumber)?.int64Value
		#endif
	}
	
	public class func doubleValue(forKey key: String, fromJSONObject jsonObject: JSONObject) -> Double? {
		
		#if COOPER
            return jsonObject.optDouble(key)
		#else
            return (jsonObject as? [String: AnyObject])?[key] as? Double
		#endif
	}
	
	public class func allEntities(fromJSONObject jsonObject: JSONObject) -> [String: AnyObject] {
		
		#if COOPER
	 
		let keysIterator = jsonObject.keys()
		let keysList = [String]() 
		while (keysIterator.hasNext()){
			keysList.append(keysIterator.next())
		}
		
		var entityDict = [String: AnyObject]()
		for key in keysList {
			entityDict[key] = jsonObject.opt(key)
		}
		
		return entityDict
		
		#else
		
		if let jsonEntity = jsonObject as? [String: AnyObject] {
			return jsonEntity
		} else {
			return [String: AnyObject]()
		}
		
		#endif
	}	
	
	public class func longValue(fromFile file: File) -> Int64? {
		
		#if COOPER
		
            if (file.length() != 8) {
                return nil
            }
            
            guard let fileInputStream = try? FileInputStream(file) else {
                return nil
            }
            
            var bytes = java.lang.reflect.Array.newInstance(SByte.Type, file.length()) as! SByteStaticArray
            fileInputStream.read(bytes)
            let data = Data.wrap(bytes)
            
            return data.toLittleEndianLong()
            
		#else
		
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
                return nil
            }
            
            return data.toLittleEndianLong()
            
		#endif
	}
	
	public class func data(fromLong longValue: Int64) -> Data {
		
		#if COOPER
			
            let data = Data.allocate(8)
            data.order(java.nio.ByteOrder.LITTLE_ENDIAN)
            data.putLong(longValue)
            return data
            
		#else
		
            var mutableLongValue = longValue
            let mutableLongBufferPtr = UnsafeMutableBufferPointer(start: &mutableLongValue, count: 1)
            return Data(buffer: mutableLongBufferPtr)
            
		#endif
	}
}

