//
//  Threading.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 6/7/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//
//===----------------------------------------------------------------------===//
//
// Fraction of this source file is part of the Perfect.org open source project
// (Threading.Lock)
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
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
	#if os(iOS) || os(watchOS) || os(tvOS)
		import Darwin
		import Dispatch
	#else
		import PerfectThread
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
	// Copied implementation of PerfectThread.Threading.Lock for iOS to avoid PerfectThread dependency there
	
	/// A mutex-type thread lock.
	/// The lock can be held by only one thread. Other threads attempting to secure the lock while it is held will block.
	/// The lock is initialized as being recursive. The locking thread may lock multiple times, but each lock should be accompanied by an unlock.
	public class Lock {
		var mutex = pthread_mutex_t()
		/// Initialize a new lock object.
		public init() {
			var attr = pthread_mutexattr_t()
			pthread_mutexattr_init(&attr)
			pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_RECURSIVE))
			pthread_mutex_init(&mutex, &attr)
		}
		
		deinit {
			pthread_mutex_destroy(&mutex)
		}
		
		/// Attempt to grab the lock.
		/// Returns true if the lock was successful.
		@discardableResult
		public func lock() -> Bool {
			return 0 == pthread_mutex_lock(&self.mutex)
		}
		
		/// Attempt to grab the lock.
		/// Will only return true if the lock was not being held by any other thread.
		/// Returns false if the lock is currently being held by another thread.
		public func tryLock() -> Bool {
			return 0 == pthread_mutex_trylock(&self.mutex)
		}
		
		/// Unlock. Returns true if the lock was held by the current thread and was successfully unlocked. ior the lock count was decremented.
		@discardableResult
		public func unlock() -> Bool {
			return 0 == pthread_mutex_unlock(&self.mutex)
		}
	}
	
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
