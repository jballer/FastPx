//
//  OAuthCore.swift
//  FastPX
//
//  Created by Jonathan Ballerano on 8/9/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation

private func sortParameter(key1:NSString, key2:NSString, context:AnyObject?) -> NSComparisonResult! {
    let result = key1.compare(key2)
    switch result {
    case .OrderedSame:
        let dict = context as NSDictionary
        let val1 = dict[key1] as String
        let val2 = dict[key2] as String
        return val1.compare(val2)
    default:
        return result
    }
}

private func HMAC_SHA1(data:String, key:String) -> NSData {
    var buffer = NSMutableData(capacity: Int(CC_SHA1_DIGEST_LENGTH))
    let keyD = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    let dataD = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    CCHmac(UInt32(kCCHmacAlgSHA1), keyD.bytes, UInt(keyD.length), dataD.bytes, UInt(dataD.length), buffer.mutableBytes)
    return NSData(data: buffer)
}


public func OAuthorizationHeader(
    url:NSURL,
    method:String,
    body:NSData?,
    oAuthConsumerKey:String,
    oAuthConsumerSecret:String,
    oAuthToken:String?,
    oAuthTokenSecret:String?) -> String? {
    return OAuthorizationHeaderWithCallback(url, method, body, oAuthConsumerKey, oAuthConsumerSecret, oAuthToken, oAuthTokenSecret, nil)
}

public func OAuthorizationHeaderWithCallback(
    url:NSURL,
    method:String,
    body:NSData?,
    _oAuthConsumerKey:String,
    _oAuthConsumerSecret:String,
    _oAuthToken:String?,
    _oAuthTokenSecret:String?,
    _oAuthCallback:String?) -> String? {

        var oAuthAuthorizationParameters = [
            "oauth_nonce": String.ab_GUID(),
            "oauth_timestamp": NSString(format: "%d", NSDate.timeIntervalSinceReferenceDate()),
            "oauth_signature_method":"HMAC-SHA1",
            "oauth_version":"1.0",
            "oauth_consumer_key":_oAuthConsumerKey
        ]
        if let token = _oAuthToken {
            oAuthAuthorizationParameters["oauth_token"] = token
        }
        if let callback = _oAuthCallback {
            oAuthAuthorizationParameters["oauth_callback"] = callback
        }

        // get query and body parameters
        let additionalQueryParameters = url.ab_queryParameters()
        var additionalBodyParameters = Dictionary<String,String>()

        if let bodyData = body {
            let string = NSString(data: bodyData, encoding: NSUTF8StringEncoding)
            additionalBodyParameters = NSURL.ab_parseURLQueryString(string)
        }

        // combine all parameters
        var parameters = oAuthAuthorizationParameters
        for (k,v) in additionalQueryParameters {
            parameters[k] = v
        }
        for(k,v) in additionalBodyParameters {
            parameters[k] = v
        }

        // -> UTF-8 -> RFC3986
        var encodedParameters = Dictionary<String,String>()
        for (k,v) in parameters {
            encodedParameters[k] = v.ab_RFC3986EncodedString
        }

        var sortedKeys = encodedParameters.keys.array
        sortedKeys.sort {sortParameter($0, $1, encodedParameters) != NSComparisonResult.OrderedDescending}

        var parameterArray = [String]()
        for key in sortedKeys {
            parameterArray.append("\(key)=\(encodedParameters[key])")
        }

        let normalizedParameterString = NSArray(array: parameterArray).componentsJoinedByString("&")

        var portStr = url.port != nil ? ":\(url.port)" : ""
        let normalizedURLString = "\(url.scheme)://\(url.host)\(portStr)\(url.ab_actualPath)"

        let signatureBaseString = "\(method.ab_RFC3986EncodedString)&\(normalizedURLString.ab_RFC3986EncodedString)&\(normalizedParameterString.ab_RFC3986EncodedString)"

        let key = "\(_oAuthConsumerSecret.ab_RFC3986EncodedString)&\(_oAuthTokenSecret?.ab_RFC3986EncodedString)"

        let signature = HMAC_SHA1(signatureBaseString, key)
        let base64Signature = signature.base64EncodedStringWithOptions(nil)

        var authorizationHeaderDictionary = oAuthAuthorizationParameters
        authorizationHeaderDictionary["oauth_signature"] = base64Signature

        var authorizationHeaderItems = [String]()
        for (key,value) in authorizationHeaderDictionary {
            authorizationHeaderItems.append("\(key.ab_RFC3986EncodedString)=\(value.ab_RFC3986EncodedString)")
        }

        var authorizationHeaderString = (authorizationHeaderItems as NSArray).componentsJoinedByString(", ")
        authorizationHeaderString = "OAuth \(authorizationHeaderString)"

        return authorizationHeaderString
}