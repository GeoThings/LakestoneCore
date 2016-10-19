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
		return BitmapFactory.decodeByteArray(data.plainBytes, 0, data.plainBytes.length)
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
