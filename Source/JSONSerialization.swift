//
//  JSONSerialization.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/30/16.
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
	import org.json
#else
	import Foundation
#endif


#if COOPER

public class JSONSerialization {
	   
	public class Error {
		static let UnsupportedEncoding = LakestoneError.with(stringRepresentation: "Data is not UTF8 encoded. (Other encodings are not yet supported)")
		static let UnknownTokenerEntity = LakestoneError.with(stringRepresentation: "Unknown tokener entity encountered while parsing")
		static let NonUTF8CompatibleString = LakestoneError.with(stringRepresentation: "String cannot be represent as UTF8 encoded data")
		static let ObjectIsNotSerializable = LakestoneError.with(stringRepresentation: "Object is not serializable")
	}
		
	public class func jsonObject(with data: Data) throws -> Any {
		
		guard let utf8DataString = data.utf8EncodedStringRepresentationº else {
			throw Error.UnsupportedEncoding
		}
		
		let jsonEntity = JSONTokener(utf8DataString).nextValue()
		if let jsonObject = jsonEntity as? JSONObject {
			return _serialize(object: jsonObject)
		} else if let jsonArray = jsonEntity as? JSONArray {
			return _serialize(array: jsonArray)
		} else {
			throw Error.UnknownTokenerEntity
		}
	}
	
    public class func string(withJSONObject jsonObject: Any) throws -> String {
        
        let jsonString: String
        if let dictionaryEntity = jsonObject as? [String: Any] {
            let targetJSONObject = _deserialize(dictionary: dictionaryEntity)
            jsonString = targetJSONObject.toString()
            
        } else if let arrayEntity = jsonObject as? [Any] {
            let targetJSONArray = _deserialize(array: arrayEntity)
            jsonString = targetJSONArray.toString()
        } else {
            throw Error.ObjectIsNotSerializable
        }
        
        return jsonString
    }
    
	public class func data(withJSONObject jsonObject: Any) throws -> Data {
		
        let jsonString = try JSONSerialization.string(withJSONObject: jsonObject)
		guard let jsonData = Data.with(utf8EncodedString: jsonString) else {
			throw Error.NonUTF8CompatibleString
		}
			
		return jsonData
	}
		
	private class func _serialize(object: JSONObject) -> [String: Any] {
		
		let keysIterator = object.keys()
		
		var targetDictionary = [String: Any]()
		while (keysIterator.hasNext()){
			 let entityKey = keysIterator.next()
			 targetDictionary[entityKey] = _serialize(entity: object.`get`(entityKey))
		}
		
		return targetDictionary
	}
	
	private class func _deserialize(dictionary: [String: Any]) -> JSONObject {
		
		var targetJSONObject = JSONObject()
		for (key, value) in dictionary {
			targetJSONObject.put(key, _deserialize(entity: value))
		}
		
		return targetJSONObject
	}
	
	private class func _serialize(array: JSONArray) -> [Any] {
		
		var targetArray = [Any]()
		for index in 0 ..< array.length() {
			targetArray.append(_serialize(entity: array.`get`(index)))
		}
		
		return targetArray
	}
	
	private class func _deserialize(array: [Any]) -> JSONArray {
		
		var targetJSONArray = JSONArray()
		for entity in array {
			targetJSONArray.put(_deserialize(entity: entity))
		}
		
		return targetJSONArray
	}
	
	private class func _serialize(entity: Any) -> AnyObject {
		
		if let stringEntity = entity as? String {
			/*
			if let boolRepresentation = stringEntity.boolRepresentation {
				return boolRepresentation
			} else if let longRepresentation = stringEntity.longDecimalRepresentation {
				return longRepresentation
			} else if let doubleRepresentation = stringEntity.doubleRepresentation {
				return doubleRepresentation
			} else {
				return stringEntity
			}*/
			return stringEntity
			
		} else if let decimalEntity = entity as? Int32 {
			return Int64(decimalEntity)
		} else if let floatEntity = entity as? Float {
			return Double(floatEntity)
		} else if let jsonObject = entity as? JSONObject {
			return _serialize(object: jsonObject)
		} else if let jsonArray = entity as? JSONArray {
			return _serialize(array: jsonArray)
		} else {
			return entity
		}
	}
	
	private class func _deserialize(entity: Any) -> Any {
		
		if let dictionaryEntity = entity as? [String:Any] {
			return _deserialize(dictionary: dictionaryEntity)
		} else if let arrayEntity = entity as? [Any] {
			return _deserialize(array: arrayEntity)
		} else {
			return entity
		}
	}
}

#else

extension JSONSerialization {
    
    public class func string(withJSONObject jsonObject: Any) throws -> String {
     
        guard let jsonString = try JSONSerialization.data(withJSONObject: jsonObject).utf8EncodedStringRepresentationº else {
            throw Data.Error.UTF8IncompatibleString
        }
        
        return jsonString
    }
    
}
    
#endif
