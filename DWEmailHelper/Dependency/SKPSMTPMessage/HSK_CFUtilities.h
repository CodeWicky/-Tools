//
//  HSK_CFUtilities.h
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

void CFStreamCreatePairWithUNIXSocketPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);
CFIndex CFWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length);