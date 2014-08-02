//
//  FpxAPI.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation
import UIKit

private let BASE_URL = "https://api.500px.com/v1"

let ConsumerKey = NSBundle.mainBundle().objectForInfoDictionaryKey("CONSUMER_KEY") as NSString
let ConsumerSecret = NSBundle.mainBundle().objectForInfoDictionaryKey("CONSUMER_SECRET") as NSString

private let PhotoStreamPhotoSize = "4"

class RestAPI: NSObject, NSURLSessionDelegate {

    weak var account : Account?

    init(account: Account){
        self.account = account
        super.init()
    }

    lazy var ephemeralSession : NSURLSession = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        return NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }()

    lazy var defaultSession : NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }()

    // MARK: - HTTP Interactions

    enum HTTPMethods : String{
        case GET = "GET"
        case POST = "POST"
    }

    private func queryStringToDictionary(queryString : String) -> [String:String] {
        var resultingDictionary : [String:String] = Dictionary()
        println(queryStringToDictionary)
        for keysAndValues in queryString.componentsSeparatedByString("&") {
            let splitKeysAndValues = keysAndValues.componentsSeparatedByString("=")
            if splitKeysAndValues.count > 1{
                resultingDictionary[splitKeysAndValues[0].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)] = splitKeysAndValues[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            }
        }
        return resultingDictionary
    }

    private func dictionaryToQueryString(dictionary : [String:String]) -> String {
        var parameters : [String] = Array()
        for (key, value) in dictionary {
            parameters.append("\(key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))=\(value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))")
        }
        return join("&", parameters)
    }

    private func _URLRequest(path: String, parameters: [String:String]?, method: HTTPMethods) -> NSMutableURLRequest {
        var finalParameters : [String: String] = Dictionary()
        if parameters != nil {
            finalParameters = parameters!
        }
        if let requiredParameters = account?.requiredRequestParameters() {
            for (key, value) in requiredParameters {
                finalParameters[key] = value
            }
        }
        var s = "\(BASE_URL)\(path)"
        var httpBody : NSString?
        if (finalParameters.count > 0) {
            let parametersAsString = dictionaryToQueryString(finalParameters)
            switch method {
                case .GET:
                s += "?\(parametersAsString)"
                case .POST:
                httpBody = parametersAsString
            }
        }
        let fullURL = NSURL(string: s)
        let request = NSMutableURLRequest(URL: fullURL)
        request.HTTPMethod = method.toRaw()
        if let body = httpBody {
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        return request
    }

    // MARK: oAuth/XAuth

    typealias AccessTokenResponse = (success : Bool, error : NSError?, token : NSString?, secret : NSString?) -> ()

    func requestToken(responseHandler: AccessTokenResponse){
        let request = _URLRequest("/oauth/request_token", parameters: nil, method: .POST)
        let header = OAuthorizationHeader(request.URL, request.HTTPMethod, nil, ConsumerKey, ConsumerSecret, nil, nil)
        request.setValue(header, forHTTPHeaderField: "Authorization")
        let task = ephemeralSession.dataTaskWithRequest(request) {
            (data, response, error) in
            if (error != nil) {
                println("Erro: \(error)")
                responseHandler(success: false, error: error, token: nil, secret: nil)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                let dictionary = self.queryStringToDictionary(NSString(data: data, encoding: NSUTF8StringEncoding))
                println("Got back data: \(dictionary)")
                responseHandler(success: true, error: error, token: dictionary["oauth_token"], secret: dictionary["oauth_token_secret"])
            } else {
                println("Error")
                // handle real error
            }
        }
        task.resume()
    }

    typealias XAuthResponse = (success : Bool, error : NSError?, token : NSString?, secret : NSString?) -> ()

    func authenticateWithUsername(username: String, password: String, responseHandler: XAuthResponse) {
        self.requestToken {
            (success, error, token, secret) in
            if success {
                let parameters = ["x_auth_mode": "client_auth", "x_auth_username": username, "x_auth_password": password]
                let request = self._URLRequest("/oauth/access_token", parameters: parameters, method: .POST)
                let header = OAuthorizationHeader(request.URL, request.HTTPMethod, request.HTTPBody, ConsumerKey, ConsumerSecret, token, secret)
                request.setValue(header, forHTTPHeaderField: "Authorization")
                let task = self.ephemeralSession.dataTaskWithRequest(request){
                    (data, response, error) in
                    if error {
                        println("Epic failure: \(error!)")
                    } else {
                        let stringResponse = NSString(data: data, encoding: NSUTF8StringEncoding)
                        let dictionary = self.queryStringToDictionary(stringResponse)
                        println("Got dictionary: \(dictionary)")
                        assert(dictionary["oauth_token"] != nil, "API failed to return token")
                        assert(dictionary["oauth_token_secret"] != nil, "API failed to return secret")
                        responseHandler(success: true, error: nil, token: dictionary["oauth_token"], secret: dictionary["oauth_token_secret"])
                    }
                }
                task.resume()
            } else {
                responseHandler(success: false, error: error, token: nil, secret: nil)
                println("Failure in step 2: \(error!)")
            }
        }
    }

    enum PhotoStreamType : String {
        case Popular = "popular"
        case HighestRated = "highest_rated"
        case Editors = "editors"
        case FreshToday = "fresh_today"
        case FreshYesterday = "fresh_yesterday"
        case FreshWeek = "fresh_week"
    }

    // MARK: - Photos

    typealias PhotosResponse = (success: Bool, error: NSError?, photos: NSDictionary?) -> ()

    func photos(streamType: PhotoStreamType, responseHandler: PhotosResponse) -> (Int){
        let request = _URLRequest("/photos", parameters: ["feature":streamType.toRaw(), "image_size": PhotoStreamPhotoSize], method: .GET)
        self.account!.signRequest(request)
        let task = defaultSession.dataTaskWithRequest(request) {
            (data, response, error) in
            if error {
                println("error: \(error)")
            } else {
                var parseError : NSError? = nil
                let responseDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &parseError) as NSDictionary
                if parseError != nil {
                    responseHandler(success: false, error: parseError, photos: nil)
                } else {
                    responseHandler(success: true, error: nil, photos: responseDictionary)
                }
            }
        }
        task.resume()
        return task.taskIdentifier
    }

    typealias ImageDownloadResponse = (success: Bool, error: NSError?, image: UIImage?) -> ()

    func downloadPhotoWithURL(url: String, responseHandler: ImageDownloadResponse){
        let request = NSURLRequest(URL: NSURL(string: url))
        let task = defaultSession.downloadTaskWithRequest(request, completionHandler: {
            (location, response, error) in
            if error {
                responseHandler(success: false, error: error, image: nil)
            } else {
                println("location: \(location)")
                let image = UIImage(contentsOfFile: location.path)
                responseHandler(success: true, error: nil, image: image)
            }
            })
        task.resume()
    }

}

