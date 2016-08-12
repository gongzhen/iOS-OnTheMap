//
//  ParseConvenience.swift
//  onthemap
//
//  Created by gongzhen on 3/22/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // GETting (GET) StudentLocations
    func getStudentLocations(completionHandlerForGetStudentLocations: (success: Bool, errorString: String?) -> Void) {
        let parameters = [String: AnyObject]()
        self.taskForGETMethod(ParseClient.Methods.StudentLocation, parameters: parameters, completionHandlerForGET: {
            (result: AnyObject!, error: NSError?) -> Void in
            
            if let error = error {
                completionHandlerForGetStudentLocations(success: false, errorString: "loading student locations failed. \(error)")
            } else {
                // stored the result to student objects.
                // Ambiguous reference to member 'subscript' error if using Dictionary
                if let resultArray = result["results"] as? [[String: AnyObject]] {
                    // Clear the studentInfos array before get the student locations.
                    self.studentInfos.removeAll()
                    self.studentInfos = StudentInfo.studentInfosFromResults(resultArray)
                    completionHandlerForGetStudentLocations(success: true, errorString: nil)
                } else {
                    completionHandlerForGetStudentLocations(success: false, errorString: "unable to parse students.")
                    return
                }                
            }
        })
    }
    
    func postStudentLocations(var studentInfo:[String: AnyObject], completionHandlerForPostStudentLocations: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */

        let jsonBody =  "{\"uniqueKey\": \"\(studentInfo["accountKey"]!)\", \"firstName\": \"\(studentInfo["first_name"]!)\", \"lastName\": \"\(studentInfo["last_name"]!)\",\"mapString\": \"\(studentInfo["mapString"]!)\", \"mediaURL\": \"\(studentInfo["mediaURL"]!)\",\"latitude\": \(studentInfo["latitude"]!), \"longitude\": \(studentInfo["longitude"]!)}"
        taskForPOSTMethod(ParseClient.Methods.StudentLocation, jsonBody: jsonBody, completionHandlerForPOST: { (result, error) -> Void in
            if let error = error {
                completionHandlerForPostStudentLocations(success: false, error: error)
            } else {
                let newStudentInfo = StudentInfo(
                    parsedData:[
                    "firstName":    studentInfo["first_name"]!,
                    "lastName":     studentInfo["last_name"]!,
                    "mediaURL":     studentInfo["mediaURL"]!,
                    "latitude":     studentInfo["latitude"]!,
                    "longitude":    studentInfo["longitude"]!
                    ]
                )
                self.studentInfos.insert(newStudentInfo!, atIndex: 0)
                completionHandlerForPostStudentLocations(success: true, error: nil)
            }
        })
    }
}
