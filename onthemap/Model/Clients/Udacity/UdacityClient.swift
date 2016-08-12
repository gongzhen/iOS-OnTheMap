//
//  UdacityClient.swift
//  onthemap
//
//  Created by gongzhen on 3/18/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// MARK: - OnTheMapClient: NSObject

class UdacityClient: NSObject {
    
    // MARK: Properties
    var accountKey: String?
    var sessionID: String?
    var firstName: String?
    var lastName: String?
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct SingleTon {
            static var sharedInstance = UdacityClient()
        }
        return SingleTon.sharedInstance
    }
    
    // MARK: GET

    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = UdacityClient.Constants.baseSecureURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        })
        
        task.resume()
        return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        
        /* 2/3. Build the URL, configure the request. */
        // let request = NSMutableURLRequest(URL: tmdbURLFromParameters(parameters, withPathExtension: nil))
        let urlString = UdacityClient.Constants.baseSecureURL + method
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)

        /*4. Make the request */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: error */
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        })        
        task.resume()
        return task
    }
    
    // MARK: DELETE
    
    func taskForDELETEMethod(method: String, var parameters:[String: AnyObject], completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        
        /* 2/3. Build the URL, configure the request. */
        let urlString = UdacityClient.Constants.baseSecureURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "DELETE"
        /* 4. Find the cookie */
        var xsrfCookie : NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForDELETE(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: error */
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForDELETE)            
        })
        task.resume()
        return task
    }
    
    // MARK: Helpers
    
    // create a URL from parameters
    private func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        return components.URL!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
        
        var parsedResult : AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

        completionHandlerForConvertData(result: parsedResult!, error: nil)
    }
    
    // substitute the key for the value that is contained within the method name
    
    class func subtituteKeyInMethod(method: String?, key: String, value: String) -> String? {
    
        guard let _ = method?.rangeOfString("{\(key)}") else {
            return method
        }
        return method?.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
    }
}
