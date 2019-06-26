//
//  DWFlashFlowCache.m
//  DWFlashFlow
//
//  Created by MOMO on 2018/4/25.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWFlashFlowCache.h"
#import "DWFlashFlowManager.h"
#import <CommonCrypto/CommonCrypto.h>

#pragma mark --- Tool method ---

///校验容器类内部元素是否合法（NSString/NSNumber/NSDictionary/NSArray）
NS_INLINE BOOL validateContainer(id container) {
    NSArray * allValues = nil;
    if ([container isKindOfClass:[NSDictionary class]]) {
        allValues = ((NSDictionary *)container).allValues;
    } else if ([container isKindOfClass:[NSArray class]]) {
        allValues = container;
    } else {
        return NO;
    }
    __block BOOL validate = YES;
    [allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]] ||
            [obj isKindOfClass:[NSNumber class]] ||
            [obj isKindOfClass:[NSDictionary class]] ||
            [obj isKindOfClass:[NSArray class]]) {
            if ([obj isKindOfClass:[NSDictionary class]] ||
                [obj isKindOfClass:[NSArray class]]) {
                BOOL temp = validateContainer(obj);
                if (!temp) {
                    validate = NO;
                    *stop = YES;
                }
            }
        } else {
            validate = NO;
            *stop = YES;
        }
    }];
    return validate;
}

///校验缓存数据类型是否合法（NSData/NSString/合法的NSDictionary和NSArray）
NS_INLINE BOOL validateCachedResponseType(id cachedResponse) {
    if ([cachedResponse isKindOfClass:[NSData class]] ||
        [cachedResponse isKindOfClass:[NSString class]] ||
        [cachedResponse isKindOfClass:[NSDictionary class]] ||
        [cachedResponse isKindOfClass:[NSArray class]]) {
        if ([cachedResponse isKindOfClass:[NSDictionary class]] || [cachedResponse isKindOfClass:[NSArray class]]) {
            return validateContainer(cachedResponse);
        } else {
            return YES;
        }
    }
    return NO;
}

///容器类转为NSData
NS_INLINE NSData * container2Data(id container) {
    return [NSJSONSerialization dataWithJSONObject:container options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
}

///NSData转为容器
NS_INLINE id jsonData2Container(NSData * jsonData) {
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
}

///返回内容的类型字符串
NS_INLINE NSString * cacheType(id cacheResponse) {
    if ([cacheResponse isKindOfClass:[NSData class]]) {
        return @"NSData";
    }
    if ([cacheResponse isKindOfClass:[NSString class]]) {
        return @"NSString";
    }
    if ([cacheResponse isKindOfClass:[NSDictionary class]]) {
        return @"NSDictionary";
    }
    if ([cacheResponse isKindOfClass:[NSArray class]]) {
        return @"NSArray";
    }
    return nil;
}

///将缓存内容转换为NSData
NS_INLINE NSData * dataFromCachedResponse(id cachedResponse) {
    if ([cachedResponse isKindOfClass:[NSData class]]) {
        return cachedResponse;
    } else if ([cachedResponse isKindOfClass:[NSString class]]) {
        return [((NSString *)cachedResponse) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([cachedResponse isKindOfClass:[NSArray class]] || [cachedResponse isKindOfClass:[NSDictionary class]]) {
        return container2Data(cachedResponse);
    }
    return nil;
}

///将NSData转换为缓存的数据
NS_INLINE id objectFromDataWithType(NSString * type,NSData * data) {
    if (!data) {
        return nil;
    }
    if ([type isEqualToString:@"NSData"]) {
        return data;
    } else if ([type isEqualToString:@"NSString"]) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else if ([type isEqualToString:@"NSDictionary"] || [type isEqualToString:@"NSArray"]) {
        return jsonData2Container(data);
    }
    return nil;
}

const NSString * kCacheType = @"cacheType";



@implementation DWFlashFlowDefaultCache

-(void)storeCachedResponse:(id)cachedResponse forKey:(NSString *)key request:(DWFlashFlowRequest *)request {
    if (!cachedResponse || !key.length || !request || !request.task.response) {
        return;
    }
    if (!validateCachedResponseType(cachedResponse)) {
        return;
    }
    NSData * data = dataFromCachedResponse(cachedResponse);
    if (!data) {
        return;
    }
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString * type = cacheType(cachedResponse);
    
    if (!type.length) {
        return;
    }
    userInfo[kCacheType] = type;
    NSCachedURLResponse * response = [[NSCachedURLResponse alloc] initWithResponse:request.task.response data:data userInfo:userInfo storagePolicy:(NSURLCacheStorageAllowed)];
    [[NSURLCache sharedURLCache] storeCachedResponse:response forRequest:requestForKey(key)];
}

-(id)cachedResponseForKey:(NSString *)key {
    if (!key.length) {
        return nil;
    }
    NSCachedURLResponse * response = [[NSURLCache sharedURLCache] cachedResponseForRequest:requestForKey(key)];
    if (!response || !response.data || !response.userInfo) {
        return nil;
    }
    NSData * data = response.data;
    NSString * type = response.userInfo[kCacheType];
    if (!type) {
        return nil;
    }
    id cachedResponse = objectFromDataWithType(type, data);
    return cachedResponse;
}

-(void)removeCachedResponseForKey:(NSString *)key {
    if (!key.length) {
        return ;
    }
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:requestForKey(key)];
}

-(BOOL)validateCacheResponese:(id)cachedResponse forKey:(NSString *)key {
    if ([self cachedResponseForKey:key]) {
        return YES;
    }
    return NO;
}

#pragma mark --- tool func ---
NS_INLINE NSString * URLForKey(NSString * key) {
    return key;
}

NS_INLINE NSURLRequest * requestForKey(NSString * key) {
    if (!key.length) {
        return nil;
    }
    return [NSURLRequest requestWithURL:[NSURL URLWithString:URLForKey(key)]];
}

@end



@interface DWFlashFlowAdvancedCache ()<NSSecureCoding>

@property (nonatomic ,strong) id cachedResponse;

@property (nonatomic ,copy) NSString * md5Key;

@property (nonatomic ,copy) NSString * cacheType;

@property (nonatomic ,assign) NSInteger appVersion;

@property (nonatomic ,strong) NSDate * createTime;

@property (nonatomic ,assign) NSTimeInterval expiredInterval;

@property (nonatomic ,assign) NSTimeInterval maxExpireInterval;

@property (nonatomic ,assign) NSUInteger maxMemorySize;

@property (nonatomic ,assign) NSUInteger maxDiskSize;

@property (nonatomic ,strong) dispatch_queue_t ioQueue;

@property (nonatomic ,strong) NSCache * memoryCache;

@end

@implementation DWFlashFlowAdvancedCache

+(instancetype)cacheHandlerWithMaxExpireInterval:(NSTimeInterval)expireInterval maxMemorySize:(NSUInteger)memorySize maxDiskSize:(NSUInteger)diskSize {
    __kindof DWFlashFlowAdvancedCache * handler = [self dw_new];
    if (handler) {
        handler.ioQueue = dispatch_queue_create("com.handleLocalCacheQueue", DISPATCH_QUEUE_SERIAL);
        handler.maxExpireInterval = expireInterval;
        handler.maxMemorySize = memorySize;
        handler.maxDiskSize = diskSize;
        [[NSNotificationCenter defaultCenter] addObserver:handler
                                                 selector:@selector(cleanLoalDiskCacheWithCompletion:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:handler
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return handler;
}

+(instancetype)cacheHandler {
    return [self cacheHandlerWithMaxExpireInterval:(60 * 60 * 24 * 7) maxMemorySize:(1024 * 1024 * 2) maxDiskSize:(1024 * 1024 * 100)];
}

-(void)storeCachedResponse:(id)cachedResponse forKey:(NSString *)key request:(DWFlashFlowRequest *)request {
    if (!cachedResponse || !key.length) {
        return;
    }
    if (!validateCachedResponseType(cachedResponse)) {
        return;
    }
    NSString * md5Key = MD5(key);
    NSTimeInterval expiredInterval = request.expiredInterval;
    if (expiredInterval == 0) {
        expiredInterval = [DWFlashFlowManager manager].globalExpiredInterval;
    }
    
    DWFlashFlowAdvancedCache * cache = [DWFlashFlowAdvancedCache dw_new];
    cache.cachedResponse = cachedResponse;
    cache.md5Key = md5Key;
    cache.cacheType = cacheType(cachedResponse);
    cache.appVersion = [DWFlashFlowManager manager].appVersion;
    cache.createTime = [NSDate date];
    cache.expiredInterval = expiredInterval;
    [self.memoryCache setObject:cache forKey:md5Key];
    dispatch_async(self.ioQueue, ^{
        [NSKeyedArchiver archiveRootObject:cache toFile:metaPathWithKey(md5Key)];
        writeFile2Path(cachedResponse, cacheFilePathWithKey(md5Key));
    });
}

-(id)cachedResponseForKey:(NSString *)key {
    NSString * md5Key = MD5(key);
    ///先从内存缓存取
    DWFlashFlowAdvancedCache * cache = [self.memoryCache objectForKey:md5Key];
    if (!cache) {
        ///再从磁盘缓存取
        cache = [NSKeyedUnarchiver unarchiveObjectWithFile:metaPathWithKey(md5Key)];
        if (cache) {
            [self.memoryCache setObject:cache forKey:md5Key];
        }
    }
    if (![self validateCacheResponese:cache forKey:key]) {
        return nil;
    }
    return cache.cachedResponse;
}

-(void)removeCachedResponseForKey:(NSString *)key {
    NSString * md5Key = MD5(key);
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePathWithKey(md5Key)]) {
        dispatch_async(self.ioQueue, ^{
            [[NSFileManager defaultManager] removeItemAtPath:savePathWithKey(md5Key) error:nil];
        });
    }
}

-(BOOL)validateCacheResponese:(DWFlashFlowAdvancedCache *)cachedResponse forKey:(NSString *)key {
    
    BOOL res = YES;
    
    if (res && !cachedResponse) {
        res = NO;
    }
    if (res && ![cachedResponse isKindOfClass:[DWFlashFlowAdvancedCache class]]) {
        res = NO;
    }
    ///版本不对
    if (res && cachedResponse.appVersion < [DWFlashFlowManager manager].appVersion) {
        res = NO;
    }
    ///超时
    if (res && cachedResponse.expiredInterval > 0 && [[NSDate date] timeIntervalSince1970] - [cachedResponse.createTime timeIntervalSince1970] > cachedResponse.expiredInterval) {
        res = NO;
    }
    ///响应数据
    if (res && !cachedResponse.cachedResponse) {
        res = NO;
    }
    
    ///缓存无效后删除缓存
    if (!res) {
        [self removeCachedResponseForKey:key];
    }
    return res;
}

#pragma mark --- tool method ---
- (void)backgroundCleanDisk {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    [self cleanLoalDiskCacheWithCompletion:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

-(void)cleanLoalDiskCacheWithCompletion:(dispatch_block_t)completion {
    dispatch_async(self.ioQueue, ^{
        NSString * mainPath = savePathWithKey(@"");
        NSURL * fileURL = [NSURL fileURLWithPath:mainPath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey];
        NSFileManager * fileMgr = [NSFileManager defaultManager];
        
        ///遍历文件夹
        NSDirectoryEnumerator *fileEnumerator = [fileMgr enumeratorAtURL:fileURL includingPropertiesForKeys:resourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSMutableDictionary * cacheFiles = [NSMutableDictionary dictionaryWithCapacity:0];
        NSUInteger currentSize = 0;
        NSMutableArray * urlsToDelete = [NSMutableArray arrayWithCapacity:0];
        for (NSURL * url in fileEnumerator) {
            NSMutableDictionary * attr = [[url resourceValuesForKeys:resourceKeys error:nil] mutableCopy];
            ///如果不是文件夹则跳过
            if (![attr[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            ///如果超时则加入待删数组，并跳过
            if (self.maxExpireInterval > 0) {
                NSDate * modData = attr[NSURLContentModificationDateKey];
                if (timeStamp - [modData timeIntervalSince1970] > self.maxExpireInterval) {
                    [urlsToDelete addObject:url];
                    continue;
                }
            }
            
            ///计算当前未过期的缓存总大小
            NSUInteger totalAllocatedSize = [self calculateDirectorySizeAtUrl:url];
            attr[NSURLTotalFileAllocatedSizeKey] = @(totalAllocatedSize);
            currentSize += totalAllocatedSize;
            [cacheFiles setObject:attr forKey:fileURL];
        }
        
        ///删除过期缓存
        for (NSURL * url in urlsToDelete) {
            [fileMgr removeItemAtURL:url error:nil];
        }
        
        ///如果设置了最大缓存大小则删除一部分老的缓存
        if (self.maxDiskSize > 0 && currentSize > self.maxDiskSize) {
            const NSUInteger desiredCacheSize = self.maxDiskSize / 2;
            ///按最后修改时间排序
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            ///删除较老的缓存并比较是否减少到指定内存大小
            for (NSURL * url in sortedFiles) {
                if ([fileMgr removeItemAtURL:url error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[url];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentSize -= [totalAllocatedSize unsignedIntegerValue];
                    ///已经到达指定内存一版，停止删除
                    if (currentSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

-(NSUInteger)calculateDirectorySizeAtUrl:(NSURL *)url {
    NSArray *resourceKeys = @[NSURLTotalFileAllocatedSizeKey];
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    ///遍历文件夹
    NSDirectoryEnumerator *fileEnumerator = [fileMgr enumeratorAtURL:url includingPropertiesForKeys:resourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    NSUInteger currentSize = 0;
    for (NSURL * fileURL in fileEnumerator) {
         NSDictionary * attr = [fileURL resourceValuesForKeys:resourceKeys error:nil];
        NSNumber *totalAllocatedSize = attr[NSURLTotalFileAllocatedSizeKey];
        currentSize += [totalAllocatedSize unsignedIntegerValue];
    }
    return currentSize;
}

#pragma mark --- 归档 ---
+ (BOOL)supportsSecureCoding {
    return YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.expiredInterval forKey:@"expiredInterval"];
    [aCoder encodeObject:self.createTime forKey:@"createTime"];
    [aCoder encodeInteger:self.appVersion forKey:@"appVersion"];
    [aCoder encodeObject:self.md5Key forKey:@"md5Key"];
    [aCoder encodeObject:self.cacheType forKey:@"cacheType"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.expiredInterval = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"expiredInterval"] doubleValue];
    self.createTime = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"createTime"];
    self.appVersion = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"appVersion"] integerValue];
    self.md5Key = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"md5Key"];
    self.cacheType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"cacheType"];
    NSString * cachePath = cacheFilePathWithKey(self.md5Key);
    if (cachePath.length && self.cacheType.length) {
        NSData * data = [NSData dataWithContentsOfFile:cachePath];
        self.cachedResponse = objectFromDataWithType(self.cacheType, data);
    }
    return self;
}

#pragma mark --- inline method ---

NS_INLINE NSString * savePathWithKey(NSString * key) {
    NSString * cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * path = [cache stringByAppendingPathComponent:@"DWFlashFlow"];
    path = [path stringByAppendingPathComponent:@"ResponseCache"];
    if (key.length) {
        path = [path stringByAppendingPathComponent:key];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

NS_INLINE NSString * cacheFilePathWithKey(NSString * key) {
    return [savePathWithKey(key) stringByAppendingPathComponent:[key stringByAppendingPathExtension:@"data"]];
}

NS_INLINE NSString * metaPathWithKey(NSString * key) {
    return [savePathWithKey(key) stringByAppendingPathComponent:@"response.meta"];
}

NS_INLINE void writeFile2Path(id file,NSString * path) {
    NSData * data = dataFromCachedResponse(file);
    [data writeToFile:path atomically:YES];
}

NS_INLINE NSString * MD5(NSString * str){
    CC_MD5_CTX md5;
    CC_MD5_Init (&md5);
    CC_MD5_Update (&md5, [str UTF8String], (CC_LONG)[str length]);
    
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
};

#pragma mark --- override ---
+(instancetype)dw_new {
    return [super new];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --- setter/getter ---
-(NSCache *)memoryCache {
    if (!_memoryCache) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.totalCostLimit = self.maxMemorySize;
        _memoryCache.countLimit = 50;
    }
    return _memoryCache;
}

@end
