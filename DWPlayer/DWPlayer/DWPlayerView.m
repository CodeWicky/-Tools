//
//  DWPlayerView.m
//  DWPlayer
//
//  Created by Wicky on 2019/7/23.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWPlayerView.h"

@interface DWPlayerView ()

@property (nonatomic ,strong) AVPlayerLayer * playerLayer;

@end

@implementation DWPlayerView

#pragma mark --- interface method ---
-(BOOL)configVideoWithURL:(NSURL *)url {
    return [self.playerManager configVideoWithURL:url];
}

-(BOOL)configVideoWithAsset:(AVAsset *)asset {
    return [self.playerManager configVideoWithAsset:asset];
}

-(BOOL)configVideoWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(NSArray<NSString *> *)automaticallyLoadedAssetKeys {
    return [self.playerManager configVideoWithAsset:asset automaticallyLoadedAssetKeys:automaticallyLoadedAssetKeys];
}

-(void)play {
    [self.playerManager play];
}

-(void)pause {
    [self.playerManager pause];
}

-(void)stop {
    [self.playerManager stop];
}

-(void)replay {
    [self.playerManager replay];
}

-(void)seekToTime:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.playerManager seekToTime:time completionHandler:completionHandler];
}

-(void)beginSeekingTime {
    [self.playerManager beginSeekingTime];
}

-(void)seekToTimeContinuously:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.playerManager seekToTimeContinuously:time completionHandler:completionHandler];
}

-(void)endSeekingTime {
    [self.playerManager endSeekingTime];
}

-(NSTimeInterval)convertCMTimeToTimeInterval:(CMTime)time {
    return [self.playerManager convertCMTimeToTimeInterval:time];
}

-(CMTime)actualTimeForAsset:(AVAsset *)asset {
    return [self.playerManager actualTimeForAsset:asset];
}

#pragma mark --- override ---
+(Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark --- setter/getter ---
-(void)setResizeMode:(DWImageVideoResizeMode)resizeMode {
    if (_resizeMode != resizeMode) {
        _resizeMode = resizeMode;
        switch (resizeMode) {
            case DWImageVideoResizeModeScaleToFill:
            {
                self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            }
                break;
            case DWImageVideoResizeModeScaleAspectFill:
            {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }
                break;
            default:
            {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            }
                break;
        }
    }
}

-(DWPlayerManager *)playerManager {
    if (!_playerManager) {
        _playerManager = [[DWPlayerManager alloc] init];
        [self.playerLayer setPlayer:_playerManager.player];
    }
    return _playerManager;
}

-(AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
