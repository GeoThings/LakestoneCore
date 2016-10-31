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
	
	#if !os(Linux)
		import Dispatch
	#endif
#endif

	
#if COOPER
	public typealias ThreadQueue = ExecutorService
	// ReentrantLock provides the corresponding functionaly with matching lock()/tryLock()/unlock() naming
	public typealias Lock = java.util.concurrent.locks.ReentrantLock
	public typealias Semaphore = java.util.concurrent.Semaphore
	
#else

	public typealias Lock = PerfectThread.Threading.Lock

	#if os(iOS) || os(watchOS) || os(tvOS)
		public typealias Semaphore = DispatchSemaphore
		public typealias ThreadQueue = DispatchQueue
	#elseif os(OSX)
		public typealias Semaphore = DispatchSemaphore
	#endif
	// for OSX and Linux PerfectThread.ThreadQueue corresponding type is used
	
#endif
	

/// Executes the closure synchronized on given reentrant mutual exlusion lock
public func synchronized(on lock: Lock, closure: () -> Void){
	lock.lock()
	closure()
	lock.unlock()
}

#if COOPER

public class Threading {
	
	public class func dispatchOnMainQueue(_ closure: @escaping () -> Void){
		Handler(Looper.getMainLooper()).post {
			closure()
		}
	}
}

extension ThreadQueue {
		
	public func dispatch(_ closure: @escaping () -> Void){
		self.execute {
			closure()
		}
	}
}
	
#elseif os(iOS) || os(watchOS) || os(tvOS)

public class Threading {}
	
extension ThreadQueue {
		
	public func dispatch(_ closure: @escaping () -> Void){
		self.async(execute: closure)
	}
}
	
#endif

#if os(OSX)
extension DispatchQueue {
	public func dispatch(_ closure: @escaping () -> Void){
		self.async(execute: closure)
	}
}
#endif

#if !COOPER && !os(Linux)
	
extension Threading {
		
	public static func dispatchOnMainQueue(_ closure: @escaping () -> Void){
		DispatchQueue.main.async(execute: closure)
	}
}
	
#endif

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

#if COOPER

extension Semaphore {
	
	public init(value: Int){
		self.init(value)
	}
	
	public func signal(){
		self.release()
	}
}

#elseif !os(Linux)

extension Semaphore {
	
	public func acquire(){
		self.wait()
	}
}

#endif


#if COOPER
	public func dispatch(on looper: android.os.Looper, closure: @escaping () -> Void){
		Handler(looper).post {
			closure()
		}
	}
#else

	public func dispatch(on queue: DispatchQueue, closure: @escaping () -> Void){
		queue.dispatch(closure)
	}
	
	#if os(OSX) || os(Linux)
		public func dispatch(on queue: ThreadQueue, closure: @escaping () -> Void){
			queue.dispatch(closure)
		}
	#endif
	
#endif

