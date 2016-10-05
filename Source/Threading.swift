//
//  Threading.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 6/7/16.
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
//
//  Threading-related set of abstractions
//  The abstractions is alligned to correspond to PerfectThread API naming
//
//  PerfectThread.Threading.Lock has been coppied here to provide the corresponding
//  iOS Lock implementation for a sake of not having PerfectThread as iOS dependency
//


#if COOPER
	import android.os
	import java.util.concurrent
#else
	import Foundation
    import PerfectThread
    
	#if os(iOS) || os(watchOS) || os(tvOS)
		import Dispatch
	#endif
#endif

#if COOPER
	public typealias ThreadQueue = ExecutorService
#elseif os(iOS) || os(watchOS) || os(tvOS)
	public typealias ThreadQueue = DispatchQueue
#else
    // for OSX and Linux PerfectThread.ThreadQueue corresponding type is used
#endif

/// Executes the closure synchronized on given reentrant mutual exlusion lock
public func synchronized(on lock: Threading.Lock, closure: () -> Void){
	lock.lock()
	closure()
	lock.unlock()
}

#if COOPER

public class Threading {
    
    internal class _Runnable: Runnable {
        let callback: () -> Void
        init(callback: () -> Void){
            self.callback = callback
        }
    
        public func run() {
            callback()
        }
    }
    
    public class func dispatchOnMainQueue(_ closure: @escaping () -> Void){
        Handler(Looper.getMainLooper()).post(_Runnable(callback: closure))
    }
}

extension ThreadQueue {
        
    public func dispatch(_ closure: @escaping () -> Void){
        self.execute(Threading._Runnable(callback: closure))
    }
}
    
#elseif os(iOS) || os(watchOS) || os(tvOS)

public class Threading {
    
    public class func dispatchOnMainQueue(_ closure: @escaping () -> Void){
        DispatchQueue.main.async(execute: closure)
    }
}
    
extension ThreadQueue {
        
    public func dispatch(_ closure: @escaping () -> Void){
        self.async(execute: closure)
    }
}
    
#endif
    

public extension Threading {
	
	#if COOPER
	
	// ReentrantLock provides the corresponding functionaly with matching lock()/tryLock()/unlock() naming
	public typealias Lock = java.util.concurrent.locks.ReentrantLock
	
    #elseif os(iOS) || os(watchOS) || os(tvOS)
    
    public typealias Lock = PerfectThread.Threading.Lock
    
    #endif
}

extension Threading {
	
	/// creates a new serial queue, exception is Linux/OSX, 
	/// where if queue with a given label exists already, existing queue will be returned
	public static func serialQueue(withLabel label: String) -> ThreadQueue {
		#if COOPER
			return Executors.newSingleThreadExecutor()
		#elseif os(Linux) || os(OSX)
			return Threading.getQueue(name: label, type: .serial)
		#else
			return DispatchQueue(label: label, qos: DispatchQoS.default)
		#endif
	}
	
}
