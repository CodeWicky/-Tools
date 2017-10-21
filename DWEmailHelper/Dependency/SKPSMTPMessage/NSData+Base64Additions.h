//
//  NSData+Base64Additions.h
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSData (Base64Additions)

+(id)decodeBase64ForString:(NSString *)decodeString;
+(id)decodeWebSafeBase64ForString:(NSString *)decodeString;

-(NSString *)encodeBase64ForData;
-(NSString *)encodeWebSafeBase64ForData;
-(NSString *)encodeWrappedBase64ForData;

@end
