import XCTest

@testable import demo

class tableViewTests: XCTestCase {
    var sut: TableViewController?
    
    override func setUp() {
        super.setUp()
        sut = TableViewController()
        sut?.database = MockDatabase()
        sut?.view //thanks http://qualitycoding.org/uiviewcontroller-tdd/
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnections() {
        XCTAssertNotNil(self.sut?.tableView.delegate)
        XCTAssertNotNil(self.sut?.tableView.dataSource)
        XCTAssert(self.sut?.tableView.delegate === sut, "this is easy since we used UITableViewController, but we might want to build our own view");
        XCTAssert(self.sut?.tableView.dataSource !== sut, "hey I didn't expect that! _UIFilteredDataSource must be a wrapper that the table view controller puts around mine");
    }
    
    func testDefaults() {
        XCTAssert(sut!.tableView is UITableView);
        XCTAssertFalse(sut!.tableView is MockTableViewForCheckingRefresh, "by default we are not using mock object");
        
        sut?.tableView = MockTableViewForCheckingRefresh()
        
        XCTAssert(sut!.tableView is UITableView);
        XCTAssert(sut!.tableView is MockTableViewForCheckingRefresh, "because if we were we would get this result");
    }
    
    //start by testing a single situation but then add edge cases as they come up
    func testTableViewDelegate() {
        XCTAssertEqual(sut?.database?.select().count, 0, "just checking");
        sut?.database?.insert(Note(note:"test 0"))
        sut?.database?.insert(Note(note:"test 1"))
        sut?.database?.insert(Note(note:"test 2"))
        XCTAssertEqual(sut?.database?.select().count, 3, "just checking");
        
        XCTAssertEqual(sut?.tableView((sut?.tableView)!, numberOfRowsInSection: 0), 3);
        XCTAssertEqual(sut?.numberOfSectionsInTableView((sut?.tableView)!), 1);
        
        let lastCell = sut?.tableView((sut?.tableView)!, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0));
        
        XCTAssertEqual(lastCell!.textLabel!.text, "test 2");
        
    }
    
    func testTitle() {
        XCTAssertEqual(sut!.title, "native view");
    }
    
    func testTakeMockObjectForASpin() {
        let mockObject = MockTableViewForCheckingRefresh()
        XCTAssertFalse(mockObject.dataReloaded)
        mockObject.reloadData()
        XCTAssertTrue(mockObject.dataReloaded)
        
    }
    
    func testDelete() {
        XCTAssertEqual(sut?.database?.select().count, 0, "just checking");
        sut?.database?.insert(Note(note:"test 0"))
        sut?.database?.insert(Note(note:"test 1"))
        sut?.database?.insert(Note(note:"test 2"))
        XCTAssertEqual(sut?.database?.select().count, 3, "just checking");
        
        sut?.tableView = MockTableViewForCheckingRefresh()
        
        XCTAssertFalse((sut?.tableView as! MockTableViewForCheckingRefresh).dataReloaded, "not reloaded yet")
        
        sut?.navigationItem.rightBarButtonItem?.target?.performSelector((sut?.navigationItem.rightBarButtonItem?.action)!)

        XCTAssert((sut?.tableView as! MockTableViewForCheckingRefresh).dataReloaded, "reloaded")
        
        XCTAssertEqual(sut?.database?.select().count, 0, "should delete all items");
        
    }
    
    func testTapACell() {
        sut?.tableView = MockTableViewForCheckingDeselect()
        XCTAssertNil((sut?.tableView as! MockTableViewForCheckingDeselect).deselectedIndexPath, "control");
        XCTAssertNil((sut?.tableView as! MockTableViewForCheckingDeselect).deselectAnimated, "control");
        
        sut!.tableView((sut?.tableView)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 0))
        
        
        XCTAssertNotNil((sut?.tableView as! MockTableViewForCheckingDeselect).deselectedIndexPath, "check that it got set to something first");
        XCTAssertNotNil((sut?.tableView as! MockTableViewForCheckingDeselect).deselectAnimated, "check that it got set to something first");
        
        XCTAssertEqual((sut?.tableView as! MockTableViewForCheckingDeselect).deselectedIndexPath!.row, 3, "deselected the right row");
        XCTAssertEqual((sut?.tableView as! MockTableViewForCheckingDeselect).deselectedIndexPath!.section, 0, "deselected the right section");
        XCTAssert((sut?.tableView as! MockTableViewForCheckingDeselect).deselectAnimated == true, "animated even though it doesn't do anything");
    }
}

/*
having trouble figuring out how to make mock objects in swift
I only managed to do it by subclassing the real object.  A lot of the tests above are more about figuring out
how to make a mock object for a class that I can't just make up a protocol for.
*/

class MockTableViewForCheckingRefresh: UITableView {
    var dataReloaded = false
    override func reloadData () {
        self.dataReloaded = true
    }
}

class MockTableViewForCheckingDeselect: UITableView {
    var deselectedIndexPath: NSIndexPath?
    var deselectAnimated: Bool?
    override func deselectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        self.deselectedIndexPath = indexPath
        self.deselectAnimated = animated;
    }
}
