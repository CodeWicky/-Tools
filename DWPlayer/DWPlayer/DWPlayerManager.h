//
//  DWPlayerManager.h
//  DWPlayer
//
//  Created by Wicky on 2019/7/23.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DWPlayerStatus) {
    //Initial status that there's no meida.
    ///初始状态
    DWPlayerUnknown,
    //Status between config video and ready to play which indicates the video view is processing data.
    ///表明当前video view正在处理数据，这个状态位于configVideo后，readyToPlay之前。
    DWPlayerProcessing,
    DWPlayerReadyToPlay,
    DWPlayerPlaying,
    DWPlayerSeekingProgress,
    DWPlayerPaused,
    DWPlayerFinished,
    DWPlayerFailed,
};

@class DWPlayerManager;
@protocol DWPlayerManagerProtocol <NSObject>
@optional
-(void)playerManager:(DWPlayerManager *)manager didChangeAssetTo:(AVAsset *)desAsset fromAsset:(AVAsset *)oriAsset;

-(void)playerManager:(DWPlayerManager *)manager readyToPlayForAsset:(AVAsset *)asset;

-(void)playerManager:(DWPlayerManager *)manager seekToTime:(CMTime)time forAsset:(AVAsset *)asset;

-(void)playerManager:(DWPlayerManager *)manager playbackBufferStatusChanged:(BOOL)empty forAsset:(AVAsset *)asset;

-(void)playerManager:(DWPlayerManager *)manager loadedTimeRangesChangedTo:(NSArray <NSValue *>*)timeRanges forAsset:(AVAsset *)asset;

-(void)playerManager:(DWPlayerManager *)manager didChangeStatusTo:(DWPlayerStatus)desStatus fromStatus:(DWPlayerStatus)oriStatus forAsset:(AVAsset *)asset;

-(void)playerManager:(DWPlayerManager *)manager playerTimeChangeTo:(CMTime)time forAsset:(AVAsset *)asset;

-(void)playerManager:(DWPlayerManager *)manager finishPlayingAsset:(AVAsset *)asset;

@end

//DWPlayerManager is a manager for media control.
///DWPlayerManager是一个媒体播放的管理类
@interface DWPlayerManager : NSObject

//Delegate of video view.
///代理
@property (nonatomic ,weak) id<DWPlayerManagerProtocol> delegate;

//The player core of video view.
///播放核心
@property (nonatomic ,strong ,readonly) AVPlayer * player;

//Current asset which is displaying.
///当前正在展示的asset
@property (nonatomic ,strong ,readonly) AVAsset * currentAsset;

//Current status of video view.KVO supported.
///当前的状态，支持KVO
@property (nonatomic ,assign ,readonly) DWPlayerStatus status;

//The time interval between each time calling -playerManager:playerTimeChangeTo:forAsset: .
///每次 -playerManager:playerTimeChangeTo:forAsset: 调用的时间间隔。
@property (nonatomic ,assign) NSTimeInterval timeIntervalForPlayerTimeObserver;

//The play rate of video view.
///媒体播放速率
@property (nonatomic ,assign) CGFloat rate;


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
