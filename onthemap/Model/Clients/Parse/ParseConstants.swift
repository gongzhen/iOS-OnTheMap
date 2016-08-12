//
//  ParseConstants.swift
//  onthemap
//
//  Created by gongzhen on 3/22/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

extension ParseClient {

	// MARK: Constants
	struct Constants {

		// MARK: URLs
		static let ApiScheme = "https"
		static let ApiHost = "api.parse.com"
		static let ApiPath = "/1"
		static let AuthorizationURL : String = ""
	}

    //MARK: - Methods
    struct Methods {
    
        // MARK: Authentication
        static let StudentLocation = "/classes/StudentLocation"
    }	

    // MARK: JSON Response Keys

    struct JSONResponseKeys {
    	static let Order = "order"
    	static let Limit = "limit"
    	static let Skip = "skip"
    }




}