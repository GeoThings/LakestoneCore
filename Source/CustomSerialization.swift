//
//  CustomSerialization.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 10/2/16.
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

public protocol CustomSerializable {
    init()
    init(variableMap: [String: Any]) throws
}

#if COOPER
    public typealias CustomSerializableType = Class
    private typealias ReflectableField = java.lang.reflect.Field
#else
    public typealias CustomSerializableType = CustomSerializable.Type
    private typealias ReflectableField = Mirror.Child
#endif

public class CustomSerialization {
    
    public class func applyCustomSerialization(ofCustomTypes customTypes: [CustomSerializableType], to serializedObject: Any) throws -> Any {
        
        #if COOPER
        
            let customSerializableTypes = [Class](customTypes.filter { CustomSerializable.self.isAssignableFrom($0) })
            var variableMap = [(CustomSerializableType, [ReflectableField])]()
            for SomeType in customSerializableTypes {
                variableMap.append(
                    (SomeType, [ReflectableField](SomeType.getDeclaredFields()))
                )
            }
            
        #else
        
            let variableMap = customTypes.map { (SomeType: CustomSerializableType) in
                (SomeType, Mirror(reflecting: SomeType.init()).children.map { $0 })
            }
        
        #endif
        
        return try _serialize(object: serializedObject, withCustomVariableMap: variableMap)
    }
    
    private class func _serialize(object: Any, withCustomVariableMap variableMap: [(CustomSerializableType, [ReflectableField])]) throws -> Any {
        
        if let dictionaryEntity = object as? [String: Any]{
            
            var targetDictionaryEntity = [String: Any]()
            for (key, value) in dictionaryEntity {
                targetDictionaryEntity[key] = try _serialize(object: value, withCustomVariableMap: variableMap)
            }
            
            return try _attemptSerilization(forDictionary: targetDictionaryEntity, withCustomVariableMap: variableMap)
            
        } else if let arrayEntity = object as? [Any] {
            
            var targetArrayEntity = [Any]()
            for value in arrayEntity {
                targetArrayEntity.append(try _serialize(object: value, withCustomVariableMap: variableMap))
            }
            
            // I cannot create the array with parameteric generic type not inffered on compile-time
            // I suspect it is not possible in pure Swift-runtime at this moment
            
            return targetArrayEntity
            
        } else {
            return object
        }
    }

    private class func _attemptSerilization(forDictionary dictionaryEntity: [String: Any],
                                            withCustomVariableMap variableMap: [(CustomSerializableType, [ReflectableField])]) throws -> Any {
        
        let keysSet = Set<String>([String](dictionaryEntity.keys))
        
        // found CustomSerializable instance that matches the dictionary entity
        var targetCandidateº: (CustomSerializableType, [ReflectableField])? = nil
        
        // the #entries difference between dictionary keys and class variables
        var targetDifference = Int.max
        
        // the final variable map that will be used to initialize CustomSerializable instance
        var targetValueMap = [String: Any]()
        
        for (SomeType, fields) in variableMap {
            
            #if COOPER
            
                let fieldNameWithRemovedPrivatePrefix: (ReflectableField) -> String = { (field: ReflectableField) in
                    let fieldName = field.getName()
                    if let privatePrefixRange = fieldName.range(of: "$p_"){
                        return fieldName.replacingCharacters(in: privatePrefixRange, with: String())
                    } else {
                        return fieldName
                    }
                }
            
                let variableNamesSet = Set<String>([String](fields.map(fieldNameWithRemovedPrivatePrefix)))
                
                var typesMap = [String: Class]()
                for field in fields {
                    typesMap[fieldNameWithRemovedPrivatePrefix(field)] = field.getType()
                }
            #else
                let variableNamesSet = Set<String>(fields.flatMap { $0.label })
                var typesMap = [String: Any]()
                for field in (fields.filter { $0.label != nil }) {
                    typesMap[field.label!] = field.value
                }
            #endif
            
            // dictionary entity doesn't contain all CustomSerializable type fields
            if !variableNamesSet.subtracting(keysSet).isEmpty {
                continue
            }
            
            let difference = keysSet.subtracting(variableNamesSet)
            if difference.count >= targetDifference {
                // the dictionary representation doesn't match closer then the current candidate
                // skip it
                continue
            }
            
            // check if variable types match dictionary entries types
            var typesMatch: Bool = true
            var candidateValueMap = [String: Any]()
            for commonKey in keysSet.union(variableNamesSet) {
                
                #if COOPER
                    
                    if let ExpectedType = typesMap[commonKey],
                       let dictionaryEntry = dictionaryEntity[commonKey],
                       ExpectedType.isAssignableFrom(dictionaryEntry.getClass()) {
                        
                        //dictionary entry matches the class field in type
                        candidateValueMap[commonKey] = dictionaryEntry
                    
                    // clause for a primitive type comparison.
                    // (First clause will fail in cases like < ExpectedType: double, dictionaryEntry.getClass(): java.lang.Double >)
                    } else if let ExpectedType = typesMap[commonKey],
                           let dictionaryEntry = dictionaryEntity[commonKey],
                           let mappedPrimitiveType = self.primitiveTypeMap["\(dictionaryEntry.getClass())"],
                           ExpectedType.isAssignableFrom(mappedPrimitiveType) {
                        
                        //dictionary entry matches the class field in type
                        candidateValueMap[commonKey] = dictionaryEntry
                        
                    } else {
                        typesMatch = false
                        break
                    }
                    
                #else
                    
                    if let expectedEntry = typesMap[commonKey],
                        let dictionaryEntry = dictionaryEntity[commonKey],
                        type(of: expectedEntry) == type(of: dictionaryEntry) {
                        
                        //dictionary entry matches the class field in type
                        candidateValueMap[commonKey] = dictionaryEntry
                        
                    } else if let dictionaryEntry = dictionaryEntity[commonKey],
                        type(of: dictionaryEntry) == [Any].self {
                        
                        // ignore the exact array type check
                        // all dictionary entities will come in [Any], which cannot be changed to [ExactType] on runtime
                        
                        candidateValueMap[commonKey] = dictionaryEntry
                        
                    } else {
                        typesMatch = false
                        break
                    }
                    
                #endif
            }
            
            if typesMatch {
                targetCandidateº = (SomeType, fields)
                targetDifference = difference.count
                targetValueMap = candidateValueMap
                
                // the dictionary maps 1-to-1 to CustomSerializable type
                // consider match found
                if difference.isEmpty {
                    break
                }
            }
        }
        
        if let targetCandidate = targetCandidateº {
            let (SomeType, _) = targetCandidate
            
            #if COOPER
            
                if let constructor = SomeType.getDeclaredConstructor(java.util.HashMap<String, Object>.self){
                    return constructor.newInstance(targetValueMap)
                } else {
                    return dictionaryEntity
                }
                
            #else
                return try SomeType.init(variableMap: targetValueMap)
            #endif
            
        } else {
            return dictionaryEntity
        }
    }
    
    #if COOPER
    
    // string-binded workaround for JAVA primitive types.
    // In silver .self and .TYPE will both yield the primitive, not the wrapped type
    private class var primitiveTypeMap: [String: java.lang.Class] {
        
        return ["class java.lang.Integer": java.lang.Integer.self,
                "class java.lang.Long": java.lang.Long.self,
                "class java.lang.Double": java.lang.Double.self,
                "class java.lang.Float": java.lang.Float.self,
                "class java.lang.Boolean": java.lang.Boolean.self,
                "class java.lang.Character": java.lang.Character.self,
                "class java.lang.Byte": java.lang.Byte.self,
                "class java.lang.Void": java.lang.Void.self,
                "class java.lang.Short": java.lang.Short.self]
    }
    
    #endif
}
