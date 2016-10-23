//
//  UIImageView+DWGifTool.m
//  GifDemo
//
//  Created by Wicky on 16/9/26.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIImageView+DWGifTool.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
@implementation UIImageView (DWGifTool)
-(instancetype)initWithFrame:(CGRect)frame gifPathString:(NSString *)path
                 repeatCount:(CGFloat)repeatCount
{
    self = [super initWithFrame:frame];
    if (self) {
        NSURL * url = [self urlFromString:path];
        NSMutableArray * delayTimeArr = [NSMutableArray array];
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        size_t count = CGImageSourceGetCount(imageSource);
        for (size_t i = 0; i < count; i ++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            [self.gifArray addObject:CFBridgingRelease(image)];
            NSDictionary *dic = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL));
            [delayTimeArr addObject:[[dic valueForKey:(NSString *)kCGImagePropertyGIFDictionary] valueForKey:@"DelayTime"]];
        }
        CGFloat totalTime = [self getTotalTimeFromDelayTimeArray:delayTimeArr];
        self.gifDuration = totalTime;
        NSMutableArray * keyTimes = [self getKeyTimesFromDelayTimeArray:delayTimeArr totalTime:totalTime];
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.duration = totalTime;
        animation.values = self.gifArray;
        animation.keyTimes = keyTimes;
        animation.repeatCount = repeatCount;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.delegate = self;
        self.clipsToBounds = YES;
        [self.layer addAnimation:animation forKey:@"gifAnimation"];
    }
    return self;
}

-(instancetype)initWithGifPathString:(NSString *)path repeatCount:(CGFloat)repeatCount
{
    NSURL * url = [self urlFromString:path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    NSDictionary *dic = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL));
    CGFloat height = [dic[@"PixelHeight"] floatValue];
    CGFloat width = [dic[@"PixelWidth"] floatValue];
    CGRect frame = CGRectMake(0, 0, width, height);
    return [self initWithFrame:frame gifPathString:path repeatCount:repeatCount];
}

-(instancetype)initWithGifPathString:(NSString *)path repeat:(BOOL)repeat
{
    return [self initWithGifPathString:path repeatCount:repeat?MAXFLOAT:1];
}

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

-(NSMutableArray *)gifArray
{
    NSMutableArray * arr = objc_getAssociatedObject(self, _cmd);
    if (!arr) {
        arr = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, arr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return arr;
}

-(void)setGifArray:(NSMutableArray *)gifArray
{
    objc_setAssociatedObject(self, @selector(gifArray), gifArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CGFloat)gifDuration
{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

-(void)setGifDuration:(CGFloat)gifDuration
{
    objc_setAssociatedObject(self, @selector(gifDuration), @(gifDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)animationDidStart:(CAAnimation *)anim
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kImageViewGifStart object:nil];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kImageViewGifFinish object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kImageViewGifCancel object:nil];
    }
}

-(void)suspendGif
{
    CFTimeInterval pausetime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    [self.layer setTimeOffset:pausetime];
    [self.layer setSpeed:0.0f];
}

-(void)resumeGif
{
    CFTimeInterval pausetime = self.layer.timeOffset;
    CFTimeInterval starttime = CACurrentMediaTime() - pausetime;
    self.layer.timeOffset = 0.0;
    self.layer.beginTime = starttime;
    self.layer.speed = 1.0;
}

-(void)invalidGif
{
    [self.layer removeAnimationForKey:@"gifAnimation"];
    self.layer.contents = self.gifArray.firstObject;
}
@end
