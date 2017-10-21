//
//  NSStream+SKPSMTPExtensions.m
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

#import "NSStream+SKPSMTPExtensions.h"


@implementation NSStream (SKPSMTPExtensions)

+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream
{
    CFHostRef           host;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    readStream = NULL;
    writeStream = NULL;
    
    host = CFHostCreateWithName(NULL, (CFStringRef) hostName);
    if (host != NULL)
    {
        (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, port, &readStream, &writeStream);
        CFRelease(host);
    }
    
    if (inputStream == NULL)
    {
        if (readStream != NULL)
        {
            CFRelease(readStream);
        }
    }
    else
    {
        *inputStream = [(NSInputStream *) readStream autorelease];
    }
    if (outputStream == NULL)
    {
        if (writeStream != NULL)
        {
            CFRelease(writeStream);
        }
    }
    else
    {
        *outputStream = [(NSOutputStream *) writeStream autorelease];
    }
}

@end