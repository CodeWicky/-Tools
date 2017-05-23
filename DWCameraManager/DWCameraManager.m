//
//  DWCameraManager.m
//  video
//
//  Created by Wicky on 2017/4/6.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWCameraManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#define SafeStatus \
if (!self.actived || self.isTakingPhoto || self.isCapturing) return;

#define SafeQuickShotTakingPhoto \
if (self.isQuickShoting && !self.quickShotTakingPhoto) return;

@interface DWCameraManager ()<AVCaptureFileOutputRecordingDelegate>
{
    dispatch_queue_t sessionQueue;///统一串行队列
}

///输出视图层
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer * videoLayer;

///捕捉实例
@property (nonatomic ,strong) AVCaptureSession * captureSession;

///后置摄像头输入源
@property (nonatomic ,strong) AVCaptureDeviceInput * backCameraInput;

///前置摄像头输入源
@property (nonatomic ,strong) AVCaptureDeviceInput * frontCameraInput;

///当前视频输入源
@property (nonatomic ,strong) AVCaptureDeviceInput * currentVideoInput;

///麦克风输入源
@property (nonatomic ,strong) AVCaptureInput * audioDeviceInput;

///视频输出类
@property (nonatomic ,strong) AVCaptureMovieFileOutput * videoOutput;

///图像输出类
@property (nonatomic ,strong) AVCaptureStillImageOutput * photoOutput;

///后置摄像头
@property (nonatomic ,strong) AVCaptureDevice * backCamera;

///前置摄像头
@property (nonatomic ,strong) AVCaptureDevice * frontCamera;

///当前摄像头
@property (nonatomic ,strong) AVCaptureDevice * currentCamera;

///麦克风
@property (nonatomic ,strong) AVCaptureDevice * audioDevice;

///文件管理者
@property (nonatomic ,strong) NSFileManager * fileMgr;

///当前捕捉视频名称
@property (nonatomic ,copy) NSString * currentFileName;

///当前视频连接
@property (nonatomic ,strong) AVCaptureConnection * videoConn;

///当前图像连接
@property (nonatomic ,strong) AVCaptureConnection * photoConn;

///连拍需要停止
@property (nonatomic ,assign) BOOL quickShotNeedStop;

///连拍构成的拍摄
@property (nonatomic ,assign) BOOL quickShotTakingPhoto;

///需要连拍张数
@property (nonatomic ,assign) NSUInteger targetQuickShotCount;

@end

@implementation DWCameraManager
@synthesize stabilizationMode = _stabilizationMode;

#pragma mark --- interface method ---
-(void)activeManager {
    if (!self.isActived) {
        dispatch_async(sessionQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

-(void)stopManager {
    if (self.isActived) {
        dispatch_async(sessionQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

-(void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!self.videoLayer) {
        return;
    }
    [CATransaction begin];
    [[self.videoLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)interfaceOrientation];
    [CATransaction commit];
}

-(void)startCaptureWithSaveFolderPath:( NSString *)savePath fileName:(NSString *)fileName {
    if (!self.actived) {
        return;
    }
    savePath = [self handleSavePath:savePath];
    fileName = [self handleFileName:fileName extention:[self autoExtentionForCaptureFileName] atPath:savePath];
    dispatch_async(sessionQueue, ^{
        if (!self.isCapturing) {
            [self createSavePath:savePath];
            self.currentFileName = fileName;
            NSURL * url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",savePath,fileName]];
            [self.videoOutput startRecordingToOutputFileURL:url recordingDelegate:self];
        }
    });
}

-(void)stopCapture {
    if (!self.actived) {
        return;
    }
    dispatch_async(sessionQueue, ^{
        if (self.isCapturing) {
            [self.videoOutput stopRecording];
        }
    });
}

-(void)takePhotoWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName flashMdoe:(AVCaptureFlashMode)flashMode completion:(void (^)(UIImage *,NSString *))completion {
    if (!self.actived) return;
    if (self.isTakingPhoto || self.isCapturing) return;
    if (self.isQuickShoting && !self.quickShotTakingPhoto) return;
    if (!self.quickShotTakingPhoto) _takingPhoto = YES;
    
    NSLog(@"%@",fileName);
    
    savePath = [self handleSavePath:savePath];
    fileName = [self handleFileName:fileName extention:@"jpg" atPath:savePath];
    dispatch_async(sessionQueue, ^{
        NSLog(@"begin");
        if (self.takingPhotoBlock) {
            __weak typeof(self)weakSelf = self;
            self.takingPhotoBlock(weakSelf, fileName);
        }
        
        // Flash set to Auto for Still Capture
        AVCaptureDevice * device = self.currentCamera;
        [self setFlashMode:flashMode forDevice:device];
        
        // Capture a still image.
        [self.photoOutput captureStillImageAsynchronouslyFromConnection:self.photoConn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if (self.autoAddToLibrary) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                    [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
#pragma clang diagnostic pop
                } else {
                    [self createSavePath:savePath];
                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[NSString stringWithFormat:@"%@/%@",savePath,fileName] atomically:YES];
                }
                if (completion) {
                    completion(image,fileName);
                }
                _takingPhoto = NO;
            }
        }];
    });
}

-(void)takePhotoWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName completion:(void (^)(UIImage *,NSString *))completion {
    [self takePhotoWithSaveFolderPath:savePath fileName:fileName flashMdoe:self.flashMode completion:completion];
}

-(void)takePhotoWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName {
    [self takePhotoWithSaveFolderPath:savePath fileName:fileName completion:nil];
}

-(void)quickShotWithCount:(NSUInteger)count saveFolderPath:(NSString *)savePath fileName:(NSString *)fileName flashMode:(AVCaptureFlashMode)flashMode currentPhoto:(void (^)(UIImage * ,NSString *, NSUInteger))currentPhoto completion:(void (^)(NSArray<UIImage *> *))completion {
    if (!self.actived) return;
    if (self.isTakingPhoto || self.isCapturing || self.isQuickShoting) return;
    _quickShoting = YES;
    savePath = [self handleSavePath:savePath];
    fileName = [self handleFileName:fileName extention:@"jpg" atPath:savePath];
    NSLog(@"save Path:%@",savePath);
    __block NSUInteger idx = 0;
    NSMutableArray * photos = [NSMutableArray array];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, sessionQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        self.quickShotTakingPhoto = YES;
        NSString * fullFillName = fixString(fileName, (int)idx);
        idx++;
        [self takePhotoWithSaveFolderPath:savePath fileName:fullFillName flashMdoe:flashMode completion:^(UIImage * photo,NSString * fileName) {
            if (currentPhoto) {
                currentPhoto(photo,fileName,photos.count);
            }
            [photos addObject:photo];
            if (photos.count == self.targetQuickShotCount) {
                self.quickShotNeedStop = NO;
                self.targetQuickShotCount = -1;
                if (completion) {
                    completion(photos);
                }
            }
        }];
        if (idx == count || self.quickShotNeedStop) {
            self.quickShotNeedStop = NO;
            self.targetQuickShotCount = idx;
            _quickShoting = NO;
            dispatch_source_cancel(timer);
        }
        self.quickShotTakingPhoto = NO;
    });
    dispatch_resume(timer);
}

-(void)startQuickShotWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName flashMode:(AVCaptureFlashMode)flashMode currentPhoto:(void (^)(UIImage *, NSString *,NSUInteger))currentPhoto completion:(void (^)(NSArray<UIImage *> *))completion {
    [self quickShotWithCount:MAXFLOAT saveFolderPath:savePath fileName:fileName flashMode:flashMode currentPhoto:currentPhoto completion:completion];
}

-(void)stopQuickShot {
    self.quickShotNeedStop = YES;
}

#pragma mark --- singlton ---
static DWCameraManager * manager = nil;
+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWCameraManager alloc] init];
    });
    return manager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

-(id)copyWithZone:(NSZone *)zone
{
    return manager;
}

#pragma mark --- capture delegate ---
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    if (self.startCaptureBlock) {
        __weak typeof(self)weakSelf = self;
        self.startCaptureBlock(weakSelf,weakSelf.currentFileName);
    }
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    if (self.autoAddToLibrary && (self.mediaType & DWCaptureTypeVideo)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[ALAssetsLibrary new] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error)
            {
                NSLog(@"%@", error);
            } else {
                [self.fileMgr removeItemAtURL:outputFileURL error:nil];
            }
        }];
#pragma clang diagnostic pop
    }
    if (self.stopCaptureBlock) {
        __weak typeof(self)weakSelf = self;
        self.stopCaptureBlock(weakSelf,weakSelf.currentFileName);
    }
    self.currentFileName = nil;
}

#pragma mark --- tool method ---
-(instancetype)init {
    if (self = [super init]) {
        sessionQueue = dispatch_queue_create("sessionQueue.DWCameraManager.com", DISPATCH_QUEUE_SERIAL);
        self.mediaType = DWCaptureTypeMovie;
        [self addOutputIfCould:self.photoOutput];
        [self addOutputIfCould:self.videoOutput];
        [self changePreviewOrientation:UIInterfaceOrientationPortrait];
        _zoomFactor = 1;
    }
    return self;
}

#pragma mark --- 源操作 ---
-(void)addInputIfCould:(AVCaptureInput *)input {
    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }
}

-(void)addOutputIfCould:(AVCaptureOutput *)output {
    if ([self.captureSession canAddOutput:output]) {
        [self.captureSession addOutput:output];
    }
}

-(void)addCameraInput {
    [self addInputIfCould:self.currentVideoInput];
}

#pragma mark --- 处理媒体类型 ---
-(void)handleMediaTypeWithTarget:(DWCaptureType)targetType errorDescription:(NSString *)description {
    AVCaptureInput * input = nil;
    if (targetType == DWCaptureTypeAudio) {
        input = self.audioDeviceInput;
    } else {
        input = self.currentVideoInput;
    }
    if (self.mediaType & targetType) {
        [self addInputIfCould:input];
    } else {
        [self.captureSession removeInput:input];
    }
}

#pragma mark --- 文件管理方法 ---
-(void)createSavePath:(NSString *)path
{
    if (![self.fileMgr fileExistsAtPath:path]) {
        [self.fileMgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

-(NSString *)handleSavePath:(NSString *)savePath {
    if (!savePath.length) {
        return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/DefaultSaveFolder"];
    }
    return savePath;
}

#pragma mark --- 处理文件名 ---
-(NSString *)handleFileName:(NSString *)fileName extention:(NSString *)extention {
    if (!fileName.length) {
        NSString * name = [self getRandomStringInLength:16];
        name = [NSString stringWithFormat:@"%@.%@",name,extention];
        return name;
    }
    return fileName;
}

-(NSString *)handleFileName:(NSString *)fileName extention:(NSString *)extention atPath:(NSString *)path {
    NSString * fileFullName = [self handleFileName:fileName extention:extention];
    if (![self.fileMgr fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",path,fileFullName]]) {
        return fileFullName;
    }
    if (fileName.length) {
        int i = -1;
        NSString * fileExtention = [fileName pathExtension];
        NSString * pureFileName = [fileName stringByDeletingPathExtension];
        do {
            i++;
            fileFullName = [[NSString stringWithFormat:@"%@_%02d",pureFileName,i] stringByAppendingPathExtension:fileExtention];
        } while ([self.fileMgr fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",path,fileFullName]]);
    } else {
        do {
            fileFullName = [self handleFileName:fileName extention:extention];
        } while ([self.fileMgr fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",path,fileFullName]]);
    }
    return fileFullName;
}

-(NSString *)autoExtentionForCaptureFileName {
    switch (self.mediaType) {
        case DWCaptureTypeAudio:
            return @"aac";
        default:
            return @"mov";
    }
}

static inline NSString * fixString(NSString * str ,int i) {
    NSString * extention = [str pathExtension];
    NSString * pureStr = [str stringByDeletingPathExtension];
    pureStr = [pureStr stringByAppendingString:[NSString stringWithFormat:@"_%02d",i]];
    return [pureStr stringByAppendingPathExtension:extention];
}


#pragma mark --- 设置闪光灯 ---
-(void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

#pragma mark --- 设置对焦、曝光 ---
-(void)focusWithMode:(AVCaptureFocusMode)focusMode atPoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async(sessionQueue, ^{
        AVCaptureDevice *device = [self.currentVideoInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
    });
}

-(void)exposeWithMode:(AVCaptureExposureMode)exposeMode atPoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async(sessionQueue, ^{
        AVCaptureDevice *device = [self.currentVideoInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposeMode])
            {
                [device setExposureMode:exposeMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
    });
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async(sessionQueue, ^{
        AVCaptureDevice *device = [self.currentVideoInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
    });
}

-(void)focusAndExposeAtLayerPoint:(CGPoint)layerPoint {
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:[self translateVideoLayerPointToCameraPoint:layerPoint] monitorSubjectAreaChange:YES];
}

-(void)autoFocusAndExpose {
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

-(CGPoint)translateVideoLayerPointToCameraPoint:(CGPoint)layerPoint {
    return [self.videoLayer captureDevicePointOfInterestForPoint:layerPoint];
}

#pragma mark --- 生成随机字符串 ---
-(NSString *)getRandomStringInLength:(NSUInteger)length {
    char data[length];
    for (int i = 0; i < length; i ++) {
        int ran = arc4random() % 62;
        if (ran < 10) {
            ran += 48;
        } else if (ran < 36) {
            ran += 55;
        } else {
            ran += 61;
        }
        data[i] = (char)ran;
    }
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

#pragma mark --- 分辨率枚举转换 ---
static inline NSString * levelString(DWCameraResolutionLevel level) {
    switch (level) {
        case DWCameraResolutionLevelHigh:
            return AVCaptureSessionPresetHigh;
        case DWCameraResolutionLevelMedium:
            return AVCaptureSessionPresetMedium;
        case DWCameraResolutionLevelLow:
            return AVCaptureSessionPresetLow;
        case DWCameraResolutionLevel1280x720:
            return AVCaptureSessionPreset1280x720;
        case DWCameraResolutionLevel1920x1080:
            return AVCaptureSessionPreset1920x1080;
        case DWCameraResolutionLevel3840x2160:
            return AVCaptureSessionPreset3840x2160;
        case DWCameraResolutionLevelPhoto:
            return AVCaptureSessionPresetPhoto;
        default:
            return AVCaptureSessionPresetHigh;
    }
}

#pragma mark --- 设备属性修改 ---
-(void)changeDeviceProperty:(AVCaptureDevice *)device withBlock:(void(^)(AVCaptureDevice * device))block {
    if (!block) {
        return;
    }
    dispatch_async(sessionQueue, ^{
        [device lockForConfiguration:nil];
        block(device);
        [device unlockForConfiguration];
    });
}

#pragma mark --- setter/getter ---
-(AVCaptureVideoPreviewLayer *)videoLayer {
    return (AVCaptureVideoPreviewLayer *)self.videoView.layer;
}

-(DWCameraManagerView *)videoView {
    if (!_videoView) {
        _videoView = [DWCameraManagerView new];
        _videoView.session = self.captureSession;
        ((AVCaptureVideoPreviewLayer *)_videoView.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    if (self.mediaType & DWCaptureTypeVideo) {
        return _videoView;
    }
    return nil;
}

-(void)setMediaType:(DWCaptureType)mediaType {
    if (_mediaType != mediaType) {
        _mediaType = mediaType;
        [self handleMediaTypeWithTarget:DWCaptureTypeAudio errorDescription:@"can't add audioInput"];
        [self handleMediaTypeWithTarget:DWCaptureTypeVideo errorDescription:@"can't add videoInput"];
    }
}

-(void)setCameraType:(DWCameraType)cameraType {
    if (_cameraType != cameraType) {
        dispatch_async(sessionQueue, ^{
            [self.captureSession beginConfiguration];
            switch (_cameraType) {
                case DWCameraTypeBackCamera:
                    [self.captureSession removeInput:self.backCameraInput];
                    break;
                case DWCaptureTypeFrontCamera:
                    [self.captureSession removeInput:self.frontCameraInput];
                    break;
                default:
                    break;
            }
            _cameraType = cameraType;
            [self addCameraInput];
            self.zoomFactor = 1;
            [self.captureSession commitConfiguration];
        });
    }
}

-(void)setResolutionLevel:(DWCameraResolutionLevel)resolutionLevel {
    if ([self.captureSession canSetSessionPreset:levelString(resolutionLevel)]) {
        [self.captureSession setSessionPreset:levelString(resolutionLevel)];
        _resolutionLevel = resolutionLevel;
    }
}

-(void)setZoomFactor:(CGFloat)zoomFactor {
    AVCaptureDevice * current = self.currentCamera;
    CGFloat max = current.activeFormat.videoMaxZoomFactor;
    zoomFactor = zoomFactor < 1 ? 1 : (zoomFactor > max ? max : zoomFactor);
    if (_zoomFactor != zoomFactor) {
        _zoomFactor = zoomFactor;
        [self changeDeviceProperty:current withBlock:^(AVCaptureDevice *device) {
            device.videoZoomFactor = zoomFactor;
        }];
    }
}

-(CGFloat)maxZoomFactor {
    return self.currentCamera.activeFormat.videoMaxZoomFactor;
}

-(void)setMaxRecordedDuration:(CGFloat)maxRecordedDuration {
    if (_maxRecordedDuration != maxRecordedDuration) {
        _maxRecordedDuration = maxRecordedDuration;
        if (maxRecordedDuration == 0) {
            self.videoOutput.maxRecordedDuration = kCMTimeInvalid;
        } else {
            self.videoOutput.maxRecordedDuration = CMTimeMakeWithSeconds(maxRecordedDuration, 30);///30为默认帧率
        }
    }
}

-(void)setMaxRecordedFileSize:(int64_t)maxRecordedFileSize {
    if (_maxRecordedFileSize != maxRecordedFileSize) {
        _maxRecordedFileSize = maxRecordedFileSize;
        self.videoOutput.maxRecordedFileSize = maxRecordedFileSize;
    }
}

-(AVCaptureVideoStabilizationMode)stabilizationMode {
    if ([self.videoConn isVideoStabilizationSupported]) {
        return self.videoConn.preferredVideoStabilizationMode;
    }
    return AVCaptureVideoStabilizationModeOff;
}

-(void)setStabilizationMode:(AVCaptureVideoStabilizationMode)stabilizationMode {
    if ([self.videoConn isVideoStabilizationSupported]) {
        self.videoConn.preferredVideoStabilizationMode = stabilizationMode;
    }
}

-(void)setMirrored:(BOOL)mirrored {
    if ([self.videoConn isVideoMirroringSupported]) {
        self.videoConn.videoMirrored = mirrored;
        self.photoConn.videoMirrored = mirrored;
        if (mirrored) {
            self.videoLayer.transform = CATransform3DMakeScale(-1, 1, 1);
        } else {
            self.videoLayer.transform = CATransform3DIdentity;
        }
    }
}

-(BOOL)isMirrored {
    return self.videoConn.videoMirrored;
}

-(void)setTorchOn:(BOOL)on {
    if (self.photoOutput.isCapturingStillImage) {
        return;
    }
    if ([self.backCamera hasTorch] && self.backCamera.isTorchAvailable) {
        [self changeDeviceProperty:self.backCamera withBlock:^(AVCaptureDevice *device) {
            if (device.torchActive && !on && [device isTorchModeSupported:AVCaptureTorchModeOff]) {
                _torchOn = on;
                [device setTorchMode:AVCaptureTorchModeOff];
            } else if (!device.torchActive && on && [device isTorchModeSupported:AVCaptureTorchModeOn]) {
                _torchOn = on;
                [device setTorchMode:AVCaptureTorchModeOn];
            }
        }];
    }
}

-(void)setEnableHDR:(BOOL)enableHDR {
    AVCaptureDevice * CDevice = self.currentCamera;
    if (!CDevice.activeFormat.isVideoHDRSupported) {
        return;
    }
    if (_enableHDR != enableHDR) {
        _enableHDR = enableHDR;
        [self changeDeviceProperty:CDevice withBlock:^(AVCaptureDevice *device) {
            device.videoHDREnabled = enableHDR;
        }];
    }
}

-(BOOL)isActived {
    return self.captureSession.isRunning;
}

-(BOOL)isCapturing {
    return self.videoOutput.isRecording;
}

-(AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [AVCaptureSession new];
    }
    return _captureSession;
}

-(AVCaptureDeviceInput *)backCameraInput {
    if (!_backCameraInput) {
        NSError * error = nil;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backCamera error:&error];
        if (error || !self.backCamera || !_backCameraInput) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DWCaptureDeviceBackCameraErrorNotification object:error];
            return nil;
        }
    }
    return _backCameraInput;
}

-(AVCaptureDeviceInput *)frontCameraInput {
    if (!_frontCameraInput) {
        NSError * error = nil;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.frontCamera error:&error];
        if (error || !self.frontCamera || !_frontCameraInput) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DWCaptureDeviceFrontCameraErrorNotification object:error];
            return nil;
        }
    }
    return _frontCameraInput;
}

-(AVCaptureDeviceInput *)currentVideoInput {
    switch (self.cameraType) {
        case DWCameraTypeBackCamera:
            return self.backCameraInput;
        case DWCaptureTypeFrontCamera:
            return self.frontCameraInput;
        default:
            return nil;
    }
}

-(AVCaptureInput *)audioDeviceInput {
    if (!_audioDeviceInput) {
        NSError * error = nil;
        _audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&error];
        if (error || !self.audioDevice || !_audioDeviceInput) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DWCaptureDeviceMicroErrorNotification object:error];
            return nil;
        }
    }
    return _audioDeviceInput;
}

-(AVCaptureMovieFileOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [AVCaptureMovieFileOutput new];
        AVCaptureConnection *connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported])
        {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
        }
    }
    return _videoOutput;
}

-(AVCaptureStillImageOutput *)photoOutput {
    if (!_photoOutput) {
        _photoOutput = [AVCaptureStillImageOutput new];
        _photoOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    }
    return _photoOutput;
}

-(AVCaptureDevice *)backCamera {
    if (!_backCamera) {
        NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice * dev in devices) {
            if (dev.position == AVCaptureDevicePositionBack) {
                _backCamera = dev;
                break;
            }
        }
    }
    return _backCamera;
}

-(AVCaptureDevice *)frontCamera {
    if (!_frontCamera) {
        NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice * dev in devices) {
            if (dev.position == AVCaptureDevicePositionFront) {
                _frontCamera = dev;
                break;
            }
        }
    }
    return _frontCamera;
}

-(AVCaptureDevice *)currentCamera {
    switch (self.cameraType) {
        case DWCameraTypeBackCamera:
            return self.backCamera;
        case DWCaptureTypeFrontCamera:
            return self.frontCamera;
        default:
            return nil;
    }
}

-(AVCaptureDevice *)audioDevice {
    if (!_audioDevice) {
        _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    return _audioDevice;
}

-(NSFileManager *)fileMgr {
    if (!_fileMgr) {
        _fileMgr = [NSFileManager defaultManager];
    }
    return _fileMgr;
}

-(AVCaptureConnection *)videoConn {
    return [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
}

-(AVCaptureConnection *)photoConn {
    return [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
}
@end

@implementation DWCameraManagerView

+(Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

-(AVCaptureSession *)session {
    return ((AVCaptureVideoPreviewLayer *)self.layer).session;
}

-(void)setSession:(AVCaptureSession *)session {
    ((AVCaptureVideoPreviewLayer *)self.layer).session = session;
}
@end
