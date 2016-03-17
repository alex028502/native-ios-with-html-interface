import XCTest

/*
Most testing of this module is covered by the ui tests.  Those will fail if the
default 'application' is not set, for example.  However, the method that catches
attempted page loads is tested here to cover a whole bunch of possibilities.

We also test that it forwards to the correct URL here, since we couldn't figure
out how to check that it forwards to safari in the UI tests.
*/

@testable import demo

class webViewTests: XCTestCase {
    var sut: WebViewController?
    var forwardedURL: NSURL?
    
    override func setUp() {
        super.setUp()
        sut = WebViewController()
        self.forwardedURL = nil
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "forwardedToExternalURL:", name:"forwardedToExternalURL", object: nil)
        UIApplication.swizzleOpenURL()
    }
    
    func forwardedToExternalURL(notification: NSNotification){
        self.forwardedURL = (notification.userInfo as! [String:NSURL])["url"]
    }
    
    override func tearDown() {
        UIApplication.unswizzleOpenURL()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.tearDown()
    }
    
    func testLinkToExternalSiteOpensWithOSNotWebview() {
        let url = NSURL(string:"http://github.com")
        XCTAssertNil(self.forwardedURL)
        
        let result = self.tryToLoadPage(url!)
        
        XCTAssertEqual(self.forwardedURL, url)
        XCTAssertFalse(result, "should not allow webview to open external page");
    }
    
    func testOpenIndexOnSimulatorShouldWork() {
        let url = NSURL(string:"file://Users/tony/Library/Developer/CoreSimulator/Devices/9875342957/data/Containers/Bundle/Application/asdhfaskhdf/demo.app/index.html");
        XCTAssertNil(self.forwardedURL)
        
        let result = self.tryToLoadPage(url!)
        
        XCTAssertNil(self.forwardedURL)
        XCTAssertTrue(result, "should allow local file to open");
    }
    
    func testOpenIndexOnDeviceShouldWork() {
        let url = NSURL(string:"file:///var/mobile/Containers/Bundle/Application/4kgh4k/demo.app/index.html");
        XCTAssertNil(self.forwardedURL)
        
        let result = self.tryToLoadPage(url!)
        
        XCTAssertNil(self.forwardedURL)
        XCTAssertTrue(result, "should allow local file to open");
    }

    func testOpenAnotherFileOnSimulatorShouldWork() {
        let url = NSURL(string:"file://Users/tony/Library/Developer/CoreSimulator/Devices/9875342957/data/Containers/Bundle/Application/asdhfaskhdf/demo.app/otherpage.html");
        XCTAssertNil(self.forwardedURL)
        
        let result = self.tryToLoadPage(url!)
        
        XCTAssertNil(self.forwardedURL)
        XCTAssertTrue(result, "should allow local file to open");
    }
    
    func testUhOhWhatIfTheyFoolUsWithAAddressThatLooksLikeALocalFile() {
        let url = NSURL(string:"http://dodgysite.example.com/somepath.app/file://somefile.html")
        
        XCTAssertNil(self.forwardedURL)
        
        let result = self.tryToLoadPage(url!)
        
        XCTAssertEqual(self.forwardedURL, url)
        XCTAssertFalse(result, "should not allow webview to open external page");
    }
    
    //we do not test the url ...history-modal.html here since the async part makes
    //it hard to unit test, but it is easy to test in the ui tests
    
    func tryToLoadPage(url: NSURL) -> Bool {
        let request = NSURLRequest(URL:url)
        //we don't use the webview and navigation type args
        return sut!.webView(UIWebView(), shouldStartLoadWithRequest: request, navigationType: UIWebViewNavigationType.Other)
    }
    
}

public extension UIApplication {
    
    func mockOpenURL(url: NSURL) -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName("forwardedToExternalURL", object: nil, userInfo: ["url":url])
        return true
    }
    
    public class func swizzleOpenURL() {
        let originalMethod = class_getInstanceMethod(self, Selector("openURL:"))
        let swizzledMethod = class_getInstanceMethod(self, Selector("mockOpenURL:"))
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    public class func unswizzleOpenURL() {
        self.swizzleOpenURL() //swizzle and unswizzle are the same thing
        //I wonder if there is a way to check if it is the right way
    }
}
