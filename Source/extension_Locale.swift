//
//  Locale.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 10/17/16.
//
//

#if COOPER
	import java.util
#else
	import Foundation
#endif

extension Locale {
	
	public static var preferredLanguage: String? {
		#if COOPER
			return self.getDefault().getISO3Language()
		#else
			return self.preferredLanguages.first
		#endif
	}
	
}
