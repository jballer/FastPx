//
//  LoggedOutAccount.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/3/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit

class LoggedOutAccount: Account {
    
    override func signRequest(request: NSMutableURLRequest){
        super.signRequest(request)
    }
    override func requiredRequestParameters() -> [String:String]? {
        return ["consumer_key":ConsumerKey]
    }
}
