//
//  NSData+DWDataUtils.m
//  AccountBook
//
//  Created by Wicky on 2017/10/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSData+DWDataUtils.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonCrypto.h>

#define xx 65

#define DWShowAssert(func,reason) \
do {\
[[NSAssertionHandler currentHandler] handleFailureInFunction:func file:@"NSData+DWDataUtils.m" lineNumber:__LINE__ description:reason];\
} while (0)

static const char * base64EncodeLookup = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static const char * webSafeBase64EncodeLookup = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

static const char kBase64PaddingChar = '=';

static const char base64DecodeLookup[256] =
{
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, 62,xx, xx, xx, 63,
    52, 53,54, 55, 56, 57, 58,59, 60, 61, xx, xx,xx, xx, xx, xx,
    xx,  0, 1,  2,  3,  4,  5, 6,  7,  8,  9, 10,11, 12, 13, 14,
    15, 16,17, 18, 19, 20, 21,22, 23, 24, 25, xx,xx, xx, xx, xx,
    xx, 26,27, 28, 29, 30, 31,32, 33, 34, 35, 36,37, 38, 39, 40,
    41, 42,43, 44, 45, 46, 47,48, 49, 50, 51, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
};

static const char webSafeBase64DecodeLookup[256] =
{
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, 62, xx, xx,
    52, 53,54, 55, 56, 57, 58,59, 60, 61, xx, xx,xx, xx, xx, xx,
    xx, 0,  1,  2,  3,  4,  5, 6,  7,  8,  9, 10,11, 12, 13, 14,
    15, 16,17, 18, 19, 20, 21,22, 23, 24, 25, xx,xx, xx, xx, 63,
    xx, 26,27, 28, 29, 30, 31,32, 33, 34, 35, 36,37, 38, 39, 40,
    41, 42,43, 44, 45, 46, 47,48, 49, 50, 51, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
    xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx, xx,xx, xx, xx, xx,
};

@implementation NSData (DWDataEncodeUtils)

+ (NSData *)dw_DecodeDataFromBase64String:(NSString *)aString {
    if (@available(iOS 7,*)) {
        return [[NSData alloc] initWithBase64EncodedString:aString options:0];
    }
    return decodeDataFromString(aString, base64DecodeLookup, true);
}

-(NSString *)dw_Base64EncodedString {
    if (@available(iOS 7,*)) {
        return [self base64EncodedStringWithOptions:0];
    }
    return encodeStringFromData(self, base64EncodeLookup, YES);
}

+(NSData *)dw_WebSafeDecodeDataFromBase64String:(NSString *)aString {
    return decodeDataFromString(aString, webSafeBase64DecodeLookup, false);
}

-(NSString *)dw_WebSafeBase64EncodedStringWithPadding:(BOOL)padding {
    return encodeStringFromData(self, webSafeBase64EncodeLookup, padding);
}

-(NSData *)dw_AES256EncryptWithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,keyPtr, kCCKeySizeAES256,NULL,[self bytes], dataLength,buffer, bufferSize,&numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

-(NSData *)dw_AES256DecryptWithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,keyPtr, kCCKeySizeAES256,NULL,[self bytes], dataLength,buffer, bufferSize,&numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

-(NSString *)dw_MD5String {
    const char * str = [self bytes];
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

#pragma mark --- inline method ---
static inline size_t CalcEncodedLength(size_t srcLen, bool padded) {
    size_t intermediate_result = 8 * srcLen + 5;
    size_t len = intermediate_result / 6;
    if (padded) {
        len = ((len + 3) / 4) * 4;
    }
    return len;
}

static inline size_t GuessDecodedLength(size_t srcLen) {
    return (srcLen + 3) / 4 * 3;
}

static inline BOOL IsSpace(unsigned char c) {
    // we use our own mapping here because we don't want anything w/ locale
    // support.
    static BOOL kSpaces[256] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1,  // 0-9
        1, 1, 1, 1, 0, 0, 0, 0, 0, 0,  // 10-19
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 20-29
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  // 30-39
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 40-49
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 50-59
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 60-69
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 70-79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 80-89
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 90-99
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 100-109
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 110-119
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 120-129
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 130-139
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 140-149
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 150-159
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 160-169
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 170-179
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 180-189
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 190-199
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 200-209
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 210-219
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 220-229
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 230-239
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 240-249
        0, 0, 0, 0, 0, 1,              // 250-255
    };
    return kSpaces[c];
}

static NSString * encodeStringFromData(NSData * data,const char * charset,bool padded) {
    size_t length = [data length];
    const char * bytes = [data bytes];
    size_t maxLength = CalcEncodedLength(length, padded);
    // make space
    NSMutableData *result = [NSMutableData data];
    [result setLength:maxLength];
    // do it
    size_t finalLength = base64Encode(bytes, length, [result mutableBytes], maxLength, charset, padded);
    if (!finalLength) {
        result = nil;
    }
    NSString * encodedString = nil;
    if (result) {
        encodedString = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
    }
    return encodedString;
}

static NSData * decodeDataFromString(NSString * aString,const char * charset,bool padded) {
    NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
    if (!data) {
        return nil;
    }
    size_t length = [data length];
    const char * srcBytes = [data bytes];
    NSUInteger maxLength = GuessDecodedLength(length);
    // make space
    NSMutableData *result = [NSMutableData data];
    [result setLength:maxLength];
    
    size_t finalLength = base64Decode(srcBytes, length, [result mutableBytes], maxLength, charset, padded);
    
    if (!finalLength) {
        return nil;
    }
    
    
    if (finalLength != maxLength) {
        // resize down to how big it was
        [result setLength:finalLength];
    }
    return [NSData dataWithData:result];
}

static size_t base64Decode(const char * srcBytes,size_t srcLen,char * destBytes,size_t destLen, const char * charset,bool requirePadding) {
    if (!srcLen || !destLen || !srcBytes || !destBytes) {
        return 0;
    }
    
    int decode;
    NSUInteger destIndex = 0;
    int state = 0;
    char ch = 0;
    while (srcLen-- && (ch = *srcBytes++) != 0)  {
        if (IsSpace(ch))  // Skip whitespace
            continue;
        
        if (ch == kBase64PaddingChar)
            break;
        
        decode = charset[(unsigned int)ch];
        if (decode == xx)
            return 0;
        
        // Four cyphertext characters decode to three bytes.
        // Therefore we can be in one of four states.
        switch (state) {
            case 0:
                // We're at the beginning of a four-character cyphertext block.
                // This sets the high six bits of the first byte of the
                // plaintext block.
                if (destIndex >= destLen) {
                    DWShowAssert(@"Base64Decode", @"Wrong DestLen which length was wrong");
                }
                destBytes[destIndex] = decode << 2;
                state = 1;
                break;
            case 1:
                // We're one character into a four-character cyphertext block.
                // This sets the low two bits of the first plaintext byte,
                // and the high four bits of the second plaintext byte.
                if (destIndex + 1 >= destLen) {
                    DWShowAssert(@"Base64Decode", @"Wrong DestLen which length was wrong");
                }
                destBytes[destIndex] |= decode >> 4;
                destBytes[destIndex+1] = (decode & 0x0f) << 4;
                destIndex++;
                state = 2;
                break;
            case 2:
                // We're two characters into a four-character cyphertext block.
                // This sets the low four bits of the second plaintext
                // byte, and the high two bits of the third plaintext byte.
                // However, if this is the end of data, and those two
                // bits are zero, it could be that those two bits are
                // leftovers from the encoding of data that had a length
                // of two mod three.
                if (destIndex + 1 >= destLen) {
                    DWShowAssert(@"Base64Decode", @"Wrong DestLen which length was wrong");
                }
                destBytes[destIndex] |= decode >> 2;
                destBytes[destIndex+1] = (decode & 0x03) << 6;
                destIndex++;
                state = 3;
                break;
            case 3:
                // We're at the last character of a four-character cyphertext block.
                // This sets the low six bits of the third plaintext byte.
                if (destIndex >= destLen) {
                    DWShowAssert(@"Base64Decode", @"Wrong DestLen which length was wrong");
                }
                destBytes[destIndex] |= decode;
                destIndex++;
                state = 0;
                break;
        }
    }
    
    // We are done decoding Base-64 chars.  Let's see if we ended
    //      on a byte boundary, and/or with erroneous trailing characters.
    if (ch == kBase64PaddingChar) {               // We got a pad char
        if ((state == 0) || (state == 1)) {
            return 0;  // Invalid '=' in first or second position
        }
        if (srcLen == 0) {
            if (state == 2) { // We run out of input but we still need another '='
                return 0;
            }
            // Otherwise, we are in state 3 and only need this '='
        } else {
            if (state == 2) {  // need another '='
                while ((ch = *srcBytes++) && (srcLen-- > 0)) {
                    if (!IsSpace(ch))
                        break;
                }
                if (ch != kBase64PaddingChar) {
                    return 0;
                }
            }
            // state = 1 or 2, check if all remain padding is space
            while ((ch = *srcBytes++) && (srcLen-- > 0)) {
                if (!IsSpace(ch)) {
                    return 0;
                }
            }
        }
    } else {
        // We ended by seeing the end of the string.
        
        if (requirePadding) {
            // If we require padding, then anything but state 0 is an error.
            if (state != 0) {
                return 0;
            }
        } else {
            // Make sure we have no partial bytes lying around.  Note that we do not
            // require trailing '=', so states 2 and 3 are okay too.
            if (state == 1) {
                return 0;
            }
        }
    }
    
    // If then next piece of output was valid and got written to it means we got a
    // very carefully crafted input that appeared valid but contains some trailing
    // bits past the real length, so just toss the thing.
    if ((destIndex < destLen) &&
        (destBytes[destIndex] != 0)) {
        return 0;
    }
    
    return destIndex;
}

static size_t base64Encode(const char * srcBytes,size_t srcLen,char * destBytes,size_t destLen,const char * charset,bool padded) {
    if (!srcLen || !destLen || !srcBytes || !destBytes) {
        return 0;
    }
    
    char *curDest = destBytes;
    const unsigned char *curSrc = (const unsigned char *)(srcBytes);
    
    // Three bytes of data encodes to four characters of cyphertext.
    // So we can pump through three-byte chunks atomically.
    while (srcLen > 2) {
        // space?
        if (destLen < 4) {
            DWShowAssert(@"Base64Encode", @"Wrong DestLen which less than 4");
        }
        curDest[0] = charset[curSrc[0] >> 2];
        curDest[1] = charset[((curSrc[0] & 0x03) << 4) + (curSrc[1] >> 4)];
        curDest[2] = charset[((curSrc[1] & 0x0f) << 2) + (curSrc[2] >> 6)];
        curDest[3] = charset[curSrc[2] & 0x3f];
        
        curDest += 4;
        curSrc += 3;
        srcLen -= 3;
        destLen -= 4;
    }
    
    // now deal with the tail (<=2 bytes)
    switch (srcLen) {
        case 0:
            // Nothing left; nothing more to do.
            break;
        case 1:
            // One byte left: this encodes to two characters, and (optionally)
            // two pad characters to round out the four-character cypherblock.
            if (destLen < 2) {
                DWShowAssert(@"Base64Encode", @"Wrong DestLen which less than 2");
            }
            curDest[0] = charset[curSrc[0] >> 2];
            curDest[1] = charset[(curSrc[0] & 0x03) << 4];
            curDest += 2;
            destLen -= 2;
            if (padded) {
                if (destLen < 2) {
                    DWShowAssert(@"Base64Encode", @"Wrong DestLen which less than 2");
                }
                curDest[0] = kBase64PaddingChar;
                curDest[1] = kBase64PaddingChar;
                curDest += 2;
            }
            break;
        case 2:
            // Two bytes left: this encodes to three characters, and (optionally)
            // one pad character to round out the four-character cypherblock.
            DWShowAssert(@"Base64Encode", @"Wrong DestLen which less than 3");
            curDest[0] = charset[curSrc[0] >> 2];
            curDest[1] = charset[((curSrc[0] & 0x03) << 4) + (curSrc[1] >> 4)];
            curDest[2] = charset[(curSrc[1] & 0x0f) << 2];
            curDest += 3;
            destLen -= 3;
            if (padded) {
                if (destLen < 1) {
                    DWShowAssert(@"Base64Encode", @"Wrong DestLen which less than 1");
                }
                curDest[0] = kBase64PaddingChar;
                curDest += 1;
            }
            break;
    }
    // return the length
    return (curDest - destBytes);
}

@end
