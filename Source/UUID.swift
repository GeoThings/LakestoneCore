//
//  UUID.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 8/4/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if !COOPER
    import Foundation
#endif

public class UUID {
    
    #if !COOPER
    let _internalEntity: Foundation.UUID
    #else
    let _internalEntity: java.util.UUID
    #endif
    
    public init(){
        #if !COOPER
        _internalEntity = Foundation.UUID()
        #else
        _internalEntity = java.util.UUID.randomUUID()
        #endif
    }
    
    public init(string: String){
        #if !COOPER
        _internalEntity = Foundation.UUID(uuidString: string)!
        #else
        _internalEntity = java.util.UUID.fromString(string)
        #endif
    }
    
    public var UUIDString: String {
        #if !COOPER
        return _internalEntity.uuidString
        #else
        return _internalEntity.toString()
        #endif
    }
}
