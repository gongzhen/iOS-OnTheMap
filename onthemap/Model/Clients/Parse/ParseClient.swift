//
//  ParseClient.swift
//  onthemap
//
//  Created by gongzhen on 3/22/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation
import UIKit

class ParseClient : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    var studentInfos:[StudentInfo] = [StudentInfo]()
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct SingleTon {
            static var sharedInstance = ParseClient()
        }
        return SingleTon.sharedInstance
    }
    
    // MARK: GET
    
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        parameters[ParseClient.JSONResponseKeys.Order] = "-updatedAt"
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: tmdbURLFromParameters(parameters, withPathExtension: method))
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            func sendError(error: String) {
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
        
    func taskForPOSTMethod(method: String, jsonBody: String, completionHandlerForPOST:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let parameters = [String: AnyObject]()
        // let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        let request = NSMutableURLRequest(URL: tmdbURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
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
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        })
        task.resume()
        return task
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        var parsedResult : AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }        
        completionHandlerForConvertData(result: parsedResult!, error: nil)
    }

    private func tmdbURLFromParameters(parameters:[String: AnyObject], withPathExtension: String?=nil) -> NSURL {
        
        let components = NSURLComponents()
        components.host = ParseClient.Constants.ApiHost
        components.scheme = ParseClient.Constants.ApiScheme
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        if !parameters.isEmpty {
            components.queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        
        // print("url: \(components.URL!)")
        return components.URL!
    }
    
    // return account key
    func getAccountKey() -> String? {
        return UdacityClient.sharedInstance().accountKey
    }
    
}
