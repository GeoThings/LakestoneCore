import java.util
import android.app
import android.content
import android.os
import android.util
import android.view
import android.widget
import remobjects.elements.eunit

public class MainActivity : Activity {

	public override func onCreate(_ savedInstanceState: Bundle!) {
		super.onCreate(savedInstanceState)
		ContentView = R.layout.main

		print("interesting REALLY")

		let tests = Discovery.DiscoverTests(self)
		Runner.RunTests(tests, withListener: Runner.DefaultListener)
	}
}

public class MyTests: Test {
	
	public func AlwaysPass() {
		Assert.AreEqual(1, 1)
	}
	
	public func AlwaysFail() {
		Assert.AreEqual("a", "b")
	}
}