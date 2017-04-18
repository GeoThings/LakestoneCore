//
//  extension_Date.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/26/16.
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
	import java.util
	import java.text
#else
	import Foundation
#endif

#if COOPER

	private var _xsdGMTDateFormatter: SimpleDateFormat {
		//ISO 8601 is not handled in Java until java 7. Once available, use X instead of Z, remove replacements in xsdGMTDateTimeString below
		let formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")

		formatter.setTimeZone(java.util.TimeZone.getTimeZone("GMT"))
		return formatter
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
		self.init(Int64(timeInterval * 1000))
	}

	//timeInterval is seconds stored in double
	public var timeIntervalSince1970: Double {
		return Double(self.getTime()) / 1000
	}

	public func addingTimeInterval(_ timeInterval: Double) -> Date {
		return java.util.Date(timeIntervalSince1970: self.timeIntervalSince1970 + timeInterval)
	}

	#endif

	public var xsdGMTDateTimeString: String {

		#if COOPER
			//ISO 8601 is not handled in Java until java 7. Once available, use X instead of Z in SimpleDateFormat, and remove replacement here
			let timeString = _xsdGMTDateFormatter.format(self/*.addingTimeInterval(-self.currentTimezoneOffsetFromGMT)*/)
			return timeString.replacingCharacters(in: timeString.index(timeString.endIndex, offsetBy: -5) ..< timeString.endIndex, with: "Z")

		#else
			return _xsdGMTDateFormatter.string(from: self)
		#endif
	}

	public static func with(xsdGMTDateTimeString string: String) -> Date? {

		//ignore .miliseconds if passed
		let milisecondsSeperatorRangeº = string.range(of: ".", options: .backwards)

		var stringToParse = string
		if let milisecondsSeperatorRange = milisecondsSeperatorRangeº {
			stringToParse = string.substring(to: milisecondsSeperatorRange.lowerBound)
			stringToParse += "Z"
		}

		#if COOPER
			//ISO 8601 is not handled in Java until java 7. Once available, use X instead of Z in SimpleDateFormat, and remove replaceAll from here
			return _xsdGMTDateFormatter.parse(stringToParse.replacingOccurrences(of: "Z$", with: "+0000"))
		#else
			return _xsdGMTDateFormatter.date(from: stringToParse)
		#endif
	}

	public static func with(year: Int, month: Int, day: Int) -> Date? {

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
			return Double(TimeZone.getDefault().getOffset(Int64(self.timeIntervalSince1970))) / 1000
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
