//
//  NSData+DWDataUtils.m
//  AccountBook
//
//  Created by Wicky on 2017/10/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSData+DWDataUtils.h"

#define xx 65
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

static unsigned char base64EncodeLookup[65] ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static unsigned char base64DecodeLookup[256] =
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

void *NewBase64Decode(const char *inputBuffer ,size_t length ,size_t *outputLength) {
    if (length == -1) {
        length = strlen(inputBuffer);
    }
    size_t outputBufferSize = (length / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    size_t i = 0;
    size_t j = 0;
    while (i < length) {
        unsigned char accumulated[BASE64_UNIT_SIZE];
        size_t accumulateIndex = 0;
        while (i < length) {
            unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
            if (decode != xx) {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;
                if (accumulateIndex == BASE64_UNIT_SIZE) {
                    break;
                }
            }
        }
        //
        // Store the 6 bits from each of the 4 characters as 3 bytes
        //
        outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
        outputBuffer[j + 1] = (accumulated[1] <<4) | (accumulated[2] >>2);
        outputBuffer[j + 2] = (accumulated[2] <<6) | accumulated[3];
        j += accumulateIndex - 1;
    }
    if (outputLength) {
        *outputLength = j;
    }
    return outputBuffer;
}

char *NewBase64Encode(const void *buffer ,size_t length ,bool separateLines ,size_t *outputLength) {
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
    size_t outputBufferSize = ((length / BINARY_UNIT_SIZE) + ((length % BINARY_UNIT_SIZE) ? 1 : 0)) * BASE64_UNIT_SIZE;
    if (separateLines) {
        outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) *CR_LF_SIZE;
    }
    outputBufferSize += 1;
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer) {
        return NULL;
    }
    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ?INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    while (true) {
        if (lineEnd > length) {
            lineEnd = length;
        }
        for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE) {
            outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] &0xFC) >> 2];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] &0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i +1] & 0x0F) <<2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            outputBuffer[j++] = base64EncodeLookup[inputBuffer[i +2] & 0x3F];
        }
        if (lineEnd == length) {
            break;
        }
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    if (i + 1 < length) {
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] &0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] &0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i +1] & 0x0F) <<2];
        outputBuffer[j++] = '=';
    } else if (i < length) {
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] &0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] &0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    if (outputLength) {
        *outputLength = j;
    }
    return outputBuffer;
}

@implementation NSData (DWDataEncodeUtils)

+ (NSData *)dw_DataFromBase64String:(NSString *)aString {
    if (@available(iOS 7,*)) {
        return [[NSData alloc] initWithBase64EncodedString:aString options:0];
    }
    NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}

-(NSString *)dw_Base64EncodedString {
    if (@available(iOS 7,*)) {
        return [self base64EncodedStringWithOptions:0];
    }
    size_t outputLength;
    char *outputBuffer = NewBase64Encode([self bytes], [self length], true, &outputLength);
    NSString *result = [[NSString alloc] initWithBytes:outputBuffer length:outputLength encoding:NSASCIIStringEncoding];
    free(outputBuffer);
    return result;
}

@end
