//
//  HSK_CFUtilities.m
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

#include "HSK_CFUtilities.h"

#include <sys/types.h>
#include <sys/socket.h>

void CFStreamCreatePairWithUNIXSocketPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream)
{
    int sockpair[2];
    int success = socketpair(AF_UNIX, SOCK_STREAM, 0, sockpair);
    if (success < 0)
    {
        [NSException raise:@"HSK_CFUtilitiesErrorDomain" format:@"Unable to create socket pair, errno: %d", errno];
    }
    
    CFStreamCreatePairWithSocket(NULL, sockpair[0], readStream, NULL);
    CFReadStreamSetProperty(*readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFStreamCreatePairWithSocket(NULL, sockpair[1], NULL, writeStream);
    CFWriteStreamSetProperty(*writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
}

CFIndex CFWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length)
{
    CFIndex bufferOffset = 0;
    CFIndex bytesWritten;
    
    while (bufferOffset < length)
    {
        if (CFWriteStreamCanAcceptBytes(outputStream))
        {
            bytesWritten = CFWriteStreamWrite(outputStream, &(buffer[bufferOffset]), length - bufferOffset);
            if (bytesWritten < 0)
            {
                // Bail!
                return bytesWritten;
            }
            bufferOffset += bytesWritten;
        }
        else if (CFWriteStreamGetStatus(outputStream) == kCFStreamStatusError)
        {
            return -1;
        }
        else
        {
            // Pump the runloop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.0, true);
        }
    }
    
    return bufferOffset;
}
