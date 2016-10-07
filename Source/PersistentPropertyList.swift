//
//  PersistentPropertyList.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 6/13/16.
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

#if COOPER
	import android.content
	import android.preference
#else
	import Foundation
#endif

public class PersistentPropertyList {
	
	#if COOPER
	
	private let sharedPreference: SharedPreferences
	private let sharedPreferenceEditor: SharedPreferences.Editor
	public init(applicationContext: Context, preferenceFileKey: String? = nil){
		
		if let passedPreferenceKey = preferenceFileKey {
			self.sharedPreference = applicationContext.getSharedPreferences(preferenceFileKey, Context.MODE_PRIVATE)
		} else {
			self.sharedPreference = PreferenceManager.getDefaultSharedPreferences(applicationContext)
		}
		
		self.sharedPreferenceEditor = self.sharedPreference.edit()
	}
	
	#else
	
	private let userDefaults: UserDefaults
	public init(){
		self.userDefaults = UserDefaults.standard
	}
	
	#endif
	
	public func set(_ value: Bool, forKey key: String){
		#if COOPER
			self.sharedPreferenceEditor.putBoolean(key, value)
		#else
			self.userDefaults.set(value, forKey: key)
		#endif
	}
	
	public func set(_ value: Int, forKey key: String){
		#if COOPER
			self.sharedPreferenceEditor.putInt(key, value)
		#else
			self.userDefaults.set(value, forKey: key)
		#endif
	}
	
	public func set(_ value: Float, forKey key: String){
		#if COOPER
			self.sharedPreferenceEditor.putFloat(key, value)
		#else
			self.userDefaults.set(value, forKey: key)
		#endif
	}
	
	public func set(_ value: Double, forKey key: String){
		#if COOPER
			//android sharedPreference for some reason doesn't have double support, store as string then instead
			self.sharedPreferenceEditor.putString(key, value.toString())
		#else
			self.userDefaults.set(value, forKey: key)
		#endif
	}
	
	public func set(_ value: String, forKey key: String){
		#if COOPER
			self.sharedPreferenceEditor.putString(key, value)
		#else
			self.userDefaults.set(value, forKey: key)
		#endif
	}
	
	public func set(_ value: Set<String>, forKey key: String){
		#if COOPER
			var javaSet = java.util.HashSet<String>(value)
			self.sharedPreferenceEditor.putStringSet(key, javaSet)
		#else
			self.userDefaults.set([String](value), forKey: key)
		#endif
	}
	
	public func bool(forKey key: String) -> Bool? {
		#if COOPER
			return (self.sharedPreference.contains(key)) ? self.sharedPreference.getBoolean(key, false) : nil
		#else
			return (self.userDefaults.object(forKey: key) != nil) ? self.userDefaults.bool(forKey: key) : nil
		#endif
	}
	
	public func integer(forKey key: String) -> Int? {
		#if COOPER
			return (self.sharedPreference.contains(key)) ? self.sharedPreference.getInt(key, 0) : nil
		#else
			return (self.userDefaults.object(forKey: key) != nil) ? self.userDefaults.integer(forKey: key) : nil
		#endif
	}
	
	public func float(forKey key: String) -> Float? {
		#if COOPER
			return (self.sharedPreference.contains(key)) ? self.sharedPreference.getFloat(key, 0.0) : nil
		#else
			return (self.userDefaults.object(forKey: key) != nil) ? self.userDefaults.float(forKey: key) : nil
		#endif
	}
	
	public func double(forKey key: String) -> Double? {
		#if COOPER
		//android sharedPreference for some reason doesn't have double support, it is stored as string instead
			return (self.sharedPreference.contains(key)) ? Double.parseDouble(self.sharedPreference.getString(key, "0.0")) : nil
		#else
			return (self.userDefaults.object(forKey: key) != nil) ? self.userDefaults.double(forKey: key) : nil
		#endif
	}
	
	public func string(forKey key: String) -> String? {
		#if COOPER
			return (self.sharedPreference.contains(key)) ? self.sharedPreference.getString(key, "") : nil
		#else
			return self.userDefaults.string(forKey: key)
		#endif
	}
	
	public func stringSet(forKey key: String) -> Set<String>? {
		#if COOPER
		
			if (self.sharedPreference.contains(key)){
				let javaStringSet = java.util.HashSet<String>(self.sharedPreference.getStringSet(key, java.util.HashSet<String>()))
				
				let returnSet = Set<String>()
				for entity in javaStringSet {
					returnSet.insert(entity)
				}
				return returnSet
				
			} else {
				return nil
			}
			
		#else
		
			guard let stringArray = self.userDefaults.stringArray(forKey: key) else {
				return nil
			}
			return Set<String>(stringArray)
			
		#endif   
	}
    
	public func removeObject(forKey key: String){
		
		#if COOPER
			self.sharedPreferenceEditor.remove(key)
		#else
			self.userDefaults.removeObject(forKey: key)
		#endif
	}
	
	public func synchronize(){
		#if COOPER
			self.sharedPreferenceEditor.apply()
		#else
			self.userDefaults.synchronize()
		#endif
	}
	
	public var allKeys: Set<String> {
		#if COOPER
			
			let javaStringSet = self.sharedPreference.getAll().keySet()
			let returnSet = Set<String>()
			for entity in javaStringSet {
				returnSet.insert(entity)
			}
			return returnSet
			
		#else
			return Set<String>(self.userDefaults.dictionaryRepresentation().keys)
			
		#endif
	}
	
}
