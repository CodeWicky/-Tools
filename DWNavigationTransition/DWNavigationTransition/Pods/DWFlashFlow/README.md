<p align="center" >
<img src="https://github.com/CodeWicky/DWFlashFlow/raw/master/DWFlashFlow.png" width=522px height=144px alt="DWLogger" title="DWLogger">
</p>

## 描述
数据请求框架封装，具有NSOperation系统行为，可方便的进行线程间通信。

它基于AFN作为基础数据请求类，同时功能层和逻辑层的分离设计也使你很方便的更换核心请求库。请求类作为NSOperation的子类可以让你与系统的其他NSOperation子类任意搭配使用。另外，他还扩展了批量请求以及请求链功能，满足你日常数据请求的基本需要。

## Description
It‘s a data request framework which has the same behavior as NSOperation so that you can commit among thread.

It uses AFN as request core, benefits from separation design of functional layer and logic layer you can change the request core easily.The request class is a subclass of NSOperation that lets you use any other NSOperation subclasses of the system. In addition, it expanded the batch request and request chain function to meet the basic needs of your daily data request.

## 功能
- 与系统NSOperation配合使用
- 全局参数
- 批量请求与请求链
- 请求加密
- 请求缓存策略

## Func
- Combine with NSOperation
- Global parameter
- Batch request and request chain
- Request encryption
- Request cache policy

## 如何使用
首先，你应该将所需文件拖入工程中，或者你也可以用Cocoapods去集成他。

```
pod 'DWFlashFlow', '~> 1.0.0'
```

单个请求你可以像这样使用：

```
DWFlashFlowRequest * r = [DWFlashFlowRequest new];
r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
  			NSLog(@"finish");
};
[r start];
```

或者借助DWFlashFlowManager,他是一个提供全局配置的管理者。

```
DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"completion");
    };
    [DWFlashFlowManager sendRequest:r completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"finish");
    }];
```

配合其他NSOperation使用：

```
DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    };
    NSBlockOperation * bP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"The request complete.");
    }];
    
    [bP addDependency:r];
    [[NSOperationQueue new] addOperations:@[bP,r] waitUntilFinished:NO];
```

使用批量请求范例如下：

```
DWFlashFlowRequest * r1 = [DWFlashFlowRequest new];
    r1.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r1.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r1 finish");
    };
    DWFlashFlowRequest * r2 = [DWFlashFlowRequest new];
    r2.fullURL = @"http://ozi0yn414.bkt.clouddn.com/MKJ-Time.mp3";
    r2.requestProgress = ^(NSProgress *progress) {
        NSLog(@"%@",progress);
    };
    r2.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r2 finish");
    };
    r2.requestType = DWFlashFlowRequestTypeDownload;
    DWFlashFlowBatchRequest * bR = [[DWFlashFlowBatchRequest alloc] initWithRequests:@[r1,r2]];
    [DWFlashFlowManager sendRequest:bR completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    }];
```

请求链：

```
DWFlashFlowRequest * r1 = [DWFlashFlowRequest new];
r1.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
r1.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r1 finish");
};
DWFlashFlowRequest * r2 = [DWFlashFlowRequest new];
r2.fullURL = @"http://ozi0yn414.bkt.clouddn.com/MKJ-Time.mp3";
r2.requestProgress = ^(NSProgress *progress) {
        NSLog(@"%@",progress);
};
r2.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r2 finish");
};
r2.requestType = DWFlashFlowRequestTypeDownload;
DWFlashFlowChainRequest * cR = [[DWFlashFlowChainRequest alloc] initWithRequests:@[r1,r2]];
[DWFlashFlowManager sendRequest:cR completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
}];
```

其他的一些使用方法你可以对应查看`.h`文件中的注释。

## Usage

Firstly,drag it into your project or use cocoapods.

```
pod 'DWFlashFlow', '~> 1.0.0'
```

To send a request you may only do such following:

```
DWFlashFlowRequest * r = [DWFlashFlowRequest new];
r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
  			NSLog(@"finish");
};
[r start];
```

You may also use a manager instead:

```
DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"completion");
    };
    [DWFlashFlowManager sendRequest:r completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"finish");
    }];
```

Combine with other NSOperation in this way:

```
DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    };
    NSBlockOperation * bP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"The request complete.");
    }];
    
    [bP addDependency:r];
    [[NSOperationQueue new] addOperations:@[bP,r] waitUntilFinished:NO];
```

An example for batchRequest:

```
DWFlashFlowRequest * r1 = [DWFlashFlowRequest new];
    r1.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r1.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r1 finish");
    };
    DWFlashFlowRequest * r2 = [DWFlashFlowRequest new];
    r2.fullURL = @"http://ozi0yn414.bkt.clouddn.com/MKJ-Time.mp3";
    r2.requestProgress = ^(NSProgress *progress) {
        NSLog(@"%@",progress);
    };
    r2.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r2 finish");
    };
    r2.requestType = DWFlashFlowRequestTypeDownload;
    DWFlashFlowBatchRequest * bR = [[DWFlashFlowBatchRequest alloc] initWithRequests:@[r1,r2]];
    [DWFlashFlowManager sendRequest:bR completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    }];
```

ChainRequest:

```
DWFlashFlowRequest * r1 = [DWFlashFlowRequest new];
r1.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
r1.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r1 finish");
};
DWFlashFlowRequest * r2 = [DWFlashFlowRequest new];
r2.fullURL = @"http://ozi0yn414.bkt.clouddn.com/MKJ-Time.mp3";
r2.requestProgress = ^(NSProgress *progress) {
        NSLog(@"%@",progress);
};
r2.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r2 finish");
};
r2.requestType = DWFlashFlowRequestTypeDownload;
DWFlashFlowChainRequest * cR = [[DWFlashFlowChainRequest alloc] initWithRequests:@[r1,r2]];
[DWFlashFlowManager sendRequest:cR completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
}];
```

Some ohter function you may look up the note in `.h` file.

## 联系作者

你可以通过在[我的Github](https://github.com/CodeWicky/DWFlashFlow)上给我留言或者给我发送电子邮件 codeWicky@163.com 来给我提一些建议或者指出我的bug,我将不胜感激。

如果你喜欢这个小东西，记得给我一个star吧，么么哒~

## Contact With Me
You may issue me on [my Github](https://github.com/CodeWicky/DWFlashFlow) or send me a email at  codeWicky@163.com  to tell me some advices or the bug,I will be so appreciated.

If you like it please give me a star.






