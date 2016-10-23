//
//  DWSocketUtils.h
//  iOS-Socket-C-Version-Client
//
//  Created by Wicky on 16/8/10.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWSocketUtils : NSObject
@property (nonatomic ,copy) NSString * addr;
@property (nonatomic ,assign) NSInteger port;
@property (nonatomic ,assign) NSInteger clientId;

#pragma mark ---TCPClient---
/*
 addr           主机地址
 port           端口号
 success        连接成功回调
 */
///创建TCPClient
+(instancetype)createTCPClientWithHostAddr:(NSString *)addr
                                      port:(NSInteger)port
                                   success:(void (^)(DWSocketUtils * aClient))success;
///发送指令
-(void)clientSendMsg:(NSString *)msg;
///关闭远程主机
-(void)clientShutDownServer;
///关闭当前套接字
-(void)closeClient;

#pragma mark ---TCPServer---
/*
 port           端口号
 success        连接成功回调
 handler        接受指令回调
 */
///创建TCPServer
+(instancetype)createTCPServerWithPort:(NSInteger)port
                               success:(void (^)(DWSocketUtils * aServer))success
                               handler:(void(^)(DWSocketUtils * aServer,NSString * msg))handler;

#pragma mark ---UDPClient---
/*
 addr           主机地址
 port           端口号
 success        连接成功回调
 handler        接受指令回调
 */
///创建UDPClient
+(instancetype)createUDPClientWithHostAddr:(NSString *)addr port:(NSInteger)port
                                   success:(void (^)(DWSocketUtils * aServer))success
                                   handler:(void (^)(DWSocketUtils * aServer))handler;
///发送指令
-(void)sendToMsg:(NSString *)msg;

///接受指令
-(NSString *)recieveFromMsg;

///结束监听
-(void)exit;

#pragma mark ---UDPServer---
/*
 port           端口号
 success        连接成功回调
 handler        接受指令回调
 */
///创建UDPServer
+(instancetype)createUDPServerWithPort:(NSInteger)port
                               success:(void (^)(DWSocketUtils * aServer))success
                               handler:(void(^)(DWSocketUtils * aServer))handler;
@end
