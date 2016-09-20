//
//  alliases.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/20/16.
//
//

#if !COOPER
	
	import Foundation
	#if os(iOS) || os(watchOS) || os(tvOS)
		import UIKit
	#else
		import AppKit
	#endif
	
#endif

#if COOPER

	public typealias URL = java.net.URL
	public typealias Data = java.nio.ByteBuffer
	public typealias Date = java.util.Date
    
#else

	
	
#endif
