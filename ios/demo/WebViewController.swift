import UIKit

class WebViewController: UIViewController, UIWebViewDelegate{
    @IBOutlet weak var webView: UIWebView!

    var htmlFileURL: NSURL?
    var pauseForDebug = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.pauseForDebug) {
            //here we load the contents of pause.html as a string and set the
            //base url to the file that we want to load once we unpause
            //so that we can load the file we debug with location.reload
            self.webView.loadHTMLString(try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("pause", ofType: "html")!, usedEncoding: nil) as String, baseURL: self.htmlFileURL)
        } else {
            //by loading file URL and not a string, we can use location.reload() in the safari console to debug white screens
            //as well as use window.location = "<filename>" to load page from debug
            self.webView.loadRequest(NSURLRequest(URL: self.htmlFileURL!));
        }
        self.title = "html view"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.webView.stringByEvaluatingJavaScriptFromString("document.dispatchEvent(new Event('viewDidAppear'));")
    }
        
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (String(request.URL).containsString("history-modal.html")) {
            //I think this has to be done from the main queue
            dispatch_async(dispatch_get_main_queue(),{
                let historyController = TableViewController()
                
                //inject the database here
                //the web view has to know about the database protocol
                //but the history view doesn't.  So inject the database into the
                //history view as though it came from this class
                
                historyController.database = URLProtocol.database;
                self.navigationController!.pushViewController(historyController, animated: true)
            
            })
            return false
        }

        if (String(request.URL!).hasPrefix("file://") && String(request.URL!).hasSuffix(".html") && String(request.URL).containsString(".app/")) {
            //it's loading a file or string passed in
            return true
        }
        
        //otherwise open it with operating system so that we can link to external pages
        //and they don't get embedded in our app

        //It is important to make sure that no external page ever gets load in an
        //embedded browser since they would have access to the local rest api
        
        UIApplication.sharedApplication().openURL(request.URL!);
        return false;
    }
}
