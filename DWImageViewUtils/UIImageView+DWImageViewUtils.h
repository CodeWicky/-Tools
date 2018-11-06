//
//  UIImageView+DWImageViewUtils.h
//  a
//
//  Created by Wicky on 2018/9/28.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///序列帧播放
@protocol DWImageViewAniamtionProtocol<NSObject>

-(void)dw_animationDidStart:(UIImageView *)imgV;

-(void)dw_animationDidStop:(UIImageView *)imgV finished:(BOOL)flag;

@end

@interface UIImageView (DWImageViewAniamtionUtils)

@property (nonatomic ,strong ,readonly ,nullable) NSArray * dw_animationImages;

@property (nonatomic ,assign) BOOL dw_animationRemoveOnCompletion;

@property (nonatomic ,copy) CAMediaTimingFillMode dw_fillMode;

@property (nonatomic ,weak) id<DWImageViewAniamtionProtocol> delegate;

/**
 以URL初始化动画

 @param frame 尺寸
 @param path 图片URL
 @param repeatCount 重复次数
 @return imageView实例
 */
-(instancetype)initWithFrame:(CGRect)frame gifPathString:(NSString *)path
                 repeatCount:(float)repeatCount;

/**
 以URL配置动画

 @param path 图片URL
 @param repeatCount 重复次数
 
 @desc 1.为异步过程，内部去远程加载图片后配置动画
       2.可与start等操作一同调用，内部将在动画配置完成后在实际执行播放动画操作
 */
-(void)dw_configWithGifPathString:(NSString *)path
                      repeatCount:(float)repeatCount;

/**
 以图片初始化动画

 @param frame 尺寸
 @param images 图片数组
 @param duration 数组播放一次的时长
 @param repeatCount 播放次数
 @return imageView实例
 */
-(instancetype)initWithFrame:(CGRect)frame
             animationImages:(NSArray <UIImage *>*)images
                    duration:(CGFloat)duration
                 repeatCount:(float)repeatCount;

/**
 以数组配置动画

 @param images 图片数组
 @param duration 数组播放一次的时长
 @param repeatCount 播放次数
 
 @desc 1.为异步过程，内部加载图片后配置动画
       2.可与start等操作一同调用，内部将在动画配置完成后在实际执行播放动画操作
 */
-(void)dw_configWithAnimationImages:(NSArray <UIImage *>*)images
                           duration:(CGFloat)duration
                        repeatCount:(float)repeatCount;

/**
 开始动画
 
 @desc 异步过程，调用后，只有当动画配置完成后才开始播放
 */
-(void)dw_startAnimation;

/**
 暂停动画
 
 @desc 异步过程，调用后，只有当动画配置完成后才可以暂停动画
 */
-(void)dw_suspendAnimation;

/**
 销毁动图
 
 @desc 1.异步过程，调用后，只有当动画配置完成后才可以销毁动图
       2.销毁后仍可以通过start回复开始动画
       3.销毁后仍可以查看dw_animationImages数组
 */
-(void)dw_invalidAnimation;

/**
 清除动画及相关状态
 
 @desc 1.异步过程，调用后，只有当动画配置完成后才可以清除动画
       2.清除后不能通过start回复动画，直到再次config动画完成之后
       3.清除后dw_animationImages数组将被清空
 */
-(void)dw_clearAnimation;

@end

NS_ASSUME_NONNULL_END
