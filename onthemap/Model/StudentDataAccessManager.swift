//
//  StudentDataAccessManager.swift
//  onthemap
//
//  Created by gongzhen on 4/1/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit

class StudentDataAccessManager {
    
    // udacity service operations
    private var udacityClient: UdacityService!

    // application specific operations for OnTheMap Parse Service
    private var parseClient: ParseClient!

    // user currently using data manager
    private var currentUser: StudentInfo?
    
    init() {
        udacityClient = UdacityService()
        parseClient = ParseClient()
    }
    
    /*
    authenticateByUsername(username, password, 
            |              completionHandler:(success: Bool, error: NSError?) -> Void)
            |---> udacity.authenticateByUsername(username, password,
                                |           completionHandler: (userIdentity: StudentIdentity?, error: NSError?))
                                |--->handleLoginResponse(userIdentity, error,
                                            completionHandler:(success: Bool, error: NSError?))
    
    */
    func authenticateByUsername(email: String, withPassword password: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        udacityClient.authenticateByUsername(email, withPassword: password) { (userIdentity, error) -> Void in
            self.handleLoginResponse(userIdentity, error: error, completionHandler: completionHandler) // return currentUser and success: true
        }
    }
    
    // MARK: Private Helpers
    
    // handles response after login attempt
    // userIdentity: unique key identifying the current logged user 
    // @todo: authType: the type of authentication used.
    private func handleLoginResponse(userIdentity: StudentIdentity?, error: NSError?, completionHandler:(success: Bool, error: NSError?) -> Void) {
        if let userIdentity = userIdentity {
            self.udacityClient.fetchInformationForStudentIdentity(userIdentity, completionHandler: { (studentInfo, error) -> Void in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    completionHandler(success: false, error: error)
                } else {
                    print("userIdentity: \(studentInfo)")
                    self.currentUser = studentInfo
                    completionHandler(success: true, error: nil)
                }
            })
        } else {
            completionHandler(success: false, error: error)
        }
    }
    
    func authenticateByFacebookToken() {
    
    }
    
    func storeStudentInformation() {
    
    }
    
    func deleteStudentInformation() {
    
    }
}


// MARK: - Data Translation

// store the value in the dictionary if non-nil
private func putValue(value: AnyObject?, var intoDictionary dictionary:[String: AnyObject], forKey key:String) -> [String: AnyObject] {
    if let value = value {
        dictionary[key] = value
    }
    return dictionary
}

// translate the corresponding udacity values into the same attributes with Parse service names
func translateToStudentInformationFromUdacityData(udacityData: [String: AnyObject]) -> StudentInfo? {
    var parseData = [String: AnyObject]()
    /*
    if let key = udacityData["key"] {
        parseData["uniqueKey"] = key
    }
    */
    //@todo key, first_name, last_name, email etc rewrite.
    parseData = putValue(udacityData["key"], intoDictionary: parseData, forKey: "uniqueKey")
    parseData = putValue(udacityData["first_name"], intoDictionary: parseData, forKey: "firstName")
    parseData = putValue(udacityData["last_name"], intoDictionary: parseData, forKey: "lastName")
    
    var studentInfo = StudentInfo(parsedData: parseData)
    
    if let emailDictionary = udacityData["email"] as? [String: AnyObject], emailAddress = emailDictionary["address"] as? String {
        studentInfo?.email = emailAddress
    }
    return studentInfo
}
