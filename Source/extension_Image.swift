//
//  extension_Image.swift
//  geoBingAnKit
//
//  Created by Taras Vozniuk on 10/19/16.
//
//

#if COOPER
	import android.graphics
#else
	import Foundation

	#if os(OSX)
		import AppKit
	#elseif os(iOS) || os(tvOS) || os(watchOS)
		import UIKit
	#endif

#endif

	
extension Image {
	
	#if COOPER
	public init?(data: Data){
		let plainData = data.plainBytes
		return BitmapFactory.decodeByteArray(plainData, 0, plainData.length)
	}
	
	public var size: Size {
		return Size(width: Double(self.getWidth()), height: Double(self.getHeight()))
	}
	
	public init?(contentsOfFile filePath: String){
		return BitmapFactory.decodeFile(filePath);
	}
	
	#endif
	
	public var pngRepresentation: Data? {
		
		#if COOPER
		
			let byteArrayOutputStream = java.io.ByteArrayOutputStream()
			self.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
			return Data.wrap(byteArrayOutputStream.toByteArray())
		
		#elseif os(OSX)
		
			guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
				return nil
			}
			
			let bitmapImage = NSBitmapImageRep(cgImage: cgImage)
			bitmapImage.size = self.size
			return bitmapImage.representation(using: NSBitmapImageFileType.PNG, properties: [:])
			
		#elseif os(iOS) || os(tvOS) || os(watchOS)
		
			return UIImagePNGRepresentation(self)
			
		#endif
	}
}
