import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController: WebViewController?
    var navigationController: UINavigationController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.mainViewController = WebViewController()
        
        var homepage = "index"
        var database: Database = OnDiskDatabase()

        if (NSProcessInfo.processInfo().arguments.contains("MOCK_DATABASE")) {
            database = MockDatabase()
        }
        
        if (NSProcessInfo.processInfo().arguments.contains("TEST_LOCAL_API")) {
            if (!NSProcessInfo.processInfo().arguments.contains("MOCK_DATABASE")) {
                fatalError("refuse to run tests on real database")
            }
            
            homepage = "api-test"
            database.insert(Note(note: "test note 1"))
            database.insert(Note(note: "test note 2"))
        }
        
        if (NSProcessInfo.processInfo().arguments.contains("UNIT_TEST_JAVASCRIPT")) {
            if (NSProcessInfo.processInfo().arguments.contains("TEST_LOCAL_API")) {
                fatalError("TEST_LOCAL_API and UNIT_TEST_JAVASCRIPT are mutually exclusive")
            }
            homepage = "unit-test"
        }
        
        let htmlFileURL = NSBundle.mainBundle().URLForResource(homepage, withExtension: "html")
        self.mainViewController!.htmlFileURL = htmlFileURL;
        self.mainViewController?.pauseForDebug = NSProcessInfo.processInfo().arguments.contains("PAUSE_FOR_HTML_DEBUG")
        
        
        URLProtocol.database = database
        NSURLProtocol.registerClass(URLProtocol)
        
        self.navigationController = UINavigationController()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window!.rootViewController = self.navigationController
        self.navigationController?.pushViewController(self.mainViewController!, animated: false);
        
        self.window?.makeKeyAndVisible()
        return true;
    }
    
}

