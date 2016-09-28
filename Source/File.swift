//
//  File.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/28/16.
//
//

#if !COOPER
    
import Foundation

#endif

#if !COOPER

public class File {
    
    let path: String
    public init(path: String){
        self.path = path
    }
    
    public init(fileURL: URL){
        self.path = fileURL.path
    }
}
    
#endif
