import java.util
import remobjects.elements.eunit

public class LakestoneTests: Test {
	
	/*
	public func synchronousHTTPRequestTest(){
		
		let rasterStyleFileURL = java.net.URL("http://52.76.15.94/raster-digitalglobe.json")
		let request = HTTP.Request(url: rasterStyleFileURL)
		
		let requestCompletionToken = TokenProvider.CreateAwaitToken()
		
		
		let newQueue = Threading.serialQueue(withLabel: "testQueue")
		newQueue.dispatch {
			let response = request.performSync()
			requestCompletionToken.Run(){
				
				guard let data = response.dataº else {
					Assert.Fail("Response data is nil while expected")
					return
				} guard let dataString = data.toUTF8EncodedString() else {
					Assert.Fail("Data cannot be represented as UTF8 encoded string")
					return
				}
				
				Assert.IsTrue(dataString.contains("raster-fade-duration"))
			}
		}
		
		requestCompletionToken.WaitFor()
		
	}
	*/
	
	public func lakestoneErrorTest(){
	   
		throw LakestoneError(HTTP.Request.ErrorType.RequestMissing)
		
	}
}