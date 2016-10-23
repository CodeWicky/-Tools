//
//  DWSocketUtils.m
//  iOS-Socket-C-Version-Client
//
//  Created by Wicky on 16/8/10.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "DWSocketUtils.h"
#include <sys/socket.h>
#include <netinet/in.h>
#import <arpa/inet.h>

@interface DWSocketUtils ()
{
    struct sockaddr_in sock_addr;
    socklen_t addr_len;
}
@property (nonatomic ,assign) BOOL createSuccess;

@property (nonatomic ,assign) BOOL listen;

@end
@implementation DWSocketUtils

#pragma mark ---接口方法---

#pragma mark ------TCPClient接口方法------
+(instancetype)createTCPClientWithHostAddr:(NSString *)addr port:(NSInteger)port success:(void (^)(DWSocketUtils * aClient))success
{
    DWSocketUtils * client = [DWSocketUtils new];
    client.addr = addr;
    client.port = port;
    [client tcpClientWithSuccess:success];
    return client;
}

-(void)clientSendMsg:(NSString *)msg
{
    send((int)self.clientId, msg.UTF8String, 1024, 0);
}

-(void)clientShutDownServer
{
    if (self.createSuccess) {
        [self clientSendMsg:@"shutDown"];
        [self closeClient];
        return;
    }
    NSLog(@"cannot shut down the server because of connecting failed");
}

-(void)closeClient
{
    if (self.createSuccess) {
        [self clientSendMsg:@"exit"];
        close((int)self.clientId);
        self.createSuccess = NO;
    }
    else
    {
        close((int)self.clientId);
    }
}

#pragma mark ------TCPServer接口方法---
+(instancetype)createTCPServerWithPort:(NSInteger)port success:(void (^)(DWSocketUtils *))success handler:(void (^)(DWSocketUtils *, NSString *))handler
{
    DWSocketUtils * server = [DWSocketUtils new];
    server.port = port;
    server.listen = YES;
    [server tcpServerWithSuccessBlock:success handler:handler];
    return server;
}


#pragma mark ------UDPClient接口方法------
+(instancetype)createUDPClientWithHostAddr:(NSString *)addr port:(NSInteger)port
                                   success:(void (^)(DWSocketUtils *))success
                                   handler:(void (^)(DWSocketUtils *))handler
{
    DWSocketUtils * client = [DWSocketUtils new];
    client.addr = addr;
    client.port = port;
    client.listen = YES;
    [client udpClientWithSuccess:success handler:handler];
    return client;
}
-(NSString *)recieveFromMsg
{
    if (self.createSuccess) {
        char buff[1024];
        recvfrom((int)self.clientId, buff, sizeof(buff), 0, (struct sockaddr *)&sock_addr, &addr_len);
        return [NSString stringWithCString:buff encoding:NSUTF8StringEncoding];
    }
    return nil;
}

-(void)sendToMsg:(NSString *)msg
{
    if (self.createSuccess) {
        sendto((int)self.clientId, [msg cStringUsingEncoding:NSASCIIStringEncoding], 2 * [msg length], 0, (struct sockaddr *)&sock_addr, addr_len);
        return;
    }
    NSLog(@"cannot sentMsg because of create failed");
}

-(void)exit
{
    if (self.createSuccess) {
        self.listen = NO;
        return;
    }
    NSLog(@"no need exit becauseo of create failed");
}
#pragma mark ------UDPServer接口方法------
+(instancetype)createUDPServerWithPort:(NSInteger)port success:(void (^)(DWSocketUtils *))success handler:(void (^)(DWSocketUtils *))handler
{
    DWSocketUtils * server = [DWSocketUtils new];
    server.port = port;
    server.listen = YES;
    [server udpServerWithSuccessBlock:success handler:handler];
    return server;
}

#pragma mark ---工具方法---
- (void)tcpClientWithSuccess:(void (^)(DWSocketUtils * aClient))successBlock
{
    // 第一步：创建soket
    // TCP是基于数据流的，因此参数二使用SOCK_STREAM
    int error = -1;
    int clientSocketId = socket(AF_INET, SOCK_STREAM, 0);
    self.clientId = clientSocketId;
    BOOL success = (clientSocketId != -1);
    struct sockaddr_in addr;
    
    // 第二步：绑定端口号
    if (success) {
        NSLog(@"client socket create success");
        // 初始化
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        
        // 指定协议簇为AF_INET，比如TCP/UDP等
        addr.sin_family = AF_INET;
        
        // 监听任何ip地址
        addr.sin_addr.s_addr = INADDR_ANY;
        error = bind(clientSocketId, (const struct sockaddr *)&addr, sizeof(addr));
        success = (error == 0);
    }
    
    if (success) {
        // p2p
        struct sockaddr_in peerAddr;
        memset(&peerAddr, 0, sizeof(peerAddr));
        peerAddr.sin_len = sizeof(peerAddr);
        peerAddr.sin_family = AF_INET;
        peerAddr.sin_port = htons(self.port);
        
        // 指定服务端的ip地址，测试时，修改成对应自己服务器的ip
        peerAddr.sin_addr.s_addr = inet_addr(self.addr.UTF8String);
        
        socklen_t addrLen;
        addrLen = sizeof(peerAddr);
        NSLog(@"will be connecting");
        
        // 第三步：连接服务器
        error = connect(clientSocketId, (struct sockaddr *)&peerAddr, addrLen);
        success = (error == 0);
        
        if (success) {
            // 第四步：获取套接字信息
            error = getsockname(clientSocketId, (struct sockaddr *)&addr, &addrLen);
            success = (error == 0);
            
            if (success) {
                NSLog(@"client connect success, host address:%s,port:%d",
                      inet_ntoa(addr.sin_addr),
                      ntohs(addr.sin_port));
                self.createSuccess = YES;
                if (successBlock) {
                    successBlock(self);
                }
            }
        } else {
            NSLog(@"connect failed");
            
            [self closeClient];
        }
    }
}

- (void)tcpServerWithSuccessBlock:(void (^)(DWSocketUtils * aClient))successBlock
                          handler:(void (^)(DWSocketUtils *, NSString *))handler
{
    // 第一步：创建socket
    int error = -1;
    
    // 创建socket套接字
    int serverSocketId = socket(AF_INET, SOCK_STREAM, 0);
    // 判断创建socket是否成功
    BOOL success = (serverSocketId != -1);
    
    // 第二步：绑定端口号
    if (success) {
        NSLog(@"server socket create success");
        // Socket address
        struct sockaddr_in addr;
        
        // 初始化全置为0
        memset(&addr, 0, sizeof(addr));
        
        // 指定socket地址长度
        addr.sin_len = sizeof(addr);
        
        // 指定网络协议，比如这里使用的是TCP/UDP则指定为AF_INET
        addr.sin_family = AF_INET;
        
        // 指定端口号
        addr.sin_port = htons(self.port);
        
        // 指定监听的ip，指定为INADDR_ANY时，表示监听所有的ip
        addr.sin_addr.s_addr = INADDR_ANY;
        
        // 绑定套接字
        error = bind(serverSocketId, (const struct sockaddr *)&addr, sizeof(addr));
        success = (error == 0);
    }
    
    // 第三步：监听
    if (success) {
        NSLog(@"bind server socket success");
        error = listen(serverSocketId, 5);
        success = (error == 0);
    }
    
    if (success) {
        NSLog(@"listen server socket success");
        while (self.listen) {
            // p2p
            struct sockaddr_in peerAddr;
            int peerSocketId;
            socklen_t addrLen = sizeof(peerAddr);
            
            // 第四步：等待客户端连接
            // 服务器端等待从编号为serverSocketId的Socket上接收客户连接请求
            peerSocketId = accept(serverSocketId, (struct sockaddr *)&peerAddr, &addrLen);
            success = (peerSocketId != -1);
            self.addr = [NSString stringWithFormat:@"%s",inet_ntoa(peerAddr.sin_addr)];
            if (success) {
                NSLog(@"accept server socket success,remote address:%@,port:%ld",
                      self.addr,
                      self.port);
                if (successBlock) {
                    successBlock(self);
                }
                char buf[1024];
                size_t len = sizeof(buf);
                // 第五步：接收来自客户端的信息
                // 当客户端输入exit时才退出
                do {
                    // 接收来自客户端的信息
                    if (recv(peerSocketId, buf, len, 0) !=0) {
                        if (strlen(buf) != 0) {
                            NSString *str = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                            if (str.length >= 1) {
                                NSLog(@"received message from client：%@",str);
                                if (handler) {
                                    handler(self,str);
                                }
                            }
                        }
                    }
                    else
                    {
                        break;
                    }
                } while (strcmp(buf, "exit") != 0 && strcmp(buf, "shutDown") != 0);
                if (strcmp(buf, "exit") == 0) {
                    NSLog(@"收到exit信号，本次socket通信完毕");
                }
                else if (strcmp(buf, "shutDown") == 0)
                {
                    self.listen = NO;
                    NSLog(@"收到shutDown信号，服务器停止监听");
                    
                }
                else
                {
                    NSLog(@"信号中断");
                }
                close(peerSocketId);
                // 第六步：关闭socket
            }
        }
    }
}

- (void)udpServerWithSuccessBlock:(void (^)(DWSocketUtils * aClient))successBlock
                          handler:(void (^)(DWSocketUtils *))handler
{
    int serverSockerId = -1;
    socklen_t addrlen;
    char buff[1024];
    struct sockaddr_in ser_addr;
    
    // 第一步：创建socket
    // 注意，第二个参数是SOCK_DGRAM，因为udp是数据报格式的
    serverSockerId = socket(AF_INET, SOCK_DGRAM, 0);
    
    if(serverSockerId < 0) {
        NSLog(@"Create server socket fail");
        return;
    }
    self.clientId = serverSockerId;
    addrlen = sizeof(struct sockaddr_in);
    addr_len = addrlen;
    bzero(&ser_addr, addrlen);
    
    ser_addr.sin_family = AF_INET;
    ser_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    ser_addr.sin_port = htons((int)self.port);
    
    // 第二步：绑定端口号
    if(bind(serverSockerId, (struct sockaddr *)&ser_addr, addrlen) < 0) {
        NSLog(@"server connect socket fail");
        return;
    }
    self.createSuccess = YES;
    if (successBlock) {
        successBlock(self);
    }
    do {
        bzero(buff, sizeof(buff));
        if (handler) {
            handler(self);
        }
    } while (self.listen);
    NSLog(@"exit了");
    // 第五步：关闭socket
    close(serverSockerId);
}

- (void)udpClientWithSuccess:(void (^)(DWSocketUtils * aClient))successBlock
                     handler:(void (^)(DWSocketUtils *))handler
{
    int clientSocketId;
    socklen_t addrlen;
    struct sockaddr_in client_sockaddr;
    // 第一步：创建Socket
    clientSocketId = socket(AF_INET, SOCK_DGRAM, 0);
    if(clientSocketId < 0) {
        NSLog(@"creat client socket fail\n");
        return;
    }
    self.clientId = clientSocketId;
    self.createSuccess = YES;
    if (successBlock) {
        successBlock(self);
    }
    addrlen = sizeof(struct sockaddr_in);
    addr_len = addrlen;
    bzero(&client_sockaddr, addrlen);
    client_sockaddr.sin_family = AF_INET;
    client_sockaddr.sin_addr.s_addr = inet_addr(self.addr.UTF8String);
    client_sockaddr.sin_port = htons(self.port);
    sock_addr = client_sockaddr;
    do {
        if (handler) {
            handler(self);
        }
    } while (self.listen);
    close(clientSocketId);
}
@end
