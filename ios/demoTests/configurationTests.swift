import XCTest

@testable import demo

class configurationTests: XCTestCase {
    
    func testDefaultConfigurationByCheckingHostApp() {
        XCTAssert(URLProtocol.database is OnDiskDatabase, String(URLProtocol.database.dynamicType))
        XCTAssertEqual((URLProtocol.database as! OnDiskDatabase).dataFile, "productionDB.txt");
    }
}
