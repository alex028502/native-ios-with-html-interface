import XCTest

class demoUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    var exists: NSPredicate {
        get {
            //will create it each time we need it, but we are not in that much of a hurry
            return NSPredicate(format: "exists == 1")
        }
    }
    
    func testDefault() { //make sure that the default page loads with no params
        let app = XCUIApplication()
        app.launch()
        let instructions = app.staticTexts["Write some text in textbox:"]
        expectationForPredicate(self.exists, evaluatedWithObject: instructions, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(instructions.exists, "obviously - since we waited for it to exist")
    }

    func testAPI() {
        let app = XCUIApplication()
        app.launchArguments.append("TEST_LOCAL_API")
        app.launchArguments.append("MOCK_DATABASE")
        app.launch()
        
        let done = app.staticTexts["done!"]
        expectationForPredicate(self.exists, evaluatedWithObject: done, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(app.staticTexts["8 specs, 0 failures"].exists)
    }

    func testJS() {
        let app = XCUIApplication()
        app.launchArguments.append("UNIT_TEST_JAVASCRIPT")
        app.launch()
        
        let done = app.staticTexts["done!"]
        expectationForPredicate(self.exists, evaluatedWithObject: done, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(app.staticTexts["15 specs, 0 failures"].exists)
    }
    
    func testPauseForDebug() {
        let app = XCUIApplication()
        app.launchArguments.append("PAUSE_FOR_HTML_DEBUG")
        app.launch()
        let load_link = app.staticTexts["load page"]
        expectationForPredicate(self.exists, evaluatedWithObject: load_link, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(load_link.exists, "obviously since we would get a timeout if it didn't")
        XCTAssert(app.staticTexts["index.html"].exists, "should have filename in a span")
        load_link.tap()
        let instructions = app.staticTexts["Write some text in textbox:"]
        expectationForPredicate(self.exists, evaluatedWithObject: instructions, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(instructions.exists, "obviously - since we waited for it to exist")
    }
    
    func testPauseForDebugAlwaysShowCorrectFilename () {
        let app = XCUIApplication()
        app.launchArguments.append("PAUSE_FOR_HTML_DEBUG")
        app.launchArguments.append("TEST_LOCAL_API")
        app.launchArguments.append("MOCK_DATABASE")
        app.launch()
        let load_link = app.staticTexts["load page"]
        expectationForPredicate(self.exists, evaluatedWithObject: load_link, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        XCTAssert(load_link.exists, "obviously since we would get a timeout if it didn't")
        XCTAssert(app.staticTexts["api-test.html"].exists, "should have filename in a span")
    }
    
    func testEverything () {
        //this one was made using the recorder
        //and then modified to wait for pages to load
        //and to use a mock database
        
        //it should cover us for stuff the unit tests don't cover
        //putting it all together in the app delegate
        //and the menu
        
        //the main interface can also be tested using protractor
        //that's probably better for testing a few different possibilities
        //while this one is better for making sure it all fits together
        
        let app = XCUIApplication()
        app.launchArguments.append("MOCK_DATABASE")
        app.launch()
        
        let textField = app.otherElements["Embedded Angular"].childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.TextField).element
        let seeAll = app.buttons["see all"]
        let saveButton = app.buttons["save"]
        let entry1 = app.staticTexts["1111"];
        let entry2 = app.staticTexts["2222"];
        let entry3 = app.staticTexts["3333"];
        let entry4 = app.staticTexts["4444"];
        
        XCTAssert(app.staticTexts["html view"].exists, "main page");
        XCTAssertFalse(app.staticTexts["native view"].exists, "not history page");
        
        expectationForPredicate(self.exists, evaluatedWithObject: textField, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        XCTAssertFalse(entry1.exists, "nothing entered yet");
        XCTAssertFalse(entry2.exists);
        XCTAssertFalse(entry3.exists);
        XCTAssertFalse(entry4.exists);
        XCTAssertFalse(seeAll.exists, "only shows up when there are four entries");
        
        textField.tap()
        textField.typeText("1111") //use numerals so that auto correct doesn't mess us up
        
        expectationForPredicate(self.exists, evaluatedWithObject: entry1, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        XCTAssertTrue(entry1.exists, "appears before it is saved");
        XCTAssertFalse(entry2.exists);
        XCTAssertFalse(entry3.exists);
        XCTAssertFalse(entry4.exists);
        XCTAssertFalse(seeAll.exists, "only shows up when there are four entries");
        
        saveButton.tap()
        
        sleep(5)
        
        XCTAssertTrue(entry1.exists, "appears still there now that it is saved");
        XCTAssertFalse(entry2.exists);
        XCTAssertFalse(entry3.exists);
        XCTAssertFalse(entry4.exists);
        XCTAssertFalse(seeAll.exists, "only shows up when there are four entries");
        
        textField.tap()
        textField.typeText("2222") //use numerals so that auto correct doesn't mess us up
        saveButton.tap()
        
        sleep(5)
        
        XCTAssertTrue(entry1.exists);
        XCTAssertTrue(entry2.exists);
        XCTAssertFalse(entry3.exists);
        XCTAssertFalse(entry4.exists);
        XCTAssertFalse(seeAll.exists, "only shows up when there are four entries");

        textField.tap()
        textField.typeText("3333") //use numerals so that auto correct doesn't mess us up
        saveButton.tap()

        sleep(5)
        
        XCTAssertTrue(entry1.exists);
        XCTAssertTrue(entry2.exists);
        XCTAssertTrue(entry3.exists);
        XCTAssertFalse(entry4.exists);
        XCTAssertFalse(seeAll.exists, "only shows up when there are four entries");
       
        textField.tap()
        textField.typeText("4444") //use numerals so that auto correct doesn't mess us up
        saveButton.tap()
        
        sleep(5)
        
        XCTAssertFalse(entry1.exists, "oldest entry is hidden");
        XCTAssertTrue(entry2.exists);
        XCTAssertTrue(entry3.exists);
        XCTAssertTrue(entry4.exists);
        XCTAssertTrue(seeAll.exists, "finally shows up");
        
        seeAll.tap()
        
        expectationForPredicate(self.exists, evaluatedWithObject: app.staticTexts["native view"], handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        XCTAssertFalse(app.staticTexts["html view"].exists, "no longer on main page obviously");

        XCTAssertTrue(entry1.exists, "now we can see all four entries");
        XCTAssertTrue(entry2.exists);
        XCTAssertTrue(entry3.exists);
        XCTAssertTrue(entry4.exists);
        
        let nativeViewNavigationBar = app.navigationBars["native view"]
        nativeViewNavigationBar.buttons["html view"].tap()

        expectationForPredicate(self.exists, evaluatedWithObject: app.staticTexts["html view"], handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        XCTAssertFalse(entry1.exists, "everything as it was");
        XCTAssertTrue(entry2.exists, "everything as it was");
        XCTAssertTrue(entry3.exists, "everything as it was");
        XCTAssertTrue(entry4.exists, "everything as it was");
        XCTAssertTrue(seeAll.exists, "everything as it was");
        
        seeAll.tap()
        
        expectationForPredicate(self.exists, evaluatedWithObject: app.staticTexts["native view"], handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        XCTAssertTrue(entry1.exists, "no change");
        XCTAssertTrue(entry2.exists);
        XCTAssertTrue(entry3.exists);
        XCTAssertTrue(entry4.exists);
        
        nativeViewNavigationBar.buttons["Delete"].tap()
        
        XCTAssertFalse(entry1.exists, "all gone!");
        XCTAssertFalse(entry2.exists);
        XCTAssertFalse(entry3.exists);
        XCTAssertFalse(entry4.exists);
        
        nativeViewNavigationBar.buttons["html view"].tap()
        
        expectationForPredicate(self.exists, evaluatedWithObject: app.staticTexts["html view"], handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        //might have to wait a split second
        
        XCTAssertFalse(entry1.exists, "all gone here too!");
        XCTAssertFalse(entry2.exists);
        XCTAssertFalse(entry3.exists);
        XCTAssertFalse(entry4.exists);
        XCTAssertFalse(seeAll.exists, "so no more see all button");
    }
    
//    func testLinkToExternalSite () {
//        //This is the recording of it clicking on the link to another site
//        //and then pressing the refresh button on safari.  However, I can't get
//        //it to cooperate once it leaves our programme.  So I we can't make
//        //sure that it's opening up external links in the browser
//
//        XCUIDevice.sharedDevice().orientation = .Portrait
//        
//        let app = XCUIApplication()
//        app.staticTexts["test link"].tap()
//        XCUIDevice.sharedDevice().orientation = .Portrait
//        XCUIDevice.sharedDevice().orientation = .Portrait
//        app.buttons["ReloadButton"].tap()
//        
//    }
    
}
