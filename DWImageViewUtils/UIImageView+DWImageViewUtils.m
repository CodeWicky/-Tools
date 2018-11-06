//
//  UIImageView+DWImageViewUtils.m
//  a
//
//  Created by Wicky on 2018/9/28.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "UIImageView+DWImageViewUtils.h"
#import <objc/runtime.h>

#define WorkInOperateQueue(OQA,MQA) \
do {\
dispatch_async(self.operateQueue, ^{\
OQA;\
dispatch_async(dispatch_get_main_queue(), ^{\
MQA;\
});\
});\
} while (0)

#define WorkInSafeQueue(MQA) WorkInOperateQueue({},MQA)

@interface UIImageView ()<CAAnimationDelegate>

@property (nonatomic ,strong) CAAnimation * ani;

@property (nonatomic ,strong) dispatch_queue_t operateQueue;

@end

@implementation UIImageView (DWImageViewAniamtionUtils)

-(instancetype)initWithFrame:(CGRect)frame gifPathString:(NSString *)path repeatCount:(float)repeatCount {
    if (self = [super initWithFrame:frame]) {
        self.dw_animationRemoveOnCompletion = NO;
        self.dw_fillMode = kCAFillModeForwards;
        [self dw_configWithGifPathString:path repeatCount:repeatCount];
    }
    return self;
}

-(void)dw_configWithGifPathString:(NSString *)path repeatCount:(float)repeatCount {
    [self dw_clearAnimation];
    if (!path.length || repeatCount == 0) {
        return;
    }
    WorkInOperateQueue(
        NSURL * url = [self urlFromString:path];
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        size_t count = CGImageSourceGetCount(imageSource);
        NSMutableArray * imagesArr = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray * delayTimeArr = [NSMutableArray arrayWithCapacity:count];
        for (size_t i = 0; i < count; i ++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            [imagesArr addObject:CFBridgingRelease(image)];
            NSDictionary *dic = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL));
            [delayTimeArr addObject:[[dic valueForKey:(NSString *)kCGImagePropertyGIFDictionary] valueForKey:@"DelayTime"]];
        }
        CGFloat totalTime = [self getTotalTimeFromDelayTimeArray:delayTimeArr];
        self.dw_animationImages = [imagesArr copy];
        NSMutableArray * keyTimes = [self getKeyTimesFromDelayTimeArray:delayTimeArr totalTime:totalTime];
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.duration = totalTime;
        animation.values = imagesArr;
        animation.keyTimes = keyTimes;
        animation.repeatCount = repeatCount;
        animation.fillMode = self.dw_fillMode;
        animation.removedOnCompletion = self.dw_animationRemoveOnCompletion;
        animation.delegate = self;
    , {
        self.animationDuration = totalTime;
        self.animationRepeatCount = repeatCount;
        self.ani = animation;
    });
}

-(instancetype)initWithFrame:(CGRect)frame animationImages:(NSArray<UIImage *> *)images duration:(CGFloat)duration repeatCount:(float)repeatCount {
    if (self = [super initWithFrame:frame]) {
        self.dw_animationRemoveOnCompletion = NO;
        self.dw_fillMode = kCAFillModeForwards;
        [self dw_configWithAnimationImages:images duration:duration repeatCount:repeatCount];
    }
    return self;
}

-(void)dw_configWithAnimationImages:(NSArray<UIImage *> *)images duration:(CGFloat)duration repeatCount:(float)repeatCount {
    [self dw_clearAnimation];
    if (!images.count || duration == 0 || repeatCount == 0) {
        return;
    }
    WorkInOperateQueue(
        NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:images.count];
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGImageRef image = obj.CGImage;
            [tmp addObject:CFBridgingRelease(image)];
        }];
        self.dw_animationImages = [tmp copy];
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.duration = duration;
        animation.values = tmp;
        animation.repeatCount = repeatCount;
        animation.fillMode = self.dw_fillMode;
        animation.removedOnCompletion = self.dw_animationRemoveOnCompletion;
        animation.delegate = self;
    , {
        self.animationDuration = duration;
        self.animationRepeatCount = repeatCount;
        self.ani = animation;
    });
}

-(void)dw_startAnimation {
    WorkInSafeQueue({
        [self.layer addAnimation:self.ani forKey:@"imagesAnimation"];
    });
}

-(void)dw_suspendAnimation {
    WorkInSafeQueue({
        CFTimeInterval pausetime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        [self.layer setTimeOffset:pausetime];
        [self.layer setSpeed:0.0f];
    });
}

-(void)dw_invalidAnimation {
    WorkInSafeQueue({
        [self.layer removeAnimationForKey:@"imagesAnimation"];
        [self handleCompleteImage];
    });
}

-(void)dw_clearAnimation {
    WorkInSafeQueue({
        [self.layer removeAnimationForKey:@"imagesAnimation"];
        [self handleCompleteImage];
        self.ani = nil;
        self.dw_animationImages = nil;
    });
}

#pragma mark --- delegate ---
-(void)animationDidStart:(CAAnimation *)anim {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dw_animationDidStart:)]) {
        [self.delegate dw_animationDidStart:self];
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dw_animationDidStop:finished:)]) {
        [self.delegate dw_animationDidStop:self finished:flag];
    }
    if (self.dw_animationRemoveOnCompletion) {
        [self handleCompleteImage];
    }
}

#pragma mark --- tool method ---
-(CGFloat)getTotalTimeFromDelayTimeArray:(NSMutableArray *)arr
{
    CGFloat total = 0;
    for (NSNumber * delay in arr) {
        total += delay.floatValue;
    }
    return total;
}

-(NSMutableArray *)getKeyTimesFromDelayTimeArray:(NSMutableArray *)delayTimeArray
                                       totalTime:(CGFloat)totalTime
{
    NSMutableArray * arr = [NSMutableArray array];
    [arr addObject:@0];
    CGFloat current = 0;
    for (NSNumber * num in delayTimeArray) {
        current += num.floatValue;
        [arr addObject:@(current / totalTime)];
    }
    return arr;
}

-(NSURL *)urlFromString:(NSString *)path
{
    if ([path hasPrefix:@"http"]) {
        return [NSURL URLWithString:path];
    }
    return [NSURL fileURLWithPath:path];
}

-(void)handleCompleteImage {
    if ([self.dw_fillMode isEqualToString:kCAFillModeForwards]) {
        self.layer.contents = self.dw_animationImages.lastObject;
    } else if ([self.dw_fillMode isEqualToString:kCAFillModeBackwards]) {
        self.layer.contents = self.dw_animationImages.firstObject;
    }
}

#pragma mark --- setter/getter ---
-(NSArray *)dw_animationImages {
    NSMutableArray * arr = objc_getAssociatedObject(self, _cmd);
    if (!arr) {
        arr = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, arr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return arr;
}

-(void)setDw_animationImages:(NSArray * _Nonnull)dw_animationImages {
    objc_setAssociatedObject(self, @selector(dw_animationImages), dw_animationImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CAAnimation *)ani {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setAni:(CAAnimation *)ani {
    objc_setAssociatedObject(self, @selector(ani), ani, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id<DWImageViewAniamtionProtocol>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setDelegate:(id<DWImageViewAniamtionProtocol>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)dw_animationRemoveOnCompletion {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setDw_animationRemoveOnCompletion:(BOOL)dw_animationRemoveOnCompletion {
    objc_setAssociatedObject(self, @selector(dw_animationRemoveOnCompletion), @(dw_animationRemoveOnCompletion), OBJC_ASSOCIATION_ASSIGN);
    if (self.ani) {
        self.ani.removedOnCompletion = dw_animationRemoveOnCompletion;
    }
}

-(CAMediaTimingFillMode)dw_fillMode {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setDw_fillMode:(CAMediaTimingFillMode)dw_fillMode {
    objc_setAssociatedObject(self, @selector(dw_fillMode), dw_fillMode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.ani) {
        self.ani.fillMode = dw_fillMode;
    }
}

-(dispatch_queue_t)operateQueue {
    dispatch_queue_t q = objc_getAssociatedObject(self, _cmd);
    if (!q) {
        q = dispatch_queue_create("com.DWImageViewUtils.queue", NULL);
        objc_setAssociatedObject(self, @selector(operateQueue), q, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return q;
}
@end
