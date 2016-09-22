import java.util
import java.io
import remobjects.elements.eunit


public class LakestoneTests: Test {
	
	public func synchronousHTTPRequestTest(){
		
		let jsonResourceStream = MainActivity.currentInstance.getResources().openRawResource(R.raw.raster_digitalglobe)
		guard let jsonData = try? Data.from(inputStream: jsonResourceStream),
			  var jsonResourceString = jsonData.utf8EncodedStringRepresentation
		else {
			Assert.Fail("Cannot interpret the raw resource as string")
			return
		}
		
		Assert.IsNotEmpty(jsonResourceString)
		//raw resource stream will contain extra ByteOrderMark in the beginning, remove it
		if Character.toString(jsonResourceString.characters.getItem(0)) == "\ufeff" {
			jsonResourceString = jsonResourceString.substring(1)
		}
		
		guard let rasterStyleFileURL = URL.from(string: "http://52.76.15.94/raster-digitalglobe.json") else {
			Assert.Fail("Remote resource URL has invalid format")
			return
		}
		
		let request = HTTP.Request(url: rasterStyleFileURL)
		let requestCompletionToken = TokenProvider.CreateAwaitToken()
		
		let newQueue = Threading.serialQueue(withLabel: "testQueue")
		newQueue.dispatch {
			let response = request.performSync()
			requestCompletionToken.Run(){
				
				guard let responseData = response.dataº else {
					Assert.Fail("Response data is nil while expected")
					return
				} guard let responseDataString = responseData.utf8EncodedStringRepresentation else {
					Assert.Fail("Data cannot be represented as UTF8 encoded string")
					return
				}
				
				let sanitizedResourceString = jsonResourceString.replaceAll(" ", "").replaceAll("\t", "")
				let sanitizedResponseString = responseDataString.replaceAll(" ", "").replaceAll("\t", "")
				
				Assert.AreEqual(sanitizedResourceString, sanitizedResponseString)
			}
		}
		
		requestCompletionToken.WaitFor()
	}

	public override func Teardown() {
		//MainActivity.currentInstance.finish()
	}
}