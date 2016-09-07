//
//  AssetsManager.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 8/22/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
    import android.os
    import android.content
    import android.graphics
#else
    import Foundation
#endif

public class AssetsManager {
    
    #if COOPER
    private let _applicationContext: Context
    public init(applicationContext: Context){
        _applicationContext = applicationContext
    }
    #else
    public init(){}
    #endif
    
    public func allAssetsPaths(withExtension ext: String, inDirectory assetDirectory: String) -> Set<String> {
        
        #if COOPER
        
        return Set<String>([String](([String](_applicationContext.getResources().getAssets().list(assetDirectory))).filter { $0.hasSuffix(".\(ext)") }))
        
        #else
        
        return Set<String>(Bundle.main.paths(forResourcesOfType: ext, inDirectory: assetDirectory))
            
        #endif
    }
    
    public func assetPath(withNameContaining nameSegment: String, inDirectory assetDirectory: String) -> String? {
        for assetPath in self.allAssetsPaths(withExtension: "png", inDirectory: assetDirectory){
            let assetPathFilename = assetPath.lastPathComponent
            if assetPathFilename.contains(nameSegment) {
                return assetPath
            }
        }
        
        return nil
    }
    
    public func image(withContentsOfAssetWithNameContaining nameSegment: String, inDirectory assetDirectory: String) -> Image? {
        
        guard let assetPath = self.assetPath(withNameContaining: nameSegment, inDirectory: assetDirectory) else {
            return nil
        }
        
        return self.image(withContentsOfAssetAtPath: assetPath)
    }
    
    public func image(withContentsOfAssetAtPath path: String) -> Image? {
        
        #if COOPER
        
        let assetManager = _applicationContext.getAssets()
        do {
            
            let inputFileStream = try assetManager.`open`(path)
            let bitmap = BitmapFactory.decodeStream(inputFileStream)
            return bitmap
            
        } catch {
            return nil
        }
        
        #else
        
        return Image(contentsOfFile: path)
        
        #endif
        
    }
    
}
