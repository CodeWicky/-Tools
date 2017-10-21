//
//  NSData+Base64Additions.m
//  SMTPSender
//
//  Created by wu xiaoming on 13-1-23.
//  Copyright (c) 2013年 wu xiaoming. All rights reserved.
//

#import "NSData+Base64Additions.h"
#import "Base64Transcoder.h"

@implementation NSData (Base64Additions)

+(id)decodeBase64ForString:(NSString *)decodeString
{
    NSData *decodeBuffer = nil;
    // Must be 7-bit clean!
    NSData *tmpData = [decodeString dataUsingEncoding:NSASCIIStringEncoding];
    
    size_t estSize = EstimateBas64DecodedDataSize([tmpData length]);
    uint8_t* outBuffer = calloc(estSize, sizeof(uint8_t));
    
    size_t outBufferLength = estSize;
    if (Base64DecodeData([tmpData bytes], [tmpData length], outBuffer, &outBufferLength))
    {
        decodeBuffer = [NSData dataWithBytesNoCopy:outBuffer length:outBufferLength freeWhenDone:YES];
    }
    else
    {
        free(outBuffer);
        [NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to decode data!"];
    }
    
    return decodeBuffer;
}

+(id)decodeWebSafeBase64ForString:(NSString *)decodeString
{
    return [NSData decodeBase64ForString:[[decodeString stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]];
}

-(NSString *)encodeBase64ForData
{
    NSString *encodedString = nil;
    
    // Make sure this is nul-terminated.
    size_t outBufferEstLength = EstimateBas64EncodedDataSize([self length]) + 1;
    char *outBuffer = calloc(outBufferEstLength, sizeof(char));
    
    size_t outBufferLength = outBufferEstLength;
    if (Base64EncodeData([self bytes], [self length], outBuffer, &outBufferLength, FALSE))
    {
        encodedString = [NSString stringWithCString:outBuffer encoding:NSASCIIStringEncoding];
    }
    else
    {
        [NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to encode data!"];
    }
    
    free(outBuffer);
    
    return encodedString;
}

-(NSString *)encodeWebSafeBase64ForData
{
    return [[[self encodeBase64ForData] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

-(NSString *)encodeWrappedBase64ForData
{
    NSString *encodedString = nil;
    
    // Make sure this is nul-terminated.
    size_t outBufferEstLength = EstimateBas64EncodedDataSize([self length]) + 1;
    char *outBuffer = calloc(outBufferEstLength, sizeof(char));
    
    size_t outBufferLength = outBufferEstLength;
    if (Base64EncodeData([self bytes], [self length], outBuffer, &outBufferLength, TRUE))
    {
        encodedString = [NSString stringWithCString:outBuffer encoding:NSASCIIStringEncoding];
    }
    else
    {
        [NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to encode data!"];
    }
    
    free(outBuffer);
    
    return encodedString;
}

@end