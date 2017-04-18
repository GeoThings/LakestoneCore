//
//  extension_String.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/27/16.
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
// General additional string abstractions.
// The core set of abstractions in being provided in SwiftBaseLibrary.
// Still need to understand though the principle to what should appear here
// and what should be on SwiftBaseLibrary level
//
// Java strings differ from Swift ones in its semantics. They are reference-type versus Swift's value type.
// That results in Java strings being immutable. On the other hand Swift standart library APIs are predominantly mutable
// Immutable Swift String APis where added to correspondent mutable APIs.
//

#if COOPER
	import java.util
	import java.util.regex
#else
	import Foundation
#endif


#if COOPER
	
	public typealias Character = Char
	
#endif

extension String {
	
	#if COOPER
	
    public enum CompareOptions {
        case none
        case backwards
    }
    
	//MARK: - Standard Library APIs
	public func lowercased() -> String {
		return self.toLowerCase()
	}
	
	public func uppercased() -> String {
		return self.toUpperCase()
	}
	
	/* Available in Silver's SwiftBaseLibrary
	 
	public var isEmpty: Bool {
		return self.isEmpty()
	}
	
	public func hasPrefix(_ `prefix`: String) -> Bool {
		return self.startsWith(`prefix`)
	}
	
	public func hasSuffix(_ `suffix`: String) -> Bool {
		return self.endsWith(`suffix`)
	}
 
	public var startIndex: String.Index {
		return 0
	}
	
	public var endIndex: String.Index {
		return self.length()
	}
 
	*/
 
	public typealias Index = Int
	public typealias IndexDistance = Int
	
	
	//TODO: Implement character view
	//TODO: Implement proper indexing
	
	public func index(after i: String.Index) -> String.Index {
		return i + 1;
	}
	
	public func index(before i: String.Index) -> String.Index {
		return i - 1;
	}
	
	public func index(_ i: String.Index, offsetBy n: String.IndexDistance) -> String.Index {
		return i + n;
	}
	
	public func index(_ i: String.Index, offsetBy n: String.IndexDistance, limitedBy limit: String.Index) -> String.Index? {
	
		if (n > 0){
			if (limit < i){
				return self.index(i, offsetBy: n)
			}
			
			return (i + n > limit) ? nil : self.index(i, offsetBy: n) 
			
		} else {
			if (limit > i){
				return self.index(i, offsetBy: n)
			}
	
			return (i + n < limit) ? nil : self.index(i, offsetBy: n)
		}
	
	}
	
	public func distance(from start: String.Index, to end: String.Index) -> String.IndexDistance {
		return end - start
	}
	
	/* Silver doesn't recognize subscript overloading
	public subscript(bounds: Range) -> String {
		let endIndex = (bounds.closed) ? bounds.endIndex + 1 : bounds.endIndex
		return self.substring(bounds.startIndex, endIndex)
	}
	*/
	
	#endif
	
	#if COOPER
	public func appending(_ other: String) -> String {
		return self.concat(other)
	}
	#endif
	
	public func appending(_ c: Character) -> String {
	
		#if COOPER
			return self + c
		#else
			var target = self
			target.append(c)
			return target
		#endif
	}
	
	#if COOPER
	
	public func replacingSubrange(_ bounds: Range, with newElements: String) -> String {
	
		let endIndex = (bounds.closed) ? bounds.upperBound + 1 : bounds.upperBound
		let substring = self.substring(bounds.lowerBound, endIndex)
		return self.replace(substring, newElements)
	}
	
	#else
	
	public func replacingSubrange<C>(_ bounds: Range<String.Index>, with newElements: C) -> String where C : Collection, C.Iterator.Element == Character {
		var target = self
		target.replaceSubrange(bounds, with: newElements)
		return target
	}
	
	public func replacingSubrange(_ bounds: Range<String.Index>, with newElements: String) -> String {
		var target = self
		target.replaceSubrange(bounds, with: newElements)
		return target
	}
	
	public func replacingSubrange<C>(_ bounds: ClosedRange<String.Index>, with newElements: C) -> String where C : Collection, C.Iterator.Element == Character {
		var target = self
		target.replaceSubrange(bounds, with: newElements)
		return target
	}
	
	public func replacingSubrange(_ bounds: ClosedRange<String.Index>, with newElements: String) -> String {
		var target = self
		target.replaceSubrange(bounds, with: newElements)
		return target
	}
	
	#endif
	
	public func inserting(_ newElement: Character, at index: String.Index) -> String {
	
		#if COOPER
			let replacementString = StringBuilder(self).insert(index, newElement).toString()
			return self.replace(self, replacementString)
		#else
			var target = self
			target.insert(newElement, at: index)
			return target
		#endif
	}
	
	
	public func removing(at i: String.Index) -> String {
		
		#if COOPER
			let replacementString = StringBuilder(self).deleteCharAt(i).toString()
			return self.replace(self, replacementString)
		#else
			var target = self
			target.remove(at: i)
			return target
		#endif
	}
	
	#if COOPER
	
	public func removingSubrange(_ bounds: Range) -> String {
	
		let endIndex = (bounds.closed) ? bounds.upperBound + 1 : bounds.upperBound
		let replacementString = StringBuilder(self).delete(bounds.lowerBound, endIndex).toString()
		return self.replace(self, replacementString)
	}
	
	#else
	
	public func removingSubrange(_ bounds: Range<String.Index>) -> String {
		var target = self
		target.removeSubrange(bounds)
		return target
	}
	
	public func removingSubrange(_ bounds: ClosedRange<String.Index>) -> String {
		var target = self
		target.removeSubrange(bounds)
		return target
	}
	
	#endif
	
	public func removingAll() -> String {
		#if COOPER
			return String()
		#else
			var target = self
			target.removeAll()
			return target
		#endif
	}
	
	//MARK: - Foundation APIs
	
	#if COOPER
	
	public func replacingCharacters(`in` range: Range, with newElements: String) -> String {
		return self.replacingSubrange(range, with: newElements)
	}
	
	public func replacingOccurrences(of string: String, with newString: String) -> String {
		return self.replaceAll(string, newString)
	}
	
	public func substring(from index: String.Index) -> String {
		return self.substring(index)
	}
	
	public func substring(to index: String.Index) -> String {
		return self.substring(0, index)
	}
	
	public func substring(with range: Range) -> String {
		let endIndex = (range.closed) ? range.upperBound + 1 : range.upperBound
		return self.substring(range.lowerBound, endIndex)
	}
	
	public func range(of substring: String, options: CompareOptions = .none) -> Range? {
	
		let startIndex: Int
		if let compareOptions = options, compareOptions == .backwards {
			startIndex = self.lastIndexOf(substring)
		} else {
			startIndex = self.indexOf(substring)
		}
	
		return (startIndex >= 0) ? startIndex ..< startIndex + substring.length() : nil
	}
	
	public func components(separatedBy seperator: String) -> [String] {
		
		var seperatorRangeº = self.range(of: seperator)
		if seperatorRangeº != nil {
			
			var array = [String]()
			var parseIndex = self.startIndex
			var activeSubstring = self
			while seperatorRangeº != nil  {
				
				let copyString = activeSubstring.substring(to: seperatorRangeº!.lowerBound)
				array.append(copyString)
	
				parseIndex = seperatorRangeº!.upperBound
				activeSubstring = activeSubstring.substring(from: parseIndex)
				
				seperatorRangeº = activeSubstring.range(of: seperator)
			}
			
			array.append(activeSubstring)
			return array
			
		} else {
			return [self]
		}
	}
	
	//TODO: Implement write(toFile:,atomically:,encoding:), write(to:,atomically:,encoding:)
	
	#endif
	
	//MARK: - Misc
	
	/// remark: Temporary string-length accessor until SwiftString is fixed in Silver's SBL
	public var characterCount: Int {
		#if COOPER
			return self.length()
		#else
			return self.characters.count
		#endif
	}
	
	public var isNumeric: Bool {
		
		if self.isEmpty {
			return false
		}
		
		#if COOPER
			
			for indexOffset in 0 ..< self.characterCount {
				let character = self[indexOffset]
				if !Character.isDigit(character){
					return false
				}
			}
			
			return true
		
		#else
			return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
			
		#endif
	}
	
	public var representsDecimal: Bool {
		
		#if COOPER
			
			if Character.isSpaceChar(self[0]) || Character.isWhitespace(self[0]) {
				return false
			}
			
			let scanner = Scanner(self)
			if scanner.hasNextInt(){
				_ = scanner.nextInt()
				return !scanner.hasNextLine()
			} else {
				return false
			}
			
		#else
			return Int32(self) != nil
			
		#endif
	}
	
	public var representsLongDecimal: Bool {
		
		#if COOPER
			
			if Character.isSpaceChar(self[0]) || Character.isWhitespace(self[0]) {
				return false
			}
			
			let scanner = Scanner(self)
			if scanner.hasNextLong(){
				_ = scanner.nextLong()
				return !scanner.hasNextLine()
			} else {
				return false
			}
			
		#else
			return Int64(self) != nil
			
		#endif
	}
	
	public var representsFloat: Bool {
		
		#if COOPER
		
			if Character.isSpaceChar(self[0]) || Character.isWhitespace(self[0]) {
				return false
			}
			
			let scanner = Scanner(self)
			if scanner.hasNextFloat() {
				_ = scanner.nextFloat()
				return !scanner.hasNextLine()
			} else {
				return false
			}
			
		#else
			return Float(self) != nil
			
		#endif
	}
	
	public var representsDouble: Bool {
		
		#if COOPER
			
			if Character.isSpaceChar(self[0]) || Character.isWhitespace(self[0]) {
				return false
			}
			
			let scanner = Scanner(self)
			if scanner.hasNextDouble() {
				_ = scanner.nextDouble()
				return !scanner.hasNextLine()
			} else {
				return false
			}
			
		#else
			return Double(self) != nil
			
		#endif
	}
	
	public var representsBool: Bool {
		
		return ["true", "false", "0", "1"].contains(self.lowercased())
	}
	
	public var boolRepresentation: Bool? {
		if ["true", "1"].contains(self.lowercased()) {
			return true
		} else if ["false", "0"].contains(self.lowercased()){
			return false
		} else {
			return nil
		}
	}
	
	public var decimalRepresentation: Int32? {
		#if COOPER
			return (self.representsDecimal) ? Integer.parseInt(self) : nil
		#else
			return Int32(self)
		#endif
	}
	
	public var longDecimalRepresentation: Int64? {
		#if COOPER
			return (self.representsLongDecimal) ? Long.parseLong(self) : nil
		#else
			return Int64(self)
		#endif
	}
	
	public var floatRepresentation: Float? {
		#if COOPER
			return (self.representsFloat) ? Float.parseFloat(self) : nil
		#else
			return Float(self)
		#endif
	}
	
	public var doubleRepresentation: Double? {
		#if COOPER
			return (self.representsDouble) ? Double.parseDouble(self) : nil
		#else
			return Double(self)
		#endif
	}
	
	// modified init(describing:) 
	// in addition works StringRepresentable, SerializableTypeRepresentable, CustomSerializable
	// optional values are unwrapped if present, "nil" otherwise
	//
	// Array, Set, Dictionary, CustomSerializable is displayed as encoded JSON string
	public static func derived(from entity: Any) -> String {
	
		#if !COOPER
			if Mirror(reflecting: entity).displayStyle == .optional {
				if let unwrappedValue = Mirror(reflecting: entity).descendant("some") {
					return String.derived(from: unwrappedValue)
				} else {
					return ""
				}
			}
		#endif
		
		if let stringEntity = entity as? String {
			return stringEntity
		} else if let arrayEntity = entity as? [Any] {
			return (try? JSONSerialization.data(withJSONObject: arrayEntity))?.utf8EncodedStringRepresentationº ?? ""
		} else if let dictionaryEntity = entity as? [String: Any] {
			return (try? JSONSerialization.data(withJSONObject: dictionaryEntity))?.utf8EncodedStringRepresentationº ?? ""
		} else if let setEntity = entity as? Set<AnyHashable> {
			return (try? JSONSerialization.data(withJSONObject: [AnyHashable](setEntity)))?.utf8EncodedStringRepresentationº ?? ""
		} else if let dataEntity = entity as? Data {
		
			return dataEntity.utf8EncodedStringRepresentationº ?? ""
			
		} else {
			#if COOPER
				return "\(entity)"
			#else
				return String(describing: entity)
			#endif
		}
	}
}

#if COOPER

extension String: Equatable {}
public func ==(lhs: String, rhs: String) -> Bool {
	return lhs.equals(rhs)
}
	
#endif

















