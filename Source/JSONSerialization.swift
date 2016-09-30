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

public class JSONSerialization {
       
    public class Error {
        static let UnsupportedEncoding = LakestoneError.with(stringRepresentation: "Data is not UTF8 encoded. (Other encodings are not yet supported)")
        static let UnknownTokenerEntity = LakestoneError.with(stringRepresentation: "Unknown tokener entity encountered while parsing")
    }
        
    public class func jsonObject(with data: Data) throws -> Any {
        
        guard let utf8DataString = data.utf8EncodedStringRepresentationº else {
            throw Error.UnsupportedEncoding
        }
        
        let jsonEntity = try JSONTokener(utf8DataString).nextValue()
        if let jsonObject = jsonEntity as? JSONObject {
            return _serialize(object: jsonObject)
        } else if let jsonArray = jsonEntity as? JSONArray {
            return _serialize(array: jsonArray)
        } else {
            throw Error.UnknownTokenerEntity
        }
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
    
    private class func _serialize(array: JSONArray) -> [Any] {
        
        var targetArray = [Any]()
        for index in 0 ..< array.length() {
            targetArray.append(_serialize(entity: array.`get`(index)))
        }
        
        return targetArray
    }
    
    private class func _serialize(entity: Any) -> AnyObject {
        
        if let stringEntity = entity as? String {
            if let boolRepresentation = stringEntity.boolRepresentation {
                return boolRepresentation
            } else if let longRepresentation = stringEntity.longDecimalRepresentation {
                return longRepresentation
            } else if let doubleRepresentation = stringEntity.doubleRepresentation {
                return doubleRepresentation
            } else {
                return stringEntity
            }
        } else if let boolEntity = entity as? Bool {
            return boolEntity
        } else if let decimalEntity = entity as? Int32 {
            return Int64(decimalEntity)
        } else if let longEntity = entity as? Int64 {
            return longEntity
        } else if let floatEntity = entity as? Float {
            return Double(floatEntity)
        } else if let doubleEntity = entity as? Double {
            return doubleEntity
        } else if let jsonObject = entity as? JSONObject {
            return _serialize(object: jsonObject)
        } else if let jsonArray = entity as? JSONArray {
            return _serialize(array: jsonArray)
        } else {
            return entity
        }
    }
    
}

#endif
