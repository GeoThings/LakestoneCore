//
//  alliases.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 5/31/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER

#else
    
    import Foundation
    #if os(iOS) || os(watchOS) || os(tvOS)
        import UIKit
    #endif
    
#endif
    

#if COOPER
    
    public typealias URL = java.net.URL
    public typealias Response = okhttp3.Response
    public typealias ResponseError = java.io.IOException
    public typealias Data = java.nio.ByteBuffer
    public typealias JSONObject = org.json.JSONObject
    
    public typealias Error = java.lang.Exception
    public typealias RuntimeError = java.lang.Error
    public typealias File = java.io.File
    
    public typealias Image = android.graphics.Bitmap
    public typealias Rectangle = android.graphics.RectF
    
    public typealias Date = java.util.Date
    
    //well... what else...
    public typealias Color = Int
    
#else
    
    public typealias Response = URLResponse
    public typealias ResponseError = Error
    public typealias JSONObject = Any
    
    //cocoa doesn't have the actual file objectized
    public typealias File = String
    
    public typealias Rectangle = CGRect
    
    #if os(iOS) || os(watchOS) || os(tvOS)
        public typealias Image = UIImage
        public typealias Color = UIColor
    #endif

#endif
