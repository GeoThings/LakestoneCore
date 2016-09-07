//
//  Threading.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 6/7/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
    import android.os
    import java.util.concurrent
#else
    import Foundation
    import Dispatch
#endif

#if COOPER
    public typealias ThreadQueue = ExecutorService
    public typealias Lock = java.util.concurrent.locks.ReentrantLock
#else
    public typealias ThreadQueue = DispatchQueue
    public typealias Lock = Int
#endif

public func synchronized(onLock lock: Lock, closure: () -> Void){
	#if COOPER
        lock.lock()
        closure()
        lock.unlock()
	#else
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
	#endif
}

public class Threading {
	
	#if COOPER
	internal class _Runnable: Runnable {
		let callback: () -> Void
		init(callback: () -> Void){
			self.callback = callback
		}
		
		public func run() {
			callback()
		}
	}
	#endif
	
	public class func dispatchOnMainQueue(closure: @escaping () -> Void){
		#if !COOPER
            DispatchQueue.main.async(execute: closure)
        #else
            Handler(Looper.getMainLooper()).post(_Runnable(callback: closure))
		#endif
	}
	
	public class func serialQueue(withLabel label: String) -> ThreadQueue {
		#if !COOPER
            return DispatchQueue(label: label, qos: DispatchQoS.default)
        #else
            return Executors.newSingleThreadExecutor()
		#endif
	}
}

extension ThreadQueue {
	
	public func dispatch(closure: @escaping () -> Void){
		#if COOPER
            self.execute(Threading._Runnable(callback: closure))
		#else
            self.async(execute: closure)
		#endif
	}
}
