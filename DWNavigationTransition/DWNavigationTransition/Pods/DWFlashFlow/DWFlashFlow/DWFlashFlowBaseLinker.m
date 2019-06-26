//
//  DWFlashFlowBaseLinker.m
//  DWFlashFlow
//
//  Created by Wicky on 2017/12/22.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFlashFlowBaseLinker.h"
#import "DWFlashFlowManager.h"

@implementation DWFlashFlowBaseLinker

-(NSString *)requestURLFromRequest:(DWFlashFlowRequest *)r {
    if (!r) {
        return globalManager().baseURL;
    }
    if (r.fullURL.length) {
        return r.fullURL;
    }
    NSString * baseStr = globalManager().baseURL;
    if (baseStr.length && ![baseStr hasSuffix:@"/"]) {
        ///不使用 -stringByAppendingPathComponent: ，若使用则http://www.baidu.com将被转换为http:/www.baidu.com，与实际预期不同
        baseStr = [baseStr stringByAppendingString:@"/"];
    }
    ///不使用 -URLWithString:relativeToURL: ，若使用则根据baseURL格式不同将产生不同行为，与实际预期不同
    return [baseStr stringByAppendingString:r.apiURL];
}

-(NSDictionary *)parametersFromRequest:(DWFlashFlowRequest *)r {
    if (!r) {
        return globalManager().globalParameters;
    }
    if (!r.useGlobalParameters) {
        return r.parameters;
    }
    return dicFromOriAndAdd(r.parameters, globalManager().globalParameters);
}

-(NSString *)methodFromRequest:(DWFlashFlowRequest *)r {
    switch (r.method) {
        case DWFlashFlowMethodPUT:
            return @"PUT";
        case DWFlashFlowMethodPOST:
            return @"POST";
        case DWFlashFlowMethodHEAD:
            return @"HEAD";
        case DWFlashFlowMethodPATCH:
            return @"PATCH";
        case DWFlashFlowMethodDELETE:
            return @"DELETE";
        default:
            return @"GET";
    }
}

-(NSDictionary *)headersFromRequest:(DWFlashFlowRequest *)r {
    if (!r) {
        return globalManager().globalHeaders;
    }
    if (!r.useGlobalHeaders) {
        return r.headers;
    }
    return dicFromOriAndAdd(r.headers, globalManager().globalHeaders);
}

-(DestinationCallback)destinationFromRequest:(DWFlashFlowRequest *)r {
    DestinationCallback d = nil;
    if (r.destination) {
        d = r.destination;
    } else if (r.downloadSavePath.length) {
        NSString * saveP = r.downloadSavePath;
        d = ^(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:saveP];
        };
    } else {
        d = ^(NSURL *targetPath, NSURLResponse *response) {
            NSString * tmpPath = [targetPath absoluteString];
            if ([tmpPath hasPrefix:@"file://"]) {//获取目标路径，去除scheme
                tmpPath = [tmpPath substringFromIndex:7];
            }
            tmpPath = [tmpPath stringByDeletingLastPathComponent];//去除文件名
            NSString * fileName = response.suggestedFilename;//获取推荐文件名
            if (!fileName) {//若无推荐文件名则取目标路径文件名并去除后缀，防止被移除
                fileName = [targetPath.absoluteString lastPathComponent];
                fileName = [fileName stringByDeletingPathExtension];
            }
            tmpPath = [tmpPath stringByAppendingPathComponent:fileName];//拼接最后路径
            return [NSURL fileURLWithPath:tmpPath];
        };
    }
    return d;
}

-(ProcessorBlock)preprocessorFromRequest:(DWFlashFlowRequest *)r {
    if (!r) {
        return nil;
    }
    if (!r.useGlobalPreprocessor) {
        return r.preprocessorBeforeRequest;
    }
    return blockFromTwo(r.preprocessorBeforeRequest,globalManager().globalPreprocessor);
}

-(ProcessorBlock)reprocessorFromRequest:(DWFlashFlowRequest *)r {
    if (!r) {
        return nil;
    }
    if (!r.useGlobalReprocessing) {
        return r.reprocessingAfterResponse;
    }
    return blockFromTwo(globalManager().globalReprocessing, r.reprocessingAfterResponse);
}

#pragma mark --- protocol method---

-(void)sendRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(Completion)completion {
    NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker and don't call super method.");
}

-(void)sendResumeDataRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(Completion)completion {
    NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker and don't call super method.");
}

-(void)resumeRequest:(DWFlashFlowRequest *)request {
    NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker and don't call super method.");
}

-(void)suspendRequest:(DWFlashFlowRequest *)request {
    NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker and don't call super method.");
}

-(void)cancelRequest:(DWFlashFlowRequest *)request {
    NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker and don't call super method.");
}

-(void)cancelRequest:(DWFlashFlowRequest *)request produceResumeData:(BOOL)produce completion:(void (^)(NSData *))completion {
    NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker and don't call super method.");
}

#pragma mark --- override ---
-(instancetype)init {
    if (isBaseLinker(self)) {
        NSAssert(NO, @"Implement this method in subclass of DWFlashFlowBaseLinker");
        return nil;
    } else {
        return [super init];
    }
}

#pragma mark --- tool func ---
static inline DWFlashFlowManager * globalManager() {
    return [DWFlashFlowManager manager];
}

static inline NSDictionary * dicFromOriAndAdd(NSDictionary * ori,NSDictionary * add) {
    if (!add) {
        return [ori copy];
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:add];
    if (ori) {
        [dic setValuesForKeysWithDictionary:ori];
    }
    return [dic copy];
}

static ProcessorBlock blockFromTwo(ProcessorBlock a,ProcessorBlock b) {
    int c = 0;
    if (a) {
        c++;
    }
    if (b) {
        c += 2;
    }
    if (c == 0) {
        return nil;
    } else if (c == 1) {
        return a;
    } else if (c == 2) {
        return b;
    } else {
        ProcessorBlock ab = (id)^(DWFlashFlowRequest * request,id data) {
            data = a(request,data);
            data = b(request,data);
            return data;
        };
        return ab;
    }
}

static inline BOOL isBaseLinker (__kindof DWFlashFlowBaseLinker * l) {
    return ([l class] == [DWFlashFlowBaseLinker class]);
}

@end
