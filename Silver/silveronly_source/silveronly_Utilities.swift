

#if COOPER

import java.text

//apple swift doesn't allow Type[] syntax
typealias SByteStaticArray = SByte[]
typealias ByteStaticArray = Byte[]
//typealias OfflineRegionImplicitStaticArray = OfflineRegion![]

class TimezoneAdjustedDateFormat: SimpleDateFormat {
	
	public override func parse(_ string: String!, _ position: ParsePosition!) -> Date! {
		return super.parse(string.replaceFirst(":(?=[0-9]{2}$)",""), position)
	}
}

#endif