//
//  OfflineTileManager.swift
//  geoBingAnCore
//
//  Created by Taras Vozniuk on 5/31/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
	import okhttp3
	import java.io
	import android.os
	import java.net
#else
	import Foundation
#endif

public protocol HTTPClientDelegate {
	func client(_ client: HTTPClient, didRecieveDataChunkWithSize size: Int64, totalWritten: Int64, totalExpected: Int64)
}

public class HTTPClient {

	#if !COOPER
	lazy private var _sessionDelegate: URLSessionDelegate = {
		return URLSessionDelegate(httpClient: self)
	}()
	#endif
	
	private var _completionHandlerº: ((Response?, Data?, Error?) -> Void)?
	private var _downloadTaskCompletionHandlerº: ((Response?, String?, Error?) -> Void)?
	
	
	private var _fetchURLº: URL?

	public var basicAuthentificationStringº: String?
	public var delegateº: HTTPClientDelegate?
	
	public init(){ }
	
	public init(basicAuthentificationString: String){
		self.basicAuthentificationStringº = basicAuthentificationString
	}
	
	public func performPutRequest(withURL url: URL, andData data: Data, ofMediaType mediaTypeString: String, completionHandler: ((Response?, Data?, Error?) -> Void)? ) {
		
		_completionHandlerº?(nil, nil, nil)
		_completionHandlerº = completionHandler
		_fetchURLº = url
		
		#if COOPER
		
			let httpClient = OkHttpClient()
			let requestBuilder = Request.Builder().url(url)
			if let basicAuthentificationString = self.basicAuthentificationStringº {
				requestBuilder.header("Authorization", basicAuthentificationString)
			}
			
			let mediaType = MediaType.parse(mediaTypeString)
			requestBuilder.put(RequestBody.create(mediaType, data.bytes))
			let request = requestBuilder.build()
			
			do {
				try httpClient.newCall(request).enqueue(self)
			} catch {
				completionHandler(nil, nil, error as? Error)
			}
		
		#else
		
		var request = URLRequest(url: url)
		request.setValue(mediaTypeString, forHTTPHeaderField: "Content-Type")
		request.httpMethod = "PUT"
		request.httpBody = data
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			request.setValue(basicAuthentificationString, forHTTPHeaderField: "Authorization")
		}
			
		let sessionConfiguration = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfiguration, delegate: _sessionDelegate, delegateQueue: nil)
		let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (dataº:NSData?, responseº:NSURLResponse?, errorº:NSError?) in
			self._completionHandlerº?(responseº: responseº, dataº: dataº, errorº: errorº)
		}
		
		dataTask.resume()
		
		#endif
	}
	
	public func performPostRequest(withURL url: URL, andURLEncodedArguments urlArguments: [String: String], ofMediaType mediaTypeString: String,completionHandler: (_ responseº: Response?, _ dataº: Data?, _ errorº: Error?) -> Void) {
	
		_completionHandlerº = completionHandler
		_fetchURLº = url
		
		
		#if COOPER
		
		let httpClient = OkHttpClient()
		let requestBuilder = Request.Builder().url(url)
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			requestBuilder.header("Authorization", basicAuthentificationString)
		}
			
		//let mediaType = MediaType.parse(mediaTypeString)
		let requestBody = FormBody.Builder()
		for (argumentKey, argumentValue) in urlArguments {
			requestBody.add(argumentKey, argumentValue)
		}
		
		let formBody = requestBody.build()
		let request = requestBuilder.post(formBody).build()
		
		do {
			try httpClient.newCall(request).enqueue(self)
		} catch {
			completionHandler(nil, nil, error as? Error)
		}
		
		#else
		
		let urlEncodedData: Data
		do {
			urlEncodedData = try _urlEncodedData(with: urlArguments)
		} catch {
			completionHandler(responseº: nil, dataº: nil, errorº: error as! Error)
			return
		}
			
		let request = NSMutableURLRequest(URL: url)
		request.setValue(mediaTypeString, forHTTPHeaderField: "Content-Type")
		request.HTTPMethod = "POST"
		request.HTTPBody = urlEncodedData
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			request.setValue(basicAuthentificationString, forHTTPHeaderField: "Authorization")
		}
			
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfiguration, delegate: _sessionDelegate, delegateQueue: nil)
		let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (dataº:NSData?, responseº:NSURLResponse?, errorº:NSError?) in
			self._completionHandlerº?(responseº: responseº, dataº: dataº, errorº: errorº)
		}
		
		dataTask.resume()
		
		#endif
	}
	
	
	public func performPostRequest(withURL url: URL, andData data: Data, ofMediaType mediaTypeString: String, completionHandler: (_ responseº: Response?, _ dataº: Data?, _ errorº: Error?) -> Void) {
		
		_completionHandlerº = completionHandler
		_fetchURLº = url
		
		#if COOPER
			
			let httpClient = OkHttpClient()
			let requestBuilder = Request.Builder().url(url)
			if let basicAuthentificationString = self.basicAuthentificationStringº {
				requestBuilder.header("Authorization", basicAuthentificationString)
			}
			
			let mediaType = MediaType.parse(mediaTypeString)
			requestBuilder.post(RequestBody.create(mediaType, data.bytes))
			let request = requestBuilder.build()
			
			do {
				try httpClient.newCall(request).enqueue(self)
			} catch {
				completionHandler(nil, nil, error as? Error)
			}
			
		#else
			
			let request = NSMutableURLRequest(URL: url)
			request.setValue(mediaTypeString, forHTTPHeaderField: "Content-Type")
			request.HTTPMethod = "POST"
			request.HTTPBody = data
			if let basicAuthentificationString = self.basicAuthentificationStringº {
				request.setValue(basicAuthentificationString, forHTTPHeaderField: "Authorization")
			}
			
			let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
			let session = NSURLSession(configuration: sessionConfiguration, delegate: _sessionDelegate, delegateQueue: nil)
			let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (dataº:NSData?, responseº:NSURLResponse?, errorº:NSError?) in
				self._completionHandlerº?(responseº: responseº, dataº: dataº, errorº: errorº)
			}
			
			dataTask.resume()
			
		#endif
	}
	
	public func performEmptyPutRequest(withURL url: URL, completionHandler: (_ responseº: Response?, _ dataº: Data?, _ errorº:Error?) -> Void) {
		
		_completionHandlerº = completionHandler
		_fetchURLº = url
		
		#if COOPER
			
		let httpClient = OkHttpClient()
		let requestBuilder = Request.Builder().url(url)
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			requestBuilder.header("Authorization", basicAuthentificationString)
		}
			
		let request = requestBuilder.build()
			
		do {
			try httpClient.newCall(request).enqueue(self)
		} catch {
			completionHandler(nil, nil, error as? Error)
		}
			
		#else
			
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "PUT"
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			request.setValue(basicAuthentificationString, forHTTPHeaderField: "Authorization")
		}
			
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfiguration, delegate: _sessionDelegate, delegateQueue: nil)
		let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (dataº:NSData?, responseº:NSURLResponse?, errorº:NSError?) in
			self._completionHandlerº?(responseº: responseº, dataº: dataº, errorº: errorº)
		}
		
		dataTask.resume()
			
		#endif

	}
	
	public func performDownloadRequest(withURL url: URL, completionHandler: (_ responseº: Response?, _ filePathº: String?, _ errorº:Error?) -> Void){
		
		_fetchURLº = url
		_downloadTaskCompletionHandlerº = completionHandler
		
		#if COOPER
			
		let httpClient = OkHttpClient()
		let requestBuilder = Request.Builder().url(url)
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			requestBuilder.header("Authorization", basicAuthentificationString)
		}
			
		let request = requestBuilder.build()
			
		do {
			try httpClient.newCall(request).enqueue(self)
		} catch {
			completionHandler(nil, nil, error as? Error)
		}
			
		#else
			
		let request = NSMutableURLRequest(URL: url)
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			request.setValue(basicAuthentificationString, forHTTPHeaderField: "Authorization")
		}
			
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfiguration, delegate: _sessionDelegate, delegateQueue: nil)
		let downloadTask: NSURLSessionDownloadTask = session.downloadTaskWithURL(url)
		downloadTask.resume()
		
		#endif
	}
	
	public func performRequest(withURL url: URL, completionHandler: (_ responseº: Response?, _ dataº: Data?, _ errorº:Error?) -> Void)   {
		_completionHandlerº = completionHandler
		_fetchURLº = url
		
		#if COOPER
			
		let httpClient = OkHttpClient()
		let requestBuilder = Request.Builder().url(url)
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			requestBuilder.header("Authorization", basicAuthentificationString)
		}
			
		let request = requestBuilder.build()
			
		do {
			try httpClient.newCall(request).enqueue(self)
		} catch {
			completionHandler(nil, nil, error as? Error)
		}
			
		#else
			
		let request = NSMutableURLRequest(URL: url)
		if let basicAuthentificationString = self.basicAuthentificationStringº {
			request.setValue(basicAuthentificationString, forHTTPHeaderField: "Authorization")
		}
			
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfiguration, delegate: _sessionDelegate, delegateQueue: nil)
		let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (dataº:NSData?, responseº:NSURLResponse?, errorº:NSError?) in
			self._completionHandlerº?(responseº: responseº, dataº: dataº, errorº: errorº)
		}
			
		dataTask.resume()
			
		#endif
	}
	
	//MARK: Utilities
	
	#if !COOPER
	private func _urlEncodedData(with argumentDictionary:[String:String]) throws -> Data {
		
		guard let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as? NSMutableCharacterSet else {
			throw ErrorBuilder.Error.CantRetrieveURLQueryAllowedCharacterSet
		}
		
		allowedCharacterSet.removeCharactersInString("&")
		
		var urlEncodedString = String()
		for (keyIndex, key) in argumentDictionary.keys.enumerate() {
			if let value = argumentDictionary[key] {
				
				guard let urlEncodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) else {
					throw ErrorBuilder.Error.StringByAddingPercentEncodingWithAllowedCharacterFailure
				}
				
				urlEncodedString += "\(key)=\(urlEncodedValue)"
				if (keyIndex < argumentDictionary.keys.count - 1){
					urlEncodedString += "&"
				}
			}
		}
		
		guard let data = urlEncodedString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true) else {
			throw ErrorBuilder.Error.DataUsingASCIIEncodingSerializationFailure
		}
		
		return data
	}
	#endif

}

#if COOPER
#else

class URLSessionDelegate: NSObject, NSURLSessionDownloadDelegate {
	
	private var _httpClient: HTTPClient
	
	init(httpClient: HTTPClient){
		_httpClient = httpClient
	}
	
	public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
		_httpClient._downloadTaskCompletionHandlerº?(responseº: downloadTask.response, filePathº: location.path, errorº: nil)
	}
	
	public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
		_httpClient.delegateº?.client(_httpClient, didRecieveDataChunkWithSize: bytesWritten, totalWritten: totalBytesWritten, totalExpected: totalBytesExpectedToWrite)
	}
	
	func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
		_httpClient._downloadTaskCompletionHandlerº?(responseº: nil, filePathº: nil, errorº: error)
	}
	
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		//the actual completion callback happens in URLSession(session:, downloadTask:, didFinishDownloadingToURL:), however the error callback proceeds from here
		if let causedError = error {
			_httpClient._downloadTaskCompletionHandlerº?(responseº: nil, filePathº: nil, errorº: error)
		}
	}
}
	
	
#endif
	

#if COOPER

extension HTTPClient:Callback {
	
	public func onFailure(_ arg1: Call!, _ arg2: IOException!){
		_completionHandlerº?(nil, nil, arg2)
	}
	
	public func onResponse(_ arg1: Call!, _ arg2: Response!){
		_completionHandlerº?(arg2, Data.wrap(arg2.body().bytes()), nil)
	}
}

#endif
