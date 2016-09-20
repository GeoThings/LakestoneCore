import java.util
import android.app
import android.content
import android.os
import android.util
import android.view
import android.widget
import remobjects.elements.eunit

public class MainActivity: Activity {

	class var currentInstance: Activity!
	public override func onCreate(_ savedInstanceState: Bundle!) {
		super.onCreate(savedInstanceState)
		ContentView = R.layout.main
		
		MainActivity.currentInstance = self
		
		let tests = Discovery.DiscoverTests(self)
		Runner.RunTests(tests, withListener: Runner.DefaultListener)
		   
	}
}