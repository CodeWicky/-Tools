//
//  DWFlashFlowCache.h
//  DWFlashFlow
//
//  Created by MOMO on 2018/4/25.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWFlashFlowRequest.h"

///支持数据类型NSArray/NSDictionary/NSString/NSData
@protocol DWFlashFlowCacheProtocol

@required

//Store response by key.
///按指定Key存储响应
-(void)storeCachedResponse:(id)cachedResponse forKey:(NSString *)key request:(DWFlashFlowRequest *)request;

//Fetch response cache by key.
///按指定key取出响应
-(id)cachedResponseForKey:(NSString *)key;

//Remove response cache by key.
///移除指定key的响应
-(void)removeCachedResponseForKey:(NSString *)key;

@optional
//Validate response cache by key.
///检验指定key的响应的有效性（内部调用，不对外部暴露）
-(BOOL)validateCacheResponese:(id)cachedResponse forKey:(NSString *)key;

@end



//Cache response via NSURLCache.
///以NSURLCache作缓存，此类中Key必须为请求URL。（仅为简单缓存，不会控制版本号及超时时间）
@interface DWFlashFlowDefaultCache : NSObject<DWFlashFlowCacheProtocol>

@end



//Control expired time and AppVersion in Local cache.
///可以控制版本超时时间的缓存策略，此类中key可以为任意key，内部文件会做MD5加密处理，应保证key的唯一性。
@interface DWFlashFlowAdvancedCache : NSObject<DWFlashFlowCacheProtocol>

//Auto clean expired cache and remove superfluous cache until totalsize is 50% of maxCacheSize.
///自动清理过期文件并删除冗余文件至大小占最大限制的1/2。
-(void)cleanLoalDiskCacheWithCompletion:(dispatch_block_t)completion;

+(instancetype)new NS_UNAVAILABLE;

-(instancetype)init NS_UNAVAILABLE;


/**
 初始化方法

 @param expireInterval 最大超时时长
 @param memorySize 最大内存缓存空间(单位B,即1KB为1024)
 @param diskSize 最大磁盘缓存空间(单位B,即1KB为1024)
 @return 实例
 */
+(instancetype)cacheHandlerWithMaxExpireInterval:(NSTimeInterval)expireInterval maxMemorySize:(NSUInteger)memorySize maxDiskSize:(NSUInteger)diskSize;

//Initialize with default value.ExpireInterval is seconds in one week,memorySize is 2MB,diskSize is 100MB.
///以默认值初始化，其中超时时间为1周，内存缓存为2MB，磁盘缓存为100MB。
+(instancetype)cacheHandler;

@end




