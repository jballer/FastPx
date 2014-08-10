//
//  FPXKeychainWrapper.swift
//  FastPX
//
//  Created by Jonathan Ballerano on 8/9/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation
import Security

private let FPXKeychainIdentifier = "com.sandofsky.fastpx"

class FPXKeychainWrapper {
    class func getPasswordForUsername(username:String) -> String? {
        var query = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
        CFDictionaryAddValue(query, &kSecClass, &kSecClassGenericPassword)
        CFDictionaryAddValue(query, &kSecAttrAccount, username)
        CFDictionaryAddValue(query, &kSecAttrService, FPXKeychainIdentifier)

        var attributeQuery = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, query)
        var cfTrue = kCFBooleanTrue
        CFDictionaryAddValue(attributeQuery, &kSecReturnAttributes, &cfTrue)

        var result:Unmanaged<AnyObject>?
        var status = SecItemCopyMatching(attributeQuery, &result)

        if let resultData = result?.takeRetainedValue() as? NSData {
            return NSString(data: resultData, encoding: NSUTF8StringEncoding)
        } else {
            return nil
        }
    }

    class func store(username:String, password:String) {
        var status = noErr

        if let existingPassword = getPasswordForUsername(username) {
            if existingPassword == password {
                var query = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
                CFDictionaryAddValue(query, &kSecClass, &kSecClassGenericPassword)
                CFDictionaryAddValue(query, &kSecAttrService, FPXKeychainIdentifier)
                CFDictionaryAddValue(query, &kSecAttrLabel, FPXKeychainIdentifier)
                CFDictionaryAddValue(query, &kSecAttrAccount, username)

                var update = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
                var data = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                CFDictionaryAddValue(update, &kSecValueData, &data)

                var status = SecItemUpdate(query, update)
            }
        } else {
            var passwordData = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

            var query = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
            CFDictionaryAddValue(query, &kSecClass, &kSecClassGenericPassword)
            CFDictionaryAddValue(query, &kSecAttrService, FPXKeychainIdentifier)
            CFDictionaryAddValue(query, &kSecAttrLabel, FPXKeychainIdentifier)
            CFDictionaryAddValue(query, &kSecAttrAccount, username)
            CFDictionaryAddValue(query, &kSecValueData, &passwordData)

            var status = SecItemAdd(query, nil)
        }
    }
}