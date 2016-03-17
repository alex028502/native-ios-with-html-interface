import XCTest

@testable import demo

class databaseTests: XCTestCase {
    var sut: OnDiskDatabase?
    let testDBFilename = "testDB.txt"
    
    override func setUp() {
        super.setUp()
        self.deleteDatafileIfItExists()
        sut = OnDiskDatabase(dataFile: self.testDBFilename)
        
    }
    
    func deleteDatafileIfItExists () {
        _ = try? NSFileManager.defaultManager().removeItemAtPath(OnDiskDatabase(dataFile: self.testDBFilename).dataFilePath)
    }
    
    override func tearDown() {
        self.deleteDatafileIfItExists()
        super.tearDown()
    }
    
    func testNoFileCreatedBeforeFirstSave() {
        //mainly to make sure test is set up right
        XCTAssertNotNil(sut, "just makin' sure")
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(sut!.dataFilePath))
    }
    
    func testDataFilePath() {
        //really an implementation detail that we have no business testing here
        XCTAssertNotNil(sut, "just makin' sure")
        //don't leave out the slash, but don't put two slashes in either
        XCTAssert(sut!.dataFilePath.hasSuffix("/" + self.testDBFilename), sut!.dataFilePath)
        XCTAssertFalse(sut!.dataFilePath.containsString("//"), sut!.dataFilePath)
    }
    
    func testStartsWithNoItems() {
        XCTAssertNotNil(sut, "just makin' sure")
        XCTAssertEqual(sut!.select().count, 0)
    }
    
    func testAddTwoItemsAndCheck() {
        XCTAssertNotNil(sut, "just makin' sure")
        sut!.insert(Note(note: "test note 0"))
        sut!.insert(Note(note: "test note 1"))
        XCTAssertEqual(sut!.select().count, 2)
        XCTAssertEqual(sut!.select()[0].note, "test note 0")
        XCTAssertEqual(sut!.select()[1].note, "test note 1")
    }
    
    func testSavedToDisk() {
        XCTAssertNotNil(sut, "just makin' sure")
        sut!.insert(Note(note: "test note"))
        XCTAssert(NSFileManager.defaultManager().fileExistsAtPath(sut!.dataFilePath), "implementation detail")
        let newSut = OnDiskDatabase(dataFile: self.testDBFilename)
        XCTAssertEqual(newSut.select().count, 1)
        XCTAssertEqual(newSut.select()[0].note, "test note")
    }
    
    func testNotForMultiLineNotes() {
        //if you need multi line notes, start by correcting this test
        //(switching the asserts around)
        
        XCTAssertNotNil(sut, "just makin' sure")
        sut!.insert(Note(note: "test note 0\nmore test note 0"))
        sut!.insert(Note(note: "test note 1"))
        XCTAssertNotEqual(sut!.select().count, 2, "reverse this assert if you want muliline notes")
        XCTAssertEqual(sut!.select().count, 3, "delete this assert if you want multiline notes")
        XCTAssertNotEqual(sut!.select()[0].note, "test note 0\nmore test note 0", "reverse for multiline notes")
        XCTAssertNotEqual(sut!.select()[1].note, "test note 1", "reverse for multiline notes")
        
        XCTAssertEqual(sut!.select()[0].note, "test note 0", "delete for multiline")
        XCTAssertEqual(sut!.select()[1].note, "more test note 0", "delete for multiline")
        XCTAssertEqual(sut!.select()[2].note, "test note 1", "delete for multiline")
    }
    
    func testDeleteAll() {
        XCTAssertNotNil(sut, "just makin' sure")
        sut!.insert(Note(note: "test note 0"))
        sut!.insert(Note(note: "test note 1"))
        XCTAssertEqual(sut!.select().count, 2, "just makin' sure");
        sut!.deleteAll()
        XCTAssertEqual(sut!.select().count, 0, "delete from this instance");
        let newSut = OnDiskDatabase(dataFile: self.testDBFilename)
        XCTAssertEqual(newSut.select().count, 0, "delete for good")
        
    }
    
}
