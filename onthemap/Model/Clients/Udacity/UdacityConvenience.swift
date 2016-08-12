//
//  UdacityConvenience.swift
//  onthemap
//
//  Created by gongzhen on 3/18/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // Authentication (GET) Methods
    func authWithUdacity(email: String?, passwd: String?, completionHandlerForUdacityAuth: (success: Bool, errorString: String?) -> Void) {
        
        self.getSessionID (email, passwd: passwd){ (success, accountKey, errorString) -> Void in
            if success {
                // get user data
                self.getUserID(accountKey, completionHandlerForUserID: {
                    (success: Bool, errorString: String?) -> Void in
                    if success {
                        ParseClient.sharedInstance().getStudentLocations({ (success, errorString) -> Void in
                            if success {
                                completionHandlerForUdacityAuth(success: true, errorString: nil)
                            }
                        })
                    } else {
                        completionHandlerForUdacityAuth(success: false, errorString: errorString)
                    }
                })
            } else {
                completionHandlerForUdacityAuth(success: false, errorString: errorString)
            }
        }
    }
    
    private func getSessionID(email: String?, passwd: String?, completionHandlerForUdacitySession: (success: Bool, accountKey: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String: AnyObject]()
        let mutableMethod : String = Methods.AuthenticationSessionNew
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(passwd!)\"}}"
        
        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody, completionHandlerForPOST: { (result, error) -> Void in
            
            if let error = error {
                completionHandlerForUdacitySession(success: false, accountKey: nil, errorString: "SessionID failed. \(error)")
            } else {
                guard let account = result[UdacityClient.ParameterKeys.Account] as? [String: AnyObject] else {
                    completionHandlerForUdacitySession(success: false, accountKey: nil, errorString: "SessionID failed. \(error)")
                    return
                }
                
                guard let accountKey = account[UdacityClient.ParameterKeys.AccountKey] as? String else {
                    completionHandlerForUdacitySession(success: false, accountKey: nil, errorString: "SessionID failed. \(error)")
                    return
                }
                
                guard let session = result[UdacityClient.ParameterKeys.Session] as? [String: AnyObject] else {
                    completionHandlerForUdacitySession(success: false, accountKey: nil, errorString: "SessionID failed. \(error)")
                    return
                }
                
                guard let sessionID = session[UdacityClient.ParameterKeys.SessionID] as? String else {
                    completionHandlerForUdacitySession(success: false, accountKey: nil, errorString: "SessionID failed. \(error)")
                    return
                }
                self.sessionID = sessionID
                self.accountKey = accountKey
                completionHandlerForUdacitySession(success: true, accountKey: accountKey, errorString: nil)
            }
        })
    }
    
    private func getUserID(accountKey: String?, completionHandlerForUserID: (success: Bool, errorString: String?) -> Void) {
        
        let parameters = [String: AnyObject]()
        var mutableMethod : String? = UdacityClient.Methods.Users
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.ParameterKeys.AccountKey, value: accountKey!)

        taskForGETMethod(mutableMethod!, parameters: parameters, completionHandlerForGET: {
            (result: AnyObject!, error: NSError?) -> Void in
            
            if let error = error {
                completionHandlerForUserID(success: false, errorString: error.localizedDescription)
            } else {
                guard let user = result["user"] as? [String: AnyObject] else {
                    completionHandlerForUserID(success: false, errorString: "Login failed. (Cannot find user.)")
                    return
                }
                if let firstName = user["first_name"] as? String {
                    self.firstName = firstName
                }
                
                if let lastName = user["last_name"] as? String {
                    self.lastName = lastName
                }
                
                completionHandlerForUserID(success: true, errorString: nil)
            }
        })
    }
    
    func logoutUdacity(completionHandlerForLogoutSession: (success: Bool, errorString: String?) -> Void) {
        let parameters = [String : AnyObject]()
        
        taskForDELETEMethod("/session", parameters: parameters, completionHandlerForDELETE: { (result, error) -> Void in
            if let error = error {
                completionHandlerForLogoutSession(success: false, errorString: error.localizedDescription)
            } else {
                guard let session = result["session"] as? [String: AnyObject] else {
                    return
                }
                
                guard let id = session["id"] as? String else {
                    return
                }
                
                guard let expiration = session["expiration"] as? String else {
                    return
                }
                
                if id != "" && expiration != "" {
                    completionHandlerForLogoutSession(success: true, errorString: nil)
                } else {
                    completionHandlerForLogoutSession(success: false, errorString: error?.localizedDescription)
                }
            }
        })
    }
    
}
