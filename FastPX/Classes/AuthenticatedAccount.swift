//
//  AuthenticatedAccount.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/3/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit
import Foundation

private let KeychainService: NSString = "com.sandofsky.fastpx"

class AuthenticatedAccount: Account {
    private let USERNAME_KEY = "USERNAME"
    private let TOKEN_KEY = "TOKEN"
    var damaged : Bool = false // If there are issues with the keychain
    var username : String
    var token : String
    var secret : String?

    required init(coder aDecoder: NSCoder!) {
        self.username = aDecoder.decodeObjectForKey(USERNAME_KEY) as String
        self.token = aDecoder.decodeObjectForKey(TOKEN_KEY) as String
        super.init(coder: aDecoder)
        let possibleSecret = AuthenticatedAccount.pullSecretFromKeychain(self.guid)
        if possibleSecret != nil {
            self.secret = possibleSecret!
        } else {
            self.damaged = true
        }
    }

    override func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(self.username, forKey: USERNAME_KEY)
        aCoder.encodeObject(self.token, forKey: TOKEN_KEY)
        if self.secret != nil {
            self.pushSecretToKeychain(self.secret!)
        }
        super.encodeWithCoder(aCoder)
    }

    init(username: String, token: String, secret: String){
        self.username = username
        self.token = token
        self.secret = secret
        if self.username == nil || self.token == nil || self.secret == nil {
            self.damaged = true
        }
        super.init()
    }

    override var description : String! {
        get {
            return "<Account: \(self.username)>"
        }
    }
    private func pushSecretToKeychain(newSecret: String){
        FPXKeychainWrapper.storeUsername(self.guid, andPassword:newSecret)
    }

    private class func pullSecretFromKeychain(accountId: String) -> String? {
        return FPXKeychainWrapper.getPasswordForUsername(accountId)
    }

    override func signRequest(request: NSMutableURLRequest){
        super.signRequest(request)
        assert(self.secret != nil, "Attempting to sign a request with a nil secret")
        let header = OAuthorizationHeader(request.URL, request.HTTPMethod, request.HTTPBody, ConsumerKey, ConsumerSecret, self.token, self.secret!)
        request.setValue(header, forHTTPHeaderField: "Authorization")
    }
}
