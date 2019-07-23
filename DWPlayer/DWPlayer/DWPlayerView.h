//
//  DWPlayerView.h
//  DWPlayer
//
//  Created by Wicky on 2019/7/23.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWPlayerManager.h"

typedef NS_ENUM(NSUInteger, DWImageVideoResizeMode) {
    DWImageVideoResizeModeScaleAspectFit,
    DWImageVideoResizeModeScaleAspectFill,
    DWImageVideoResizeModeScaleToFill,
};

@interface DWPlayerView : UIView

//The playerManager of current view.
///当前视图的播放核心
@property (nonatomic ,strong) DWPlayerManager * playerManager;

//The resize mode of media.
///当前媒体资源的缩放模式
@property (nonatomic ,assign) DWImageVideoResizeMode resizeMode;

/**
 Config video to display.
 配置当前视频资源
 
 @param url 视频URL
 @para asset 视频asset对象
 @para automaticallyLoadedAssetKeys 自动装载的一些属性
 @return 是否需要配置资源（如果当前资源与配置资源相同，则无需改变）
 */
-(BOOL)configVideoWithURL:(NSURL *)url;
-(BOOL)configVideoWithAsset:(AVAsset *)asset;
-(BOOL)configVideoWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(NSArray<NSString *> *)automaticallyLoadedAssetKeys NS_AVAILABLE(10_9, 7_0);

//Playing control
///播放控制方法
-(void)play;
-(void)pause;
-(void)stop;
-(void)replay;


/**
 Seek to specific time
 跳转至指定时间后，回调
 
 @param time 要跳转到的时间
 @param completionHandler 完成回调
 */
-(void)seekToTime:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler;


/**
 To seek time continuously and the status will on changed on begin and end.
 连续调整时间，此时status只会在begin及end时发生改变
 */
-(void)beginSeekingTime;
-(void)seekToTimeContinuously:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler;
-(void)endSeekingTime;


/**
 Convert CMTime to timeIntercal
 将CMTime转换成时间间隔
 
 @param time 要转换的时间
 @return 转换结果
 */
-(NSTimeInterval)convertCMTimeToTimeInterval:(CMTime)time;


/**
 The duration of specific asset.
 指定资源的实际时长
 
 @param asset 资源
 @return 时长
 */
-(CMTime)actualTimeForAsset:(AVAsset *)asset;

@end
