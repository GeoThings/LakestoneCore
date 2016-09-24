//
//  HTTP.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/7/16.
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
//  HTTP-associated set of abstractions
//

#if COOPER
	import java.net
	import java.io
#else
	
	import Foundation
	#if os(OSX) || os(Linux)
		import PerfectLib
		import PerfectCURL
		import cURL
	#endif
		
#endif

///
/// Designated class to perform a set of HTTP-related operations.
///
public class HTTP {
	
	public class Request {
		
		/// designated target of this requests
		public let url: URL
		
		public init(url: URL){
			self.url = url
		}
		
		public class Error {
			
			#if os(iOS) || os(tvOS) || os(watchOS)
			/// indicates the error in underlying invocation which results in both internally returned response objects and error being nil.
			/// Can only be thrown on iOS.
			///
			/// - remark: thrown when Foundation's session.dataTask(with:) callbacks with error and response both nil.
			///		   It is unlikely that this error will be ever thrown
			static let Unknown = LakestoneError.with(stringRepresentation: "Internal unknown invocation error")
			
			#endif
		}
		
		#if os(OSX) || os(Linux)
		
		/// Error representable type that is backend by CURL error
		public class CURLInvocationErrorType: ErrorRepresentable {
			
			let curlCode: Int
			let errorDetail: String
			init(curlCode: Int, errorDetail: String){
				self.curlCode = curlCode
				self.errorDetail = errorDetail
			}
			
			public var detailMessage: String {
				return self.errorDetail
			}
		}
		
		#endif
		
		
		/// synchronous request invocation
		/// - throws:  **Java**:
		///			`IOException` if an error occurs while opening/closing connection, reading/writing from/to designated remote.
		///			**iOS**:
		///			Wrapped `NSError` that indicates URLSession dataTask invocation error.
		///			`HTTP.Request.Error.Unknown` when URLSession error was not provided.
		///			**OSX/Linux**:
		///			`LakestoneError` with CURLInvocationError contained object that contains curlError code and its description
		///			`HTTP.Response.Error.UnexpectedEmptyHeaderData`, `HTTP.Response.Error.StatusLineFormatInvalid`
		///
		/// - returns: The response object carrying request status, http-headers, and optional data if providid
		///
		/// - warning: This will block the current thread until completed.
		///			Therefore avoid calling it on the main thread.
		public func performSync() throws -> Response {
			
			#if COOPER
				
				let currentConnection = self.url.openConnection() as! HttpURLConnection
				
				let inputStream = BufferedInputStream(currentConnection.getInputStream())
				let outputStream = ByteArrayOutputStream()
				let contentLength = currentConnection.getContentLength()
				
				let bytes = java.lang.reflect.Array.newInstance(Byte.self, contentLength) as! ByteStaticArray
				var nRead: Int
				while ( (nRead = inputStream.read(bytes, 0, contentLength)) != -1){
					outputStream.write(bytes, 0, nRead)
				}
				
				let completeData = Data.wrap(outputStream.toByteArray())
				inputStream.close()
				outputStream.close()
				
				let responseCode = currentConnection.getResponseCode()
				let responseHeaders = currentConnection.getHeaderFields()
				let responseMessage = currentConnection.getResponseMessage()
				currentConnection.disconnect()
				
				
				// header values are represented in List<String> for each individual key
				// concatenate for unification-sake
				//TODO: review whether this concatenation is neccesary
				let targetPlainHeaderDict = [String: String]()
				for entry in responseHeaders.entrySet() {
					let key = entry.getKey()
					var concatantedValues = String()
					
					for individualValue in entry.getValue() {
						concatantedValues = (concatantedValues.isEmpty()) ? individualValue : concatantedValues + ", \(individualValue)"
					}
					
					targetPlainHeaderDict[key] = concatantedValues
				}
				
				return HTTP.Response(url: self.url, statusCode: responseCode, statusMessage: responseMessage, headerFields: targetPlainHeaderDict, data: completeData) 
			
			#elseif os(OSX) || os(Linux)
				
				let request = CURL(url: self.url.absoluteString)
				let (invocationCode, headerBytes, bodyData) = request.performFully()
				let headerString = UTF8Encoding.encode(bytes: headerBytes)
				request.close()
				
				if CURLcode(rawValue: UInt32(invocationCode)) != CURLE_OK {
					throw LakestoneError(CURLInvocationErrorType(curlCode: invocationCode, errorDetail: request.strError(code: CURLcode(rawValue: UInt32(invocationCode)))))
				}
				
				var headerComponentsStrings = headerString.components(separatedBy: "\r\n").filter { !$0.isEmpty }
				if headerComponentsStrings.isEmpty {
					//curl invocation code is CURLE_OK however for header components are unexpectedly empty
					throw HTTP.Response.Error.UnexpectedEmptyHeaderData
				}
				
				let statusComponents = headerComponentsStrings.removeFirst().components(separatedBy: " ")
				guard statusComponents.count == 3,
					  let statusCode = Int(statusComponents[1])
				else {
					throw HTTP.Response.Error.StatusLineFormatInvalid
				}
				
				let statusMessage = statusComponents[2]
				let headerComponents = headerComponentsStrings.map { (headerComponentString: String) -> (String, String) in
					
					var components = headerComponentString.components(separatedBy: ":")
					if (components.count == 1){
						return (components[0].trimmingCharacters(in: CharacterSet.whitespaces), String())
					} else if (components.count == 2){
						return (components[0].trimmingCharacters(in: CharacterSet.whitespaces), components[1].trimmingCharacters(in: CharacterSet.whitespaces))
					} else if (components.count > 2){
						//handling of case when : is a part of headerValue, thus we need to concatenate it back
						let headerKey = components.removeFirst().trimmingCharacters(in: CharacterSet.whitespaces)
						let headerValue = components.joined(separator: ":").trimmingCharacters(in: CharacterSet.whitespaces)
						return (headerKey, headerValue)
					} else {
						return (String(), String())
					}
					
				}.filter { !$0.0.isEmpty }

				var headerFields = [String: String]()
				headerComponents.forEach { headerFields[$0.0] = $0.1 }
				
				return HTTP.Response(url: self.url, statusCode: statusCode, statusMessage: statusMessage, headerFields: headerFields, data: Data(bytes: bodyData))
				
			#else
				
				let request = URLRequest(url: self.url)
				let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
				
				var targetDataº: Data?
				var targetResponseº: URLResponse?
				var targetErrorº: Swift.Error?
				
				let semaphore = DispatchSemaphore(value: 0)
				let dataTask = session.dataTask(with: request){ (dataº: Data?, responseº: URLResponse?, errorº: Swift.Error?) in
					
					targetDataº = dataº
					targetResponseº = responseº
					targetErrorº = errorº
					
					semaphore.signal()
				}
				
				dataTask.resume()
				semaphore.wait()
				
				if let targetError = targetErrorº {
					throw targetError
				}
				
				// if response is nil and returned error is nil, error is not provided then
				// this should never happen, but still handling this scenario
				guard let response = targetResponseº as? HTTPURLResponse else {
					throw Error.Unknown
				}
				
				var targetHeaderFields = [String: String]()
				for (header, headerValue) in response.allHeaderFields {
					guard let headerString = header as? String,
						  let headerValueString = headerValue as? String
					else {
						print("Header field entry is not a string literal")
						continue
					}
					
					targetHeaderFields[headerString] = headerValueString
				}
				
				let statusMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
				return HTTP.Response(url: self.url, statusCode: response.statusCode, statusMessage: statusMessage, headerFields: targetHeaderFields, data: targetDataº)
				
			#endif
			
		}
	}
	
	/// Container that carries HTTP response entities
	public class Response {
		
		public class Error {
			
			#if os(OSX) || os(Linux)
			/// indicates the empty headerData received while CURL invocation returned without error
			/// Can only be thrown on Linux or OSX
			static let UnexpectedEmptyHeaderData = LakestoneError.with(stringRepresentation: "Header data is empty when expected")
			
			/// indicates the parsing failure of HTTP status line since it has invalid format
			/// Can only be thrown on Linux or OSX
			static let StatusLineFormatInvalid = LakestoneError.with(stringRepresentation: "HTTP Status line parsing failed: Invalid format")
			
			#endif
		}
		
		/// origin of this responses
		let url: URL
		let statusCode: Int
		let statusMessage: String
		let headerFields: [String: String]
		let dataº: Data?
		
		init(url: URL, statusCode: Int, statusMessage: String, headerFields: [String: String], data: Data? = nil){
			self.url = url
			self.statusCode = statusCode
			self.statusMessage = statusMessage
			self.headerFields = headerFields
			self.dataº = data
		}
	}
}
