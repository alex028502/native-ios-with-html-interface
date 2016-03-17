//this is the local api that the angularjs app uses to communicate
//thanks https://www.raywenderlich.com/76735/using-nsurlprotocol-swift

/*
You can do something similar with NSURLCache, but URLProtocol can intercept
posts, puts, and deletes, which allows a full RESTful API.

I'm pretty sure these tricks are both obsolete with WKWebView's messageHandlers.

One gotcha is that, as far as I can tell, if you can only
access the post body if your custom scheme starts with http:// or https://.  So
I used http://localhost:8080/ as my protocol.  The great news is that I can use
the exact same url in my mock server that that I used for interface development.
I wouldn't be able to do this so easily if I used a scheme like donut://

*/

import UIKit

enum WebServiceError: ErrorType {
    case NoDatabaseConfigured
}

class URLProtocol: NSURLProtocol {
    static var database: Database? = nil //we inject the database as a class variable
    var connection: NSURLConnection!


    class func localAPIPrefix() -> String {
        /*
        note: http://localhost:8080 is hard coded all over the place.  This isn't
        that big a deal though since if one ever changes without changing all the
        others, the tests will probably fail.  I need to think of a good way to
        cut don't on the number of repeats of the address.
        */
        return "http://localhost:8080/api/"
    }

    class func notesAPIPrefix() -> String {
        return localAPIPrefix() + "notes"
    }

    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        return request.URL!.absoluteString.hasPrefix(URLProtocol.localAPIPrefix())
    }

    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    override func startLoading() {
        do {
            if (URLProtocol.database == nil) {
                throw WebServiceError.NoDatabaseConfigured
            }
            if (self.request.HTTPMethod == "PUT") {
                self.respond(501, jsonData: [["message":"update not implemented"],["url":self.request.URL!.absoluteString ,"method":String(self.request.HTTPMethod)]])
            } else if (self.request.HTTPMethod == "DELETE") {
                self.respond(501, jsonData: [["message":"delete not implemented"],["url":self.request.URL!.absoluteString ,"method":String(self.request.HTTPMethod)]])
            } else if (self.request.HTTPMethod == "POST" && self.request.URL!.absoluteString == self.dynamicType.notesAPIPrefix()) {
                try self.respondToPost()
            } else if (self.request.HTTPMethod == "GET" && self.request.URL!.absoluteString == self.dynamicType.notesAPIPrefix()) {
                try self.respondToGet()
            } else if (request.URL!.absoluteString.hasPrefix(URLProtocol.notesAPIPrefix())) {
                self.respond(501, jsonData: [["message":"not implemented"],["url":self.request.URL!.absoluteString ,"method":String(self.request.HTTPMethod)]])
            } else {
                self.respond(400, jsonData: [["message":"no match"],["url":self.request.URL!.absoluteString ,"method":String(self.request.HTTPMethod)]])
            }
        } catch {
            self.respond(500, jsonData: [["message":"error"],["error":String(error)]]) //TODO: check if this shows the error in a readable format
        }
    }

    func respondToGet() throws {
        self.respond(200, jsonData: self.dynamicType.database!.json())
    }

    func respondToPost() throws {
        //I think this is a weird looking message
        //we really just check for the 200
        //and expect everything to work all the time except when debugging
        //and this allows us to use the same json type as below
        let json = try NSJSONSerialization.JSONObjectWithData(self.request.HTTPBody!, options:.AllowFragments)
        self.dynamicType.database?.insert(Note(note: json["note"] as! String))
        self.respond(200, jsonData: [["message":"success"]])
    }

    //json for response is not very flexible
    //must be an array of dictionaries
    func respond(status: Int, jsonData: [[String:String]]) {
        let headers: [String: String] = ["Content-Type":"application/json"]
        let response = NSHTTPURLResponse(URL: self.request.URL!, statusCode: status, HTTPVersion: "HTTP/1.1", headerFields: headers)
        self.client?.URLProtocol(self, didReceiveResponse: response!, cacheStoragePolicy: NSURLCacheStoragePolicy.NotAllowed)
        let data = try! NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions.PrettyPrinted)
        self.client?.URLProtocol(self, didLoadData: data)
        self.client?.URLProtocolDidFinishLoading(self)
    }

    override func stopLoading() {

    }
}
