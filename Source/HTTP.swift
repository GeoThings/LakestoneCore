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
	import android.util
	import android.os
#else
	import Foundation
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
		
		public var method: Method = .get
		public var basicAuthentificationStringº: String? {
			didSet {
				if let basicAuthentificationString = basicAuthentificationStringº {
					self.headers["Authorization"] = "Basic \(basicAuthentificationString)"
				} else {
					self.headers["Authorization"] = nil
				}
			}
		}
		
		public var headers = [String: String]()
		public var dataº: Data?
		
		public let queue: ThreadQueue = Threading.serialQueue(withLabel: "lakestonecore.http.request.queue")
		
		#if !COOPER
		private var _downloadDelegateº: _DownloadDelegate?
		#endif
		
		// Silver is fragile with string-backed enums, plain enum in the meanwhile
		public enum Method {
			case get
			case post
			case put
		}
		
		public var methodString: String {
			switch self.method {
			case .get: return "GET"
			case .post: return "POST"
			case .put: return "PUT"
			}
		}
		
		public class Error {
			
			#if !COOPER
			/// indicates the error in underlying invocation which results in both internally returned response objects and error being nil.
			///
			/// - remark: thrown when Foundation's session.dataTask(with:) callbacks with error and response both nil.
			///		   It is unlikely that this error will be ever thrown
			static let Unknown = LakestoneError.with(stringRepresentation: "Internal unknown invocation error")
			
			static let AddingPercentEncodingWithAllowedCharacterFailure = LakestoneError.with(stringRepresentation: "Adding percent encoding with allowed character set failed")
			
			#endif
		}
		
		public func addBasicAuthentification(with username: String, and password: String){
			
			#if COOPER
				self.basicAuthentificationStringº = Base64.encodeToString("\(username):\(password)".getBytes(), 0)
			#else
				self.basicAuthentificationStringº = Data.with(utf8EncodedString: "\(username):\(password)")?.base64EncodedString()
			#endif
		}
		
		public func setJSONData(with jsonDictionary: [String: Any]) throws {
			self.dataº = try JSONSerialization.data(withJSONObject: jsonDictionary)
			self.headers["Content-Type"] = "application/json"
		}
		
		public func setFormURLEncodedData(with parameters:[String:Any]) throws {
			
			#if !COOPER
				var allowedCharacterSet = CharacterSet.urlQueryAllowed
				//if '&' is present as part of value it needs to be escaped, since non escaped '&' will be treated as key=value pair seperator
				allowedCharacterSet.remove(charactersIn: "&")
			#endif
			
			var urlEncodedString = String()
			for (keyIndex, key) in parameters.keys.enumerated() {
				guard let value = parameters[key] else {
					continue
				}
				
				#if COOPER
					
					let urlEncodedValue = URLEncoder.encode(String.derived(from: value), "UTF-8")
					let urlEncodedKey = URLEncoder.encode(key, "UTF-8")
					
				#else
					
					guard let urlEncodedValue = String.derived(from: value).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet),
						  let urlEncodedKey = key.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
					else {
						throw Error.AddingPercentEncodingWithAllowedCharacterFailure
					}
					
				#endif
				
				urlEncodedString += "\(urlEncodedKey)=\(urlEncodedValue)"
				if (keyIndex < parameters.keys.count - 1){
					urlEncodedString += "&"
				}
			}
			
			guard let encodedData = Data.with(utf8EncodedString: urlEncodedString) else {
				throw Data.Error.UTF8IncompatibleString
			}
			
			self.dataº = encodedData
			self.headers["Content-Type"] = "application/x-www-form-urlencoded"
		}
		
		public func setMutlipartFormData(with parameters: [String: Any], mimeTypes: [String: String] = [:], fileNames: [String: String] = [:]) throws {
			
			let boundary = "Boundary-\(UUID().uuidString)"
			
			var multipartString = String()
			var contentFragements = [Any]()
			for (key, value) in parameters {
				
				multipartString += "--\(boundary)\r\n"
				
				multipartString += "Content-Disposition: form-data; name=\"\(key)\";"
				if let filename = fileNames[key],value is Data {
					multipartString += "; filename=\"\(filename)\""
				}
				multipartString += "\r\n"
				
				
				if let mimeType = mimeTypes[key] {
					multipartString += "Content-Type: \(mimeType)\r\n"
				}
				multipartString += "\r\n"
				
				if let data = value as? Data {
					contentFragements.append(multipartString)
					contentFragements.append(data)
					multipartString = String()
					multipartString += "\r\n"
					
				} else {
					multipartString += "\(String.derived(from: value))\r\n"
				}
			}
			
			multipartString += "--\(boundary)--\r\n"
			
			var targetData = Data.empty
			for contentFragement in contentFragements {
				
				if let stringFragment = contentFragement as? String {
					guard let encodedData = Data.with(utf8EncodedString: stringFragment) else {
						throw Data.Error.UTF8IncompatibleString
					}
					
					targetData = targetData.appending(encodedData)
	
				} else if let partialData = contentFragement as? Data {
					targetData = targetData.appending(partialData)
					
				} else {
					#if COOPER
						let contentType = contentFragement.Class
					#else
						let contentType = type(of: contentFragement)
					#endif
					
					print("WARNING: \(#function): Unexpected content fragment type: \(contentType). Fragment ignored")
				}
			}
			
			guard let encodedRemainingFragment = Data.with(utf8EncodedString: multipartString) else {
				throw Data.Error.UTF8IncompatibleString
			}
			
			self.dataº = targetData.appending(encodedRemainingFragment)
			self.headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
		}
		
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
		
		#if COOPER
		
		public func performSync() throws -> Response {
			return try self._performSyncCore(with: nil)
		}
		
		private func _performSyncCore(with progressDelegateº: ((Bool, Double) -> Void)?) throws -> Response {
			
			let currentConnection = self.url.openConnection() as! HttpURLConnection
			do {
				
				currentConnection.setDoOutput(false)
				currentConnection.setUseCaches(false)
				currentConnection.setRequestMethod(self.methodString)
				currentConnection.setConnectTimeout(10 * 1000)
				
				for (headerKey, headerValue) in self.headers {
					currentConnection.setRequestProperty(headerKey, headerValue)
				}
				
				if self.method != .get {
					
					currentConnection.setDoInput(true)
					currentConnection.setDoOutput(true)
				
					// writing off the data
					if var data = self.dataº {
						let dataLength = data.bytes.count
						
						if Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT {
							currentConnection.setFixedLengthStreamingMode(dataLength)
						}
						
						let batchWriteSize = 16384
						var writeSize = (dataLength > 16384) ? batchWriteSize : dataLength
						
						let outputStream = BufferedOutputStream(currentConnection.getOutputStream())
						var nWritten = 0
						data.position(0)
						while nWritten < dataLength {
							let bufSize = ( (dataLength - nWritten) < writeSize) ? dataLength - nWritten : writeSize
							let writeChunk = java.lang.reflect.Array.newInstance(Byte.self, bufSize) as! ByteStaticArray
							data = data.`get`(writeChunk)
							
							outputStream.write(writeChunk)
							nWritten += bufSize
		
							let progress = Double(nWritten)/Double(dataLength)
							if progress < 1 {
								progressDelegateº?(false, progress)
							}
						}
						
						outputStream.close()
					}
				}
				
				//currentConnection.connect()
				
				let responseCode = currentConnection.getResponseCode()
				let responseHeaders = currentConnection.getHeaderFields()
				let responseMessage = currentConnection.getResponseMessage()
				
				let inputStream: InputStream
				if responseCode >= 400 {
					inputStream = BufferedInputStream(currentConnection.getErrorStream())
				} else {
					inputStream = BufferedInputStream(currentConnection.getInputStream())
				}
				
				let outputByteStream = ByteArrayOutputStream()
				var readSize = currentConnection.getContentLength()
				
				var isContentLengthAvailable = true
				let batchReadSize = 16384
				if progressDelegateº != nil && batchReadSize < readSize {
					readSize = batchReadSize
				} else if readSize < 0 {
					readSize = batchReadSize
					isContentLengthAvailable = false
				}
				
				// reading the response
				let bytes = java.lang.reflect.Array.newInstance(Byte.self, readSize) as! ByteStaticArray
				var nRead: Int
				var totalRead: Int = 0
				while ( (nRead = inputStream.read(bytes, 0, readSize)) != -1){
					outputByteStream.write(bytes, 0, nRead)
					
					totalRead += nRead
					let progress = Double(totalRead)/Double(currentConnection.getContentLength())
					
					if progress < 1 && isContentLengthAvailable {
						progressDelegateº?(true, progress)
					}
				}
				
				let completeData = Data.wrap(outputByteStream.toByteArray())
				inputStream.close()
				outputByteStream.close()
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
				
			} catch {
				currentConnection.disconnect()
				throw error
			}

		}
		
		#else
		
		public func performSync() throws -> Response {
		
			var request = URLRequest(url: self.url)
			request.httpMethod = self.methodString
			for (headerKey, headerValue) in self.headers {
				request.setValue(headerValue, forHTTPHeaderField: headerKey)
			}
			
			if self.method != .get {
				request.httpBody = self.dataº
			}
			
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
		}
		
		#endif
		
		public func perform(with progressCallbackº:((Bool, Double) -> Void)? = nil, and completionHander: @escaping (ThrowableError?, Response?) -> Void){
			
			#if COOPER
				
				self.queue.dispatch {
					
					do {
						let response = try self._performSyncCore(with: progressCallbackº)
						completionHander(nil, response)
					} catch {
						completionHander(error as! ThrowableError, nil)
					}
				}
				
			#else
				
				var request = URLRequest(url: self.url)
				request.httpMethod = self.methodString
				for (headerKey, headerValue) in self.headers {
					request.setValue(headerValue, forHTTPHeaderField: headerKey)
				}
				
				if self.method != .get {
					request.httpBody = self.dataº
				}
				
				_downloadDelegateº = _DownloadDelegate(invocationURL: self.url, progressDelegateº: progressCallbackº, completionHandler: completionHander)
				let session = URLSession(configuration: URLSessionConfiguration.default, delegate: _downloadDelegateº, delegateQueue: nil)
				let downloadTask = session.downloadTask(with: request)
				downloadTask.resume()
				
			#endif
		}
	}
	
	/// Container that carries HTTP response entities
	public class Response {
		
		public class StatusCode {
			public static let OK = 200
			public static let BadRequest = 400
			public static let Unauthorized = 401
			public static let Forbidden = 403
			public static let NotFound = 404
			public static let MethodNotAllowed = 405
			public static let NotAcceptable = 406
			public static let UnsupportedMediaType = 415
		}
				
		/// origin of this responses
		public let url: URL
		public let statusCode: Int
		public let statusMessage: String
		public let headerFields: [String: String]
		public let dataº: Data?
		
		init(url: URL, statusCode: Int, statusMessage: String, headerFields: [String: String], data: Data? = nil){
			self.url = url
			self.statusCode = statusCode
			self.statusMessage = statusMessage
			self.headerFields = headerFields
			self.dataº = data
		}
		
		public var jsonDictionaryDataº: [String: Any]? {
			
			guard let data = self.dataº else {
				return nil
			}
			
			return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
		}
		
		public var jsonArrayDataº: [Any]? {
			
			guard let data = self.dataº else {
				return nil
			}
			
			return (try? JSONSerialization.jsonObject(with: data)) as? [Any]
		}
	}
	
	#if !COOPER
	
	private class _DownloadDelegate: NSObject, URLSessionDownloadDelegate {
		
		let invocationURL: URL
		let progressDelegateº: ((Bool, Double) -> Void)?
		let completionHandler: (ThrowableError?, Response?) -> Void
		
		init(invocationURL: URL, progressDelegateº: ((Bool, Double) -> Void)?, completionHandler: @escaping (ThrowableError?, Response?) -> Void){
			self.invocationURL = invocationURL
			self.progressDelegateº = progressDelegateº
			self.completionHandler = completionHandler
		}
		
		fileprivate func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
			self.progressDelegateº?(false, Double(totalBytesSent)/Double(totalBytesExpectedToSend))
		}
		
		fileprivate func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
			
			guard let response = downloadTask.response as? HTTPURLResponse else {
				self.completionHandler(HTTP.Request.Error.Unknown, nil)
				return
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
			self.completionHandler(nil, HTTP.Response(url: self.invocationURL, statusCode: response.statusCode, statusMessage: statusMessage, headerFields: targetHeaderFields, data: FileManager.default.contents(atPath: location.path)
			))
		}
		
		fileprivate func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
			if totalBytesExpectedToWrite >= 0 {
				self.progressDelegateº?(true, Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
			}
		}
		
		fileprivate func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
			self.completionHandler(error, nil)
		}
		
		fileprivate func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
			//the actual completion callback happens in URLSession(session:, downloadTask:, didFinishDownloadingToURL:), however the error callback is here
			if let encounteredError = error {
				self.completionHandler(encounteredError, nil)
			}
		}
		
	}
	
	#endif

}
