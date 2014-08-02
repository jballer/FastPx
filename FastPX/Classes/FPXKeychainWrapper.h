//
//  FPXKeychainWrapper.h
//  FastPX
//
//  Created by Ben Sandofsky on 8/5/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPXKeychainWrapper : NSObject

+ (NSString *)getPasswordForUsername:(NSString *)username;
+ (void)storeUsername:(NSString *)username andPassword:(NSString *)password;
@end
