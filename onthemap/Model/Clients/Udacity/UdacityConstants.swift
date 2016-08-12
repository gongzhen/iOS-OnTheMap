//
//  UdacityConstants.swift
//  onthemap
//
//  Created by gongzhen on 3/19/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

extension UdacityClient {

    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = ""
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.themoviedb.org"
        static let ApiPath = ""
        static let baseSecureURL = "https://www.udacity.com/api"
    }
    
    //MARK: - Methods
    struct Methods {
    
        // MARK: Authentication
        static let AuthenticationSessionNew = "/session"
        static let Users = "/users/{key}"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let Account = "account"
        static let AccountKey = "key"
        static let Session = "session"
        static let SessionID = "id"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
    }

    // MARK: Selectors
    struct Selectors {
        static let KeyboardWillShow: Selector = "keyboardWillShow:"
        static let KeyboardWillHide: Selector = "keyboardWillHide:"
        static let KeyboardDidShow: Selector = "keyboardDidShow:"
        static let KeyboardDidHide: Selector = "keyboardDidHide:"
    }

}