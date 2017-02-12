//
//  DWMD5Utils.m
//  DWAsyncImage
//
//  Created by Wicky on 2017/2/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWMD5Utils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation DWMD5Utils

+(NSString *)dw_GetMD5StringFromData:(NSData *)data
{
    return [self getMD5StrWithStr:data.bytes];
}

+(NSString *)dw_GetMD5StringFromString:(NSString *)str
{
    return [self getMD5StrWithStr:str.UTF8String];
}

+(NSString *)getMD5StrWithStr:(const char *)str
{
    CC_MD5_CTX md5;
    CC_MD5_Init (&md5);
    CC_MD5_Update (&md5, str, (uint)strlen(str));
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final (digest, &md5);
    return  [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             digest[0],  digest[1],
             digest[2],  digest[3],
             digest[4],  digest[5],
             digest[6],  digest[7],
             digest[8],  digest[9],
             digest[10], digest[11],
             digest[12], digest[13],
             digest[14], digest[15]];
}

@end

@implementation NSString (DWMD5Utils)

-(NSString *)dw_MD5String
{
    return [DWMD5Utils dw_GetMD5StringFromString:self];
}

@end

@implementation NSData (DWMD5Utils)

-(NSString *)dw_MD5String
{
    return [DWMD5Utils dw_GetMD5StringFromData:self];
}

@end

