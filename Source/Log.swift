//
//  Log.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 6/1/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if !COOPER
    import Foundation
#endif

public class Log {
    #if !COOPER
    public enum LoggingLevel:Int {
        case Verbose = 0
        case Debug = 1
        case Info = 2
        case Warning = 3
        case Error = 4
        
        var stringValue: String {
            switch self {
            case .Verbose: return "Verbose"
            case .Debug: return "Debug"
            case .Info: return "Info"
            case .Warning: return "WARNING"
            case .Error: return "ERROR"
            }
        }
    }
    
    public static var level: LoggingLevel = .Verbose
    #endif
    
    public class func v(_ tag: String, _ string: String, file: String = #file, line: Int = #line, function: String = #function){
        #if COOPER
        android.util.Log.v(tag, "\(file):\(line):\(function): \(string)")
        #else
        _logCore(stringToLog: "\(file):\(line):\(function): \(string))", visibility: .Verbose)
        #endif
    }
    public class func d(_ tag: String, _ string: String, file: String = #file, line: Int = #line, function: String = #function){
        #if COOPER
        android.util.Log.d(tag, "\(file):\(line):\(function): \(string)")
        #else
        _logCore(stringToLog: "\(file):\(line):\(function): \(string))", visibility: .Debug)
        #endif
    }
    public class func i(_ tag: String, _ string: String, file: String = #file, line: Int = #line, function: String = #function){
        #if COOPER
        android.util.Log.i(tag, "\(file):\(line):\(function): \(string)")
        #else
        _logCore(stringToLog: "\(file):\(line):\(function): \(string))", visibility: .Info)
        #endif
    }
    public class func w(_ tag: String, _ string: String, file: String = #file, line: Int = #line, function: String = #function){
        #if COOPER
        android.util.Log.w(tag, "\(file):\(line):\(function): \(string)")
        #else
        _logCore(stringToLog: "\(file):\(line):\(function): \(string))", visibility: .Warning)
        #endif
    }
    public class func e(_ tag: String, _ string: String, file: String = #file, line: Int = #line, function: String = #function){
        #if COOPER
        android.util.Log.e(tag, "\(file):\(line):\(function): \(string)")
        #else
        _logCore(stringToLog: "\(file):\(line):\(function): \(string))", visibility: .Error)
        #endif
    }
    
    //CustomStringConvertible
    #if !COOPER
    public class func v(_ tag: String, _ entity: CustomStringConvertible, file: String = #file, line: Int = #line, function: String = #function){
        _logCore(stringToLog: "\(file):\(line):\(function): \(entity.description))", visibility: .Verbose)
    }
    public class func d(_ tag: String, _ entity: CustomStringConvertible, file: String = #file, line: Int = #line, function: String = #function){
        _logCore(stringToLog: "\(file):\(line):\(function): \(entity.description))", visibility: .Debug)
    }
    public class func i(_ tag: String, _ entity: CustomStringConvertible, file: String = #file, line: Int = #line, function: String = #function){
        _logCore(stringToLog: "\(file):\(line):\(function): \(entity.description))", visibility: .Info)
    }
    public class func w(_ tag: String, _ entity: CustomStringConvertible, file: String = #file, line: Int = #line, function: String = #function){
        _logCore(stringToLog: "\(file):\(line):\(function): \(entity.description))", visibility: .Warning)
    }
    public class func e(_ tag: String, _ entity: CustomStringConvertible, file: String = #file, line: Int = #line, function: String = #function){
        _logCore(stringToLog: "\(file):\(line):\(function): \(entity.description))", visibility: .Error)
    }
    
    //MARK: private - Utilities
    private class func _logCore(stringToLog string: String, visibility: LoggingLevel, threadCountº: Int? = nil){
        
        let stringToLog = _stringWithLoggingSugar(to: string, visibility: visibility, threadCountº: threadCountº)
        if (self.level.rawValue <= visibility.rawValue){
            
            print(stringToLog)
        }
    }
    
    private class func _stringWithLoggingSugar(to stringToLog: String, visibility: LoggingLevel, threadCountº:Int? = nil) -> String {
        
        let currentTimeString = Date().xsdGMTDateTimeString
        if let threadCount = threadCountº {
            return "\(currentTimeString) (queue:\(threadCount)): \(stringToLog)"
        } else {
            return "\(currentTimeString) (\(visibility.stringValue)): \(stringToLog)"
        }
    }
    #endif
}
