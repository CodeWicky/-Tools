//
//  NSStream+SKPSMTPExtensions.h
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

/*
 MRC Needed.
 -fno-objc-arc
 */

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

@interface NSStream (SKPSMTPExtensions)

+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream;

@end
