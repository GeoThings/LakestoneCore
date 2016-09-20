//
//  ErrorType.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/20/16.
//
//

/// The protocol to which all
public protocol ErrorRepresentable {
    var detailMessage: String { get }
}

public func ==(lhs: ErrorRepresentable, rhs: ErrorRepresentable) -> Bool {
    return lhs.detailMessage == rhs.detailMessage
}

open class StringBackedErrorType: ErrorRepresentable {
    
    public let representation: String
    public init(_ representation: String) { self.representation = representation }
    
    public var detailMessage: String { return self.representation }
}

#if COOPER

open class LakestoneError: java.lang.Exception {

    public let representation: ErrorRepresentable
    public init(_ representation: ErrorRepresentable){
        super.init(representation.detailMessage)
        self.representation = representation
    }
}
    
#else
    
open class LakestoneError: Error {
    
    /// interesting variable
    public let representation: ErrorRepresentable
    public init(_ representation: ErrorRepresentable){
        self.representation = representation
    }
}

#endif
