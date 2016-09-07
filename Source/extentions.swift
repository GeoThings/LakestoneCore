//
//  extentions.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 5/19/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
    import java.nio.charset
    import java.io
    import android.graphics.drawable
    import android.graphics

#else
    import Foundation
    #if os(iOS) || os(watchOS) || os(tvOS)
        import UIKit
    #endif
#endif

extension URL {
	public static func constructWithValidation(fromString string: String) throws -> URL {
		
		#if COOPER
			
            if !android.util.Patterns.WEB_URL.matcher(string).matches() {
                throw ErrorBuilder.from(errorDescription: "Invalid URL Format")
            }
            
            return URL(string)
		
		#else
		
            guard let resURL = URL(string: string) else {
                throw ErrorBuilder.CoreError.InvalidURLFormat
            }
            
            return resURL
			
		#endif
	}
}

#if COOPER
    
private var _xsdGMTDateFormatter: TimezoneAdjustedDateFormat {
	return TimezoneAdjustedDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
}
    
#else
    
private var _xsdGMTDateFormatter: DateFormatter {
		
	let formatter = DateFormatter()
	formatter.timeStyle = .full
	formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
	formatter.timeZone = TimeZone(abbreviation: "GMT")
	return formatter
}
#endif

extension Date {
	
	public static func from(timeIntervalSince1970 timeInterval: Double) -> Date {
		#if COOPER
            //timeInterval is milliseconds stored in 64-bit signed int
            return java.util.Date(Int64(timeInterval))
		
		#else
            //timeInterval is seconds stored in double
            return Date(timeIntervalSince1970: timeInterval)
		
		#endif
	}
	
	public var timeInterval: Double {
		#if COOPER
            return Double(self.getTime())
		#else
            return self.timeIntervalSince1970
		#endif
	}
	
	public var xsdGMTDateTimeString: String {
		
		#if COOPER
            return _xsdGMTDateFormatter.format(self)
		#else
            return _xsdGMTDateFormatter.string(from: self)
		#endif
	}
	
	public static func from(xsdGMTDateTimeString string: String) -> Date? {
		
		#if COOPER
            return _xsdGMTDateFormatter.parse(string)
		#else
            return _xsdGMTDateFormatter.date(from: string)
		#endif
	}
}

extension String {
		
	public static func base64CredentialString(withUsername username: String, andPassword password: String) -> String? {
		
		#if COOPER
            return okhttp3.Credentials.basic(username, password)
		
        #else
			
            let plainString = username + ":" + password
            let plainData = plainString.data(using: String.Encoding.utf8)
            guard let base64AuthStringBase = plainData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
                return nil
            }
            
            return "Basic " + base64AuthStringBase
            
		#endif
	}
	
	public var lastPathComponent: String {
		#if COOPER
            return self.substring(self.lastIndexOf("/") + 1)
		#else
            return (self as NSString).lastPathComponent
		#endif
	}
	
	public var longValue: Int64? {
		
		#if COOPER
            return try? Long.parseLong(self)
		
		#else
            return Int64(self)
		
		#endif
	}
	
	#if !COOPER
    
	public func isEmpty() -> Bool {
		return self.isEmpty
	}
    
	#endif
}

extension File {
	
	public func absolutePath() -> String {
		#if COOPER
            return self.getAbsolutePath()
		#else
            return self
        #endif
	}
	
	public func remove() -> Bool {
		#if COOPER
            return self.delete()
		#else
            return ((try? Foundation.FileManager.default.removeItem(atPath: self)) == nil) ? false : true
		#endif
	}
	
	public func extensionString() -> String {
		#if COOPER
            let filePath = self.getPath()
            let extIndex = filePath.lastIndexOf(".")
            return filePath.substring(extIndex+1)
        #else
            return (self as NSString).pathExtension
		#endif
	}
	
	public func write(fromData data: Data) throws {
		
		#if COOPER
            if (!self.exists()){
                self.createNewFile()
            }
            
            let outputChannel = try FileOutputStream(self).getChannel()
            data.position(0)
            try outputChannel.write(data)

		#else
            
            try data.write(to: URL(fileURLWithPath: self), options: [])
		#endif
	}
	
}

extension Data {
	
	public static func fromUTF8EncodedString(_ string: String) -> Data? {
		#if COOPER
            return Data.wrap(string.getBytes(StandardCharsets.UTF_8))
		#else
            return string.data(using: String.Encoding.utf8)
		#endif
	}
		
	public func toLittleEndianLong() -> Int64? {
		
		#if COOPER
	
            if (self.capacity() == 8){
                self.order(java.nio.ByteOrder.LITTLE_ENDIAN)
                return self.getLong()
            } else {
                return nil
            }

		#else
		
            if self.count == 8 {
                var longValue: Int64 = 0
                _ = self.copyBytes(to: UnsafeMutableBufferPointer(start: &longValue, count: 1))
                return longValue
            } else {
                return nil
            }
			
		#endif
	}
	
	#if COOPER
    
	public var bytes: SByteStaticArray {
	
		//apple swift doesn't allow Type[] syntax
		var bytes: SByteStaticArray
		if self.hasArray() {
			bytes = self.array()
		} else {
			bytes = java.lang.reflect.Array.newInstance(SByte.Type, self.remaining()) as! SByteStaticArray
			self.`get`(bytes as! SByteStaticArray)
		}
		
		return bytes as! SByteStaticArray
	}
    
	#endif
	
	public func toUTF8EncodedString() -> String? {
		
		#if COOPER
		
		return java.lang.String(self.bytes, StandardCharsets.UTF_8)
		
		#else
		
		return String(data: self, encoding: String.Encoding.utf8)
		
		#endif
		
	}
	
}

#if os(iOS) || os(watchOS) || os(tvOS)

extension Image {
	
	public func resizedImage(toWidth width: Int, andHeight height: Int) -> Image {
		
		#if COOPER
		
            return Bitmap.createScaledBitmap(self, width, height, false)
			
		#else
		
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.image = self
            
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
            imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let targetImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return targetImage ?? UIImage()

		#endif
		
	}
	
	public func tintedImage(toColor color: Color) -> Image {
		
		#if COOPER
		
            let paint = Paint()
            paint.setColorFilter(PorterDuffColorFilter(color, PorterDuff.Mode.SRC_IN))
		
            let targetBitmap = Bitmap.createBitmap(self.getWidth(), self.getHeight(), Config.ARGB_8888)
            let canvas = Canvas(targetBitmap)
            canvas.drawBitmap(self, 0, 0, paint)
            return targetBitmap
		
		#else
		
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            color.setFill()
            
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0);
            context.setBlendMode(CGBlendMode.normal)
            
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context.clip(to: rect, mask: self.cgImage!)
            context.fill(rect)
            
            let targetImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
            UIGraphicsEndImageContext()
            
            return targetImage
			
		#endif
	}
}
    
extension UIColor {
	
	public class func randomColor() -> UIColor {
		
		let hue = Double(arc4random() % 256) / 256.0  //  0.0 to 1.0
		let saturation = Double(arc4random() % 128) / 256.0 + 0.5;  //  0.5 to 1.0, away from white
		let brightness = Double(arc4random() % 128) / 256.0 + 0.5;
		
		return UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1.0)
	}
	
	public class func color(fromHexString hexString: String, alpha:CGFloat = 1.0) -> UIColor {
		
		let hexint = Int(_intFromHexString(hexString))
		let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
		let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
		let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
		let alpha = alpha
		
		let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
		return color
	}
	
	private class func _intFromHexString(_ hexStr: String) -> UInt32 {
		var hexInt: UInt32 = 0
		
		let scanner: Scanner = Scanner(string: hexStr)
		scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		scanner.scanHexInt32(&hexInt)
		return hexInt
	}
}
    
#endif
