//
//  OAuth+Additions.swift
//  FastPX
//
//  Created by Jonathan Ballerano on 8/9/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation

extension Character {
    private func ab_uint8() -> UInt8 {
        var tmp = String(self)
        if(tmp.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 1) {
            for c in tmp.unicodeScalars {
                return UInt8(c.value)
            }
        }
        return 0
    }

    init(_ ab_uint8:UInt8) {
        self.init(UnicodeScalar(UInt32(ab_uint8)))
    }
}

extension String {
    static func ab_GUID() -> String {
        let u = CFUUIDCreate(kCFAllocatorDefault);
        let s = CFUUIDCreateString(kCFAllocatorDefault, u);
        return s as NSString
    }

    var ab_RFC3986EncodedString: String {
    get {
        var result = ""

        let c0 = UInt8("0")
        let c9 = "9".ab_uint8()
        let cA = "A".ab_uint8()
        let cZ = "Z".ab_uint8()
        let ca = "a".ab_uint8()
        let cz = "z".ab_uint8()
        let cDot = ".".ab_uint8()
        let cDash = "-".ab_uint8()
        let cTilde = "~".ab_uint8()
        let cUnderscore = "_".ab_uint8()

        for c in self.utf8 {
            switch(c) {
            case c0...c9:
                result += Character(c)
            case cA...cZ:
                result += Character(c)
            case ca...cz:
                result += Character(c)
            case cDot:
                result += Character(c)
            case cDash:
                result += Character(c)
            case cTilde:
                result += Character(c)
            case cUnderscore:
                result += Character(c)
            break;
            default:
                result += String(format: "%%%02X", c)
            }
        }
        return result;
    }
    }
}

extension NSURL {
    class func ab_parseURLQueryString(query:NSString) -> Dictionary<String,String> {
        var dict = Dictionary<String,String>()
        let pairs = query.componentsSeparatedByString("&")
        for pair in pairs {
            let keyValue = pair.componentsSeparatedByString("=")
            if keyValue.count == 2 {
                var key = keyValue[0] as String
                var value = keyValue[1] as String
                value = value.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                if key != nil && value != nil {
                    dict[key] = value
                }
            }
        }
        let immutableDict = dict
        return immutableDict
    }

    func ab_queryParameters() -> Dictionary<String,String> {
        return NSURL.ab_parseURLQueryString(self.query)
    }

    var ab_actualPath:String {
        get{
            return CFURLCopyPath(self as CFURLRef) as NSString
        }
    }
}