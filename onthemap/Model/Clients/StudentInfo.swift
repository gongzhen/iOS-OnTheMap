//
//  StudentInfo.swift
//  onthemap
//
//  Created by gongzhen on 3/22/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// MARK: - StudentIdentity

// identity type for student objects, aka "key" property
typealias StudentIdentity = String

struct StudentInfo {

    // MARK: Properties
    
    // student unique identifier
    let studentKey : StudentIdentity
    
    // student first name
    var firstName:String?
    
    // student last name
    var lastName:String?
    
    // any url, should be properly formed
    var mediaURL: String?
    
    // student email. excluded from raw data
    var email: String?
    
    private var _latitude: Double?
    var latitude: Double? {
        get {
            return _latitude
        }
        set {
            //@todo: validate latitude
            _latitude = newValue
        }
    }
    
    private var _longitude:Double?
    var longitude: Double? {
        get {
            return _longitude
        }
        set {
            _longitude = newValue
        }
    }
    
    // MARK: Initializers
    
    // construct a student from a dictionary
    //@todo: return nil
    init?(parsedData data: [String: AnyObject]) {
        //@todo:studentKey
        studentKey = data["uniqueKey"] as? String ?? ""
        
        firstName = data["firstName"] as? String
        lastName = data["lastName"] as? String
        mediaURL = data["mediaURL"] as? String
        latitude = data["latitude"] as? Double
        longitude = data["longitude"] as? Double
        
        //@todo:
        if studentKey.isEmpty {
            return nil
        }
    }
    
    static func studentInfosFromResults(results: [[String: AnyObject]]) -> [StudentInfo] {
        var studentInfos = [StudentInfo]()
        
        for result in results {
            studentInfos.append(StudentInfo(parsedData: result)!)
        }
        return studentInfos
    }
    
}
