//
//  UdacityService.swift
//  onthemap
//
//  Created by gongzhen on 4/1/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

class UdacityService {

    private var webClient: WebClient!
    
    init() {
        webClient = WebClient()
        // prepareData FOR ALL RESPONSES FROM THE UDACITY API, YOU WILL NEED TO SKIP THE FIRST 5 CHARACTERS OF THE RESPONSE.
        webClient.prepareData = prepareDataForParsing
    }
    
    /*
    authenticateByUsername: authenticate with username, password
    username, withPassword
    completionHandler - userIdentity: the udacity user key uniquely 
    identifying this user if login successful.
    */
    func authenticateByUsername(username: String, withPassword password:String, completionHandler:(userIdentity: StudentIdentity?, error: NSError?) -> Void) {
        // first check the basic requrements
        if username.isEmpty {
            //@todo
        }
        if password.isEmpty {
            //@todo
        }
        let httpBody:NSData = buildUdacitySessionBody(username, withPassword: password)

        authenticateUsingHttpBody(httpBody, completionHandler:completionHandler)
    }
    
    //@todo
    func authenticateByFacebookToken(httpBody: NSData, completionHandler:(userIdentity: StudentIdentity?, error: NSError?) -> Void) {
        
        
    }
    
    private func buildUdacitySessionBody(username: String, withPassword password: String) -> NSData {
        return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func authenticateUsingHttpBody(httpBody: NSData, completionHandler:(userIdentity: StudentIdentity?, error: NSError?)-> Void) {
        /* 2/3. Build the URL, configure the request. */
        // request logic is done by WebClient class.
        //@todo: method, urlstring, body, headers
        if let request = webClient.createHttpRequestUsingMethod("POST", forUrlString: "https://www.udacity.com/api/session", withBody: httpBody, includeHeaders: UdacityService.StandardHeaders) {
            webClient.executeRequest(request, completionHandler: { (jsonData, error) -> Void in

                guard error == nil else {
                    //@todo: handle error
                    completionHandler(userIdentity: nil, error: error)
                    return
                }

                //@todo account
                if let account = jsonData?.valueForKey("account") as? NSDictionary, key = account["key"] as? String {
                    completionHandler(userIdentity: key, error: nil)
                } else {
                    //@todo
                    let userInfo = [NSLocalizedDescriptionKey: "authenticateUsingHttpBody"]
                    completionHandler(userIdentity: nil, error: NSError(domain: "authenticateUsingHttpBody", code: 1, userInfo: userInfo))
                }
            })
        } else {
            //@todo
            let userInfo = [NSLocalizedDescriptionKey: "authenticateUsingHttpBody"]
            completionHandler(userIdentity: nil, error: NSError(domain: "authenticateUsingHttpBody", code: 1, userInfo: userInfo))
        }
    }
    
    // fetch available data for the user identified by userIdentity.
    
    func fetchInformationForStudentIdentity(studentIdentity: StudentIdentity, completionHandler: (studentInfo: StudentInfo?, error: NSError?) -> Void) {        
        if let request = webClient.createHttpRequestUsingMethod("GET", forUrlString: "https://www.udacity.com/api/users/\(studentIdentity)") {

            webClient.executeRequest(request, completionHandler: { (jsonData, error) -> Void in
                //@todo: constants.
                if let userObject = jsonData?.valueForKey("user") as? [String: AnyObject] {
                    // studentInfo: retrieve key, first_name, last_name
                    completionHandler(studentInfo: translateToStudentInformationFromUdacityData(userObject) , error: nil)
                } else {
                    completionHandler(studentInfo: nil, error: error)
                }
            })
        } else {
            let userInfo = [NSLocalizedDescriptionKey : "InsufficientDataLength"]
            completionHandler(studentInfo: nil, error: NSError(domain: "fetchInformationForStudentIdentity", code: 1, userInfo: userInfo))
        }
    }
    
    // closure prepareData: ((NSData) -> NSData?)? equals function
    // prepareDataForParsing(data:NSData) -> NSData?
    private func prepareDataForParsing(data: NSData) -> NSData? {
        // checking the data length before parsing.
        // @todo
        if let _ = validateUdacityLengthRequirement(data) {
            return nil
        }
        return data.subdataWithRange(NSMakeRange(5, data.length-5))
    }
    
    private func validateUdacityLengthRequirement(jsonData: NSData!) -> NSError? {
        //@todo: 5 has to be replaced by literal name.
        if jsonData.length <= 5 {
            //@todo: handle error
            let userInfo = [NSLocalizedDescriptionKey : "InsufficientDataLength"]
            return NSError(domain: "InsufficientDataLength", code: 1, userInfo: userInfo)
        } else {
            return nil
        }
    }
    
    
}

// MARK: - Constants
extension UdacityService {
    
    static var StandardHeaders: [String: String] {
        return [
            WebClient.HttpHeaderAccept:WebClient.JsonContentType,
            WebClient.HttpHeaderContentType:WebClient.JsonContentType
        ]
    }
    
}

