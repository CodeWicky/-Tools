//
//  DWPlayerViewController.m
//  DWPlayer
//
//  Created by Wicky on 2019/7/23.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWPlayerViewController.h"

@interface DWPlayerViewController ()<DWPlayerManagerProtocol>

@end

@implementation DWPlayerViewController
@dynamic view;

#pragma mark --- interface method ---
-(BOOL)configVideoWithURL:(NSURL *)url {
    return [self.view.playerManager configVideoWithURL:url];
}

-(BOOL)configVideoWithAsset:(AVAsset *)asset {
    return [self.view.playerManager configVideoWithAsset:asset];
}
-(BOOL)configVideoWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(NSArray<NSString *> *)automaticallyLoadedAssetKeys {
    return [self.view.playerManager configVideoWithAsset:asset automaticallyLoadedAssetKeys:automaticallyLoadedAssetKeys];
}

-(void)play {
    [self.view.playerManager play];
}

-(void)pause {
    [self.view.playerManager pause];
}

-(void)stop {
    [self.view.playerManager stop];
}

-(void)replay {
    [self.view.playerManager replay];
}

-(void)seekToTime:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.view.playerManager seekToTime:time completionHandler:completionHandler];
}

-(void)beginSeekingTime {
    [self.view.playerManager beginSeekingTime];
}

-(void)seekToTimeContinuously:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.view.playerManager seekToTimeContinuously:time completionHandler:completionHandler];
}

-(void)endSeekingTime {
    [self.view.playerManager endSeekingTime];
}

-(NSTimeInterval)convertCMTimeToTimeInterval:(CMTime)time {
    return [self.view.playerManager convertCMTimeToTimeInterval:time];
}

-(CMTime)actualTimeForAsset:(AVAsset *)asset {
    return [self.view.playerManager actualTimeForAsset:asset];
}

-(void)playerManagerDidChangeAssetTo:(AVAsset *)desAsset fromAsset:(AVAsset *)oriAsset {
    //Do nothing
}

-(void)playerManagerReadyToPlayForAsset:(AVAsset *)asset {
    //Do nothing
}

-(void)playerManagerSeekToTime:(CMTime)time forAsset:(AVAsset *)asset {
    //Do nothing
}

-(void)playerManagerPlaybackBufferStatusChanged:(BOOL)empty forAsset:(AVAsset *)asset {
    //Do nothing
}

-(void)playerManagerLoadedTimeRangesChangedTo:(NSArray <NSValue *>*)timeRanges forAsset:(AVAsset *)asset {
    //Do nothing
}

-(void)playerManagerDidChangeStatusTo:(DWPlayerStatus)desStatus fromStatus:(DWPlayerStatus)oriStatus forAsset:(AVAsset *)asset {
    //Do nothing
}

-(void)playerManagerPlayerTimeChangeTo:(CMTime)time forAsset:(AVAsset *)asset {
    //Do nothing
}

-(void)playerManagerFinishPlayingAsset:(AVAsset *)asset {
    //Do nothing
}

#pragma mark --- DWPlayerManagerProtocol ---
-(void)playerManager:(DWPlayerManager *)manager didChangeAssetTo:(AVAsset *)desAsset fromAsset:(AVAsset *)oriAsset {
    if (manager == self.view.playerManager) {
        [self playerManagerDidChangeAssetTo:desAsset fromAsset:oriAsset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager readyToPlayForAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerReadyToPlayForAsset:asset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager seekToTime:(CMTime)time forAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerSeekToTime:time forAsset:asset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager playbackBufferStatusChanged:(BOOL)empty forAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerPlaybackBufferStatusChanged:empty forAsset:asset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager loadedTimeRangesChangedTo:(NSArray <NSValue *>*)timeRanges forAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerLoadedTimeRangesChangedTo:timeRanges forAsset:asset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager didChangeStatusTo:(DWPlayerStatus)desStatus fromStatus:(DWPlayerStatus)oriStatus forAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerDidChangeStatusTo:desStatus fromStatus:oriStatus forAsset:asset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager playerTimeChangeTo:(CMTime)time forAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerPlayerTimeChangeTo:time forAsset:asset];
    }
}

-(void)playerManager:(DWPlayerManager *)manager finishPlayingAsset:(AVAsset *)asset {
    if (manager == self.view.playerManager) {
        [self playerManagerFinishPlayingAsset:asset];
    }
}

#pragma mark --- override ---
-(void)loadView {
    [super loadView];
    self.view = [[DWPlayerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.playerManager.delegate = self;
}

@end
