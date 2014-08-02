//
//  FPXKeychainWrapper.m
//  FastPX
//
//  Created by Ben Sandofsky on 8/5/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

// Copy pasta from https://github.com/ldandersen/scifihifi-iphone/blob/master/security/SFHFKeychainUtils.m

#import "FPXKeychainWrapper.h"
#import <Security/Security.h>

#define FPXKeychainIdentifier @"com.sandofsky.fastpx"

@implementation FPXKeychainWrapper

+ (NSString *)getPasswordForUsername:(NSString *)username  {

    NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass, kSecAttrAccount, kSecAttrService, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword, username, FPXKeychainIdentifier, nil];

    NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys];

    NSDictionary *attributeResult = NULL;
    NSMutableDictionary *attributeQuery = [query mutableCopy];
    [attributeQuery setObject: (id) kCFBooleanTrue forKey:(__bridge id) kSecReturnAttributes];
    CFTypeRef a = (__bridge CFTypeRef)attributeResult;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) attributeQuery, &a);

    NSData *resultData = nil;
    NSMutableDictionary *passwordQuery = [query mutableCopy];
    [passwordQuery setObject: (id) kCFBooleanTrue forKey: (__bridge id) kSecReturnData];
    CFTypeRef result = (__bridge CFTypeRef)resultData;
    status = SecItemCopyMatching((__bridge CFDictionaryRef) passwordQuery, &result);

    if (result) {
        return [[NSString alloc] initWithData: (__bridge NSData *)result encoding: NSUTF8StringEncoding];
    }
    else {
        return nil;
    }
}

+ (void)storeUsername:(NSString *)username andPassword:(NSString *)password {
    OSStatus status = noErr;

    NSString *existingPassword = [self getPasswordForUsername: username];

    if (existingPassword) {
        if (![existingPassword isEqualToString:password])
            {
        NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass,
                          kSecAttrService,
                          kSecAttrLabel,
                          kSecAttrAccount,
                          nil];

        NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword,
                             FPXKeychainIdentifier,
                             FPXKeychainIdentifier,
                             username,
                             nil];

        NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];

        status = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObject: [password dataUsingEncoding: NSUTF8StringEncoding] forKey: (__bridge NSString *) kSecValueData]);
		}
	}
	else
    {
		// No existing entry (or an existing, improperly entered, and therefore now
		// deleted, entry).  Create a new entry.

		NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass,
                          kSecAttrService,
                          kSecAttrLabel,
                          kSecAttrAccount,
                          kSecValueData,
                          nil];

		NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword,
                             FPXKeychainIdentifier,
                             FPXKeychainIdentifier,
                             username,
                             [password dataUsingEncoding: NSUTF8StringEncoding],
                             nil];

		NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];

		status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
	}
}

@end
