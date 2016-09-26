//
//  extension_Date.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/26/16.
//
//

#if COOPER
	import java.util
	import java.text
#else
	import Foundation
#endif

#if COOPER
	
	private var _xsdGMTDateFormatter: SimpleDateFormat {
		//ISO 8601 is not handled in Java until java 7. Once available, use X instead of Z, remove replacements in xsdGMTDateTimeString below
		return SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
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
	
	#if COOPER
	//timeInterval is milliseconds stored in 64-bit signed int
	public init(timeIntervalSince1970 timeInterval: Double){
		self.init(Int64(timeInterval))
	}
	
	//timeInterval is seconds stored in double
	public var timeIntervalSince1970: Double {
		return Double(self.getTime())
	}
	
	public func addingTimeInterval(_ timeInterval: Double) -> Date {
		return java.util.Date(timeIntervalSince1970: self.timeIntervalSince1970 + timeInterval)
	}
	
	#endif

	public var xsdGMTDateTimeString: String {
		
		#if COOPER
			//ISO 8601 is not handled in Java until java 7. Once available, use X instead of Z in SimpleDateFormat, and remove replacement here
			let timeString = _xsdGMTDateFormatter.format(self.addingTimeInterval(-self.currentTimezoneOffsetFromGMT))
			return timeString.substring(0, timeString.length() - 5) + "Z";
		#else
			return _xsdGMTDateFormatter.string(from: self)
		#endif
	}
	
	public static func from(xsdGMTDateTimeString string: String) -> Date? {
		
		#if COOPER
			//ISO 8601 is not handled in Java until java 7. Once available, use X instead of Z in SimpleDateFormat, and remove replaceAll from here
			return try? _xsdGMTDateFormatter.parse(string.replaceAll("Z$", "+0000"))
		#else
			return _xsdGMTDateFormatter.date(from: string)
		#endif
	}
	
	public static func from(year: Int, month: Int, day: Int) -> Date? {
		
		#if COOPER
			let calendar = Calendar.getInstance()
			calendar.`set`(year, month - 1, day)
			calendar.`set`(Calendar.HOUR_OF_DAY, 0)
			calendar.`set`(Calendar.MINUTE, 0)
			calendar.`set`(Calendar.SECOND, 0)
			calendar.`set`(Calendar.MILLISECOND, 0)
			return calendar.getTime()
		#else
			let calendar = Calendar.current
			var components = DateComponents()
			components.year = year
			components.month = month
			components.day = day
			return calendar.date(from: components)
		#endif
	}
	
	public var currentTimezoneOffsetFromGMT: Double {
		#if COOPER
			return TimeZone.getDefault().getOffset(Int64(self.timeIntervalSince1970))
		#else
			return Double(TimeZone.current.secondsFromGMT(for: self))
		#endif
	}
}

#if COOPER
extension Date: Equatable {}
public func ==(lhs: Date, rhs: Date) -> Bool {
	return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}
#endif
