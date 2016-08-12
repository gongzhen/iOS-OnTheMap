//
//  WebClient.swift
//  onthemap
//
//  Created by gongzhen on 4/1/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// WebClient
// Base Class for general interactions with any Web Service API that produces JSON data.
public class WebClient {
    
    // optional data maniupation function
    // if set will modify the data before handing it off to the parser.
    // Common Use Case: some web services include extraneous content
    // before or after the desired JSON content in response data.
    public var prepareData: ((NSData) -> NSData?)?
    
    
    // encodeParameters
    // convert dictionary to parameterized String appropriate for use in an HTTP URL
    public static func encodeParameters(params: [String: AnyObject]) -> String {
        //@todo
        let components = NSURLComponents()
        components.queryItems = [NSURLQueryItem]()
        for (key, value) in params {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        // The query URL component expressed as a URL-encoded string, or nil if not present.
        return components.percentEncodedQuery ?? ""
    }
    
    // createHttpRequestUsingMethod
    // Creates fuly configured NSURLRequest for making HTTP POST requests.
    // urlString: properly formatted URL string
    // withBody: body of the post request, not necessarily JSON or any particular format.
    // includeHeaders: field-name / value pairs for request headers.
    public func createHttpRequestUsingMethod(method: String, var forUrlString urlString: String, withBody body: NSData? = nil, includeHeaders requestHeaders: [String: String]? = nil, includeParameters requestParameters: [String: AnyObject]? = nil) -> NSURLRequest? {
        //@todo:
        if method == "GET" && body != nil {
            // handle error
            return nil
        }
        //@todo:
        if (method == "POST" || method == "PUT") && body == nil {
            // handle error
            return nil
        }
        if let requestParameters = requestParameters {
            urlString = "\(urlString)?\(WebClient.encodeParameters(requestParameters))"
        }
        if let requestUrl = NSURL(string: urlString) {
            var request = NSMutableURLRequest(URL: requestUrl)
            request.HTTPMethod = method
            if let requestHeaders = requestHeaders {
                request = addRequestHeaders(requestHeaders, toRequest: request)
            }
            if let body = body {
                request.HTTPBody = body
            }
            return request
        }
        return nil
    }
    
    // helper function adds request headers to request
    // request.addValue("application/json", forHTTPHeaderField: "Accept")
    // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    private func addRequestHeaders(requestHeaders:[String: String], toRequest request: NSMutableURLRequest) -> NSMutableURLRequest {
        let request = request
        for (field, value) in requestHeaders {
            request.addValue(value, forHTTPHeaderField: field)
        }
        return request
    }
    
    // executeRequest
    // Execute the request in a background thread, and call completionHandler when done.
    // Performs the work of checking for general errors and then
    // turning raw data into JSON data to feed to completionHandler.
    public func executeRequest(request: NSURLRequest, completionHandler:(jsonData: AnyObject?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

            guard error == nil else {
                // handle error
                return
            }
            /*
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // handle error
                return
            }
            */
            if let data = data {
                let jsonData = self.parseJsonFromData(data)
                print(jsonData)
                completionHandler(jsonData: jsonData, error: nil)
            } else {
                //@todo: handle error
                let userInfo = [NSLocalizedDescriptionKey: "executeRequest"]
                completionHandler(jsonData: nil, error: NSError(domain: "executeRequest", code: 1, userInfo: userInfo))
            }
        }
        task.resume()
    }
    
    // MARK: Private Helpers
    
    // Produces usable JSON object from the raw data.
    private func parseJsonFromData(data: NSData) -> AnyObject? {
        var mutableData = data
        if let prepareData = prepareData, modifiedData = prepareData(data) {
            mutableData = modifiedData
        }
        do {
            let jsonData : AnyObject? = try NSJSONSerialization.JSONObjectWithData(mutableData, options: .AllowFragments)
            return jsonData
        } catch {
            return nil
        }
    }
}

// MARK: - Constants

extension WebClient {    
    static let JsonContentType = "application/json"
    static let HttpHeaderAccept = "Accept"
    static let HttpHeaderContentType = "Content-Type"
}
