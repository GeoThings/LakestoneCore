//
//  HTTP.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/7/16.
//
//

#if COOPER
	import java.net
	import java.io
#else
	
	import Foundation
    #if os(OSX) || os(Linux)
		import PerfectLib
		import PerfectCURL
	#endif
		
#endif

public class HTTP {
	
	public class Request {
		
		public let url: URL
		
		public init(url: URL){
			self.url = url
		}
		
		public class Error {
            static let RequestMissing = LakestoneError(StringBackedErrorType("Request is missing"))
		}
		
		public func performSync() throws -> Response {
			
            #if COOPER
				
				let currentConnection = self.url.openConnection() as! HttpURLConnection
				
				let inputStream = BufferedInputStream(currentConnection.getInputStream())
				let outputStream = ByteArrayOutputStream()
				let contentLength = currentConnection.getContentLength()
				
				
				let bytes = java.lang.reflect.Array.newInstance(Byte.Type, contentLength) as! ByteStaticArray
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
				
				
				//header values are represented in List<String> for each individual key
				//concatenate for unification-sake
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
				let (statusCode, headerBytes, bodyData) = request.performFully()
				let headerString = UTF8Encoding.encode(bytes: headerBytes)
				request.close()
                
				//parse header bytes
				var headerComponentsStrings = headerString.components(separatedBy: "\r\n").filter { !$0.isEmpty }
				if headerComponentsStrings.isEmpty {
					//possibly invalid situation when the headerBytes is empty, still returning correc
					return HTTP.Response(url: self.url, statusCode: statusCode, statusMessage: String(), headerFields: [:])
				}
                
                let statusComponents = headerComponentsStrings.removeFirst().components(separatedBy: " ")
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

				var statusMessage = String()
				if statusComponents.count == 3 {
					statusMessage = statusComponents[2]
				} else {
					print("Status line components have unexpected size: \(statusComponents.count)")
				}
				
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
				
				guard let response = targetResponseº as? HTTPURLResponse else {
					throw Error.RequestMissing
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
	
	public class Response {
		
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
