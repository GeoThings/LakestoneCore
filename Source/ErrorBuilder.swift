//
//  ErrorBuilder.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 5/31/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

public class ErrorBuilder {
	
	#if !COOPER
	public enum CoreError: Error {
		case InvalidURLFormat
		case NoURLPresent
		case NoSuchFile
		case CouldNotCreateFile
		case InternalErrorRequiredParameterNil
		case CouldNotAuthenticate
		
		case RequiredAttributeIsNotPresent
		case DataIsNilOrSerializationFailure
		
		case FileNotFoundOnServerOrServerRejectedRequest
		case GenericError
		
		case OfflineDownloadIsNotInitialized
		case OfflineDownloadAlreadyStarted
		case OfflineDownloadRegionIsNilWhenExpected
		
		case PropertyListDoesntContainFullObjectRepresentation
		
		case GeneralConversionError
		case GeneralEncodingError
		case FileParsingFailed
		case BytesDataIsNotProperXML
		case XMLWritingFailure
		
		case ResponseMissing
		case NoDataInResponse
		
		case EntityIsNotRecognized
		case UserNotLoggedIn
		
		case TaskIsRunningAlready
		case PartialSubmissionFailure
		
		case ChangesetIsNotOpened
		case OriginalNodeIsNotFoundForModified
		case UpdateConflict
		
		case ChangesetIsNotIdle
		case CantRetrieveURLQueryAllowedCharacterSet
		case StringByAddingPercentEncodingWithAllowedCharacterFailure
		case DataUsingASCIIEncodingSerializationFailure
		
		case GeneralRegistrationError
		case FatalRuntimeError
		
		
		//the following string-based utility is prefered to fully enum-based alternative, since Silver enums has dosens of problems in Java
		static func from(errorDescription string: String) -> CoreError {
			let errorDescriptionUnspaced = string.replacingOccurrences(of: " ", with: "").lowercased()
			
			switch (errorDescriptionUnspaced) {
			case "InvalidURLFormat".lowercased():
				return .InvalidURLFormat
			case "NoSuchFile".lowercased():
				return .NoSuchFile
			case "CouldNotCreateFile".lowercased():
				return .CouldNotCreateFile
			case "InternalErrorRequiredParameterNil".lowercased():
				return .InternalErrorRequiredParameterNil
			case "CouldNotAuthenticate".lowercased():
				return .CouldNotAuthenticate
			case "RequiredAttributeIsNotPresent".lowercased():
				return .RequiredAttributeIsNotPresent
			case "DataIsNilOrSerializationFailure".lowercased():
				return .DataIsNilOrSerializationFailure
			case "FileNotFoundOnServerOrServerRejectedRequest".lowercased():
				return .FileNotFoundOnServerOrServerRejectedRequest
			case "OfflineDownloadIsNotInitialized".lowercased():
				return .OfflineDownloadIsNotInitialized
			case "OfflineDownloadAlreadyStarted".lowercased():
				return .OfflineDownloadAlreadyStarted
			case "OfflineDownloadRegionIsNilWhenExpected".lowercased():
				return .OfflineDownloadRegionIsNilWhenExpected
			case "PropertyListDoesntContainFullObjectRepresentation".lowercased():
				return .PropertyListDoesntContainFullObjectRepresentation
			case "GeneralEncodingError".lowercased():
				return .GeneralEncodingError
			case "FileParsingFailed".lowercased():
				return .FileParsingFailed
			case "BytesDataIsNotProperXML".lowercased():
				return .BytesDataIsNotProperXML
			case "ResponseMissing".lowercased():
				return .ResponseMissing
			case "NoDataInResponse".lowercased():
				return .NoDataInResponse
			case "XMLWritingFailure".lowercased():
				return .XMLWritingFailure
			case "UserNotLoggedIn".lowercased():
				return .UserNotLoggedIn
			case "EntityIsNotRecognized".lowercased():
				return .EntityIsNotRecognized
			case "TaskIsRunningAlready".lowercased():
				return .TaskIsRunningAlready
			case "PartialSubmissionFailure".lowercased():
				return .PartialSubmissionFailure
			case "ChangesetIsNotOpened".lowercased():
				return .ChangesetIsNotOpened
			case "GeneralConversionError".lowercased():
				return .GeneralConversionError
			case "OriginalNodeIsNotFoundForModified".lowercased():
				return .OriginalNodeIsNotFoundForModified
			case "UpdateConflict".lowercased():
				return .UpdateConflict
			case "ChangesetIsNotIdle".lowercased():
				return .ChangesetIsNotIdle
			case "CantRetrieveURLQueryAllowedCharacterSet".lowercased():
				return .CantRetrieveURLQueryAllowedCharacterSet
			case "GeneralRegistrationError".lowercased():
				return .GeneralRegistrationError
			case "FatalRuntimeError".lowercased():
				return .FatalRuntimeError
			default: return .GenericError
			}
		}
	}
	#endif
	
	public class func from(errorDescription string: String) -> Error {
		#if COOPER
		return Exception(string)
		#else
		return CoreError.from(errorDescription: string)
		#endif
	}
}
