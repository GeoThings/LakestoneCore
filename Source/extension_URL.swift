//
//  extension_URL.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/21/16.
//
//

#if !COOPER
    import Foundation
#endif

extension URL {
    
    public static func from(string: String) -> URL? {
        #if COOPER
            return try? URL(string)
        #else
            return URL(string: string)
        #endif
    }
    
}
