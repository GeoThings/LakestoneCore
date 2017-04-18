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
	import Dispatch
#endif

//TODO: GeoThings/LakestoneCore: Issue #5: Reconsider Threading abstractions
//link: https://github.com/GeoThings/LakestoneCore/issues/5

#if COOPER
	public typealias ThreadQueue = ExecutorService
	public typealias ConstraintConcurrentThreadQueue = ExecutorService
	
    public typealias Semaphore = java.util.concurrent.Semaphore
	// ReentrantLock provides the corresponding functionaly with matching lock()/tryLock()/unlock() naming
	public typealias Lock = java.util.concurrent.locks.ReentrantLock
	
#else

    public typealias ThreadQueue = DispatchQueue
    public typealias ConstraintConcurrentThreadQueue = OperationQueue
    public typealias Semaphore = DispatchSemaphore
    
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
        
        /// Acquire the lock, execute the closure, release the lock.
        public func doWithLock(closure: () throws -> ()) rethrows {
            let _ = self.lock()
            defer {
                let _ = self.unlock()
            }
            try closure()
        }
    }

#endif
	

/// Executes the closure synchronized on given reentrant mutual exlusion lock
public func synchronized(on lock: Lock, closure: () -> Void){
	lock.lock()
	closure()
	lock.unlock()
}



/// Utilities for threading
public class Threading {
	
    public class func dispatchOnMainQueue(_ closure: @escaping () -> Void){
            
        #if COOPER
            Handler(Looper.getMainLooper()).post { closure() }
        #else
            DispatchQueue.main.async(execute: closure)
        #endif
    }
}

extension ThreadQueue {
    
    public func dispatch(_ closure: @escaping () -> Void){
        #if COOPER
            self.execute { closure() }
        #else
            self.async(execute: closure)
        #endif
    }
}

#if !COOPER

extension ConstraintConcurrentThreadQueue {
        
    public func dispatch(_ closure: @escaping () -> Void){
        self.addOperation {
            closure()
        }
    }
}
	
#endif

extension Threading {
	
	/// creates a new serial queue, exception is Linux/OSX, 
	/// where if queue with a given label exists already, existing queue will be returned
	public static func serialQueue(withLabel label: String) -> ThreadQueue {
		#if COOPER
			return Executors.newSingleThreadExecutor()
		#else
			return DispatchQueue(label: label, qos: DispatchQoS.default)
		#endif
	}
	
	public static func concurrentQueue(withMaximumConcurrentThreads threadCount: Int) -> ConstraintConcurrentThreadQueue {
		#if COOPER
			//corePoolSize: Integer, maximumPoolSize: Integer, keepAliveTime: Int64, unit: TimeUnit!, workQueue: BlockingQueue<Runnable>!
			return ThreadPoolExecutor(threadCount, threadCount, 60, TimeUnit.SECONDS, LinkedBlockingQueue<Runnable>())
		#else
			let concurrentQueue = OperationQueue()
            concurrentQueue.maxConcurrentOperationCount = threadCount
            return concurrentQueue
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

#else

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
	
#endif

