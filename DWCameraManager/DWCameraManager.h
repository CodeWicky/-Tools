//
//  DWCameraManager.h
//  video
//
//  Created by Wicky on 2017/4/6.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWCameraManager
 媒体捕捉管理类
 提供快捷API进行照相、摄像
 
 version 1.0.0
 视频捕捉支持
 图像捕捉支持
 分辨率更改支持
 手电筒支持
 闪关灯/曝光/对焦支持
 自动加入媒体库支持（纯音频模式不会加入媒体库）
 
 version 1.0.1
 拍摄回调
 缩放支持
 HDR模式支持
 最大录制时长支持
 连拍支持
 照片方向修正
 
 version 1.0.2
 连拍修正
 照片、视频方向修正
 
 version 1.0.3
 连拍模式文件名修复
 连拍修正
 
 version 1.0.4
 视图除数层改为UIView子类
 屏幕旋转方向bug修复
 镜像bug修复
 
 */
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

///获取后置摄像头错误通知
#define DWCaptureDeviceBackCameraErrorNotification @"DWCaptureDeviceBackCameraErrorNotification"

///获取前置摄像头错误通知
#define DWCaptureDeviceFrontCameraErrorNotification @"DWCaptureDeviceFrontCameraErrorNotification"

///获取麦克风错误通知
#define DWCaptureDeviceMicroErrorNotification @"DWCaptureDeviceMicroErrorNotification"

typedef NS_OPTIONS(NSUInteger, DWCaptureType) {///设置捕捉类型
    DWCaptureTypeAudio = 1 << 0,///捕捉音频
    DWCaptureTypeVideo = 1 << 1,///捕捉视频
    DWCaptureTypeMovie = DWCaptureTypeAudio | DWCaptureTypeVideo,///同时捕捉音频视频
};

typedef NS_ENUM(NSUInteger, DWCameraType) {///摄像头类型
    DWCameraTypeBackCamera,///后置摄像头
    DWCaptureTypeFrontCamera,///前置摄像头
    DWCameraTypeUndefined,///未定义
};

typedef NS_ENUM(NSUInteger, DWCameraResolutionLevel) {///分辨率
    DWCameraResolutionLevelHigh,///默认，预置高分辨率
    DWCameraResolutionLevelMedium,///预置中分辨率
    DWCameraResolutionLevelLow,///预置低分辨率
    DWCameraResolutionLevel1280x720,///1280 * 720
    DWCameraResolutionLevel1920x1080,///1920 * 1080
    DWCameraResolutionLevel3840x2160,///3840 * 2160
    DWCameraResolutionLevelPhoto,///全分辨率（最高）
};

@class DWCameraManagerView;
@interface DWCameraManager : NSObject

///输出视图层
@property (nonatomic ,strong) DWCameraManagerView * videoView;

///开始捕捉回调
@property (nonatomic ,copy) void (^startCaptureBlock)(DWCameraManager * mgr,NSString * fileName);

///结束捕捉回调
@property (nonatomic ,copy) void (^stopCaptureBlock)(DWCameraManager * mgr,NSString * fileName);

///照相中回调
@property (nonatomic ,copy) void (^takingPhotoBlock)(DWCameraManager * mgr,NSString * fileName);

///捕获类型
@property (nonatomic ,assign) DWCaptureType mediaType;

///摄像头类型
@property (nonatomic ,assign) DWCameraType cameraType;

///闪光灯类型
@property (nonatomic ,assign) AVCaptureFlashMode flashMode;

///分辨率
@property (nonatomic ,assign) DWCameraResolutionLevel resolutionLevel;

///缩放比例（大于1，当输入比例大于设备支持最大比例时按最大比例设置）
@property (nonatomic ,assign) CGFloat zoomFactor;

///最大缩放比例(取决于当前设备)
@property (nonatomic ,assign ,readonly) CGFloat maxZoomFactor;

///最大录制时间(0为无限制)
@property (nonatomic ,assign) CGFloat maxRecordedDuration;

///最大录制文件大小(0为无限制)
@property (nonatomic ,assign) int64_t maxRecordedFileSize;

///防抖模式
@property (nonatomic ,assign) AVCaptureVideoStabilizationMode stabilizationMode;

///镜像
@property (nonatomic ,assign,getter = isMirrored) BOOL mirrored;

///手电筒
@property (nonatomic ,assign,getter = isTorchOn) BOOL torchOn;

///HDR模式
@property (nonatomic ,assign,getter= isHDREnabled) BOOL enableHDR;

///已激活
@property (nonatomic ,assign ,readonly ,getter = isActived) BOOL actived;

///正在录制
@property (nonatomic ,assign ,readonly ,getter = isCapturing) BOOL capturing;

///正在拍照
@property (nonatomic ,assign ,readonly ,getter = isTakingPhoto) BOOL takingPhoto;

///正在连拍
@property (nonatomic ,assign ,readonly ,getter = isQuickShoting) BOOL quickShoting;

///自动加入相册，DWCaptureTypeVideo、DWCaptureTypeMovie有效
@property (nonatomic ,assign) BOOL autoAddToLibrary;

///单例
+(instancetype)shareManager;

///激活，激活后视图输出层输出图像
-(void)activeManager;

///停止捕捉
-(void)stopManager;


/**
 改变预览方向

 @param interfaceOrientation 目标方向
 
 注：当屏幕方向发生改变时，应该调用此方法进而修正捕获方向
 */
-(void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 开始录制音、视频

 @param savePath 保存路径，可为nil，保存至默认路径
 @param fileName 保存文件名，可为nil，保存为随机16位字符串文件名及对应格式
 
 注：对于重复文件名均会自动校正，以防止文件覆盖
 */
-(void)startCaptureWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName;

///停止录制
-(void)stopCapture;

/**
 照相

 @param savePath 保存路径，可为nil，保存至默认路径
 @param fileName 保存文件名，可为nil，保存为随机16位字符串文件名及对应格式
 
 注：
 1.对于重复文件名均会自动校正，以防止文件覆盖
 2.以单例类的闪光灯模式进行拍照
 */
-(void)takePhotoWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName;


/**
 照相

 @param savePath 保存路径，可为nil，保存至默认路径
 @param fileName 保存文件名，可为nil，保存为随机16位字符串文件名及对应格式
 @param completion 成功后回调
 
 注：
 1.对于重复文件名均会自动校正，以防止文件覆盖
 2.以单例类的闪光灯模式进行拍照
 */
-(void)takePhotoWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName completion:(void(^)(UIImage * photo,NSString * fileName))completion;


/**
 照相

 @param savePath 保存路径，可为nil，保存至默认路径
 @param fileName 保存文件名，可为nil，保存为随机16位字符串文件名及对应格式
 @param flashMode 闪关灯模式，可以指定本次闪光灯模式
 @param completion 成功后回调
 
 注：
 1.对于重复文件名均会自动校正，以防止文件覆盖
 */
-(void)takePhotoWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName flashMdoe:(AVCaptureFlashMode)flashMode completion:(void (^)(UIImage * photo,NSString * fileName))completion;



/**
 以张数开始快速连拍

 @param count 连拍张数
 @param savePath 保存路径
 @param fileName 保存文件名
 @param flashMode 闪光灯模式
 @param currentPhoto 每张照片完成回调
 @param completion 连拍完成回调
 */
-(void)quickShotWithCount:(NSUInteger)count saveFolderPath:(NSString *)savePath fileName:(NSString *)fileName flashMode:(AVCaptureFlashMode)flashMode currentPhoto:(void(^)(UIImage * photo,NSString * fileName,NSUInteger idx))currentPhoto completion:(void (^)(NSArray <UIImage *>* photos))completion;


/**
 开始快速连拍

 @param savePath 保存路径
 @param fileName 保存文件名
 @param flashMode 闪光灯模式
 @param currentPhoto 每张照片完成回调
 @param completion 连拍完成回调
 */
-(void)startQuickShotWithSaveFolderPath:(NSString *)savePath fileName:(NSString *)fileName flashMode:(AVCaptureFlashMode)flashMode currentPhoto:(void(^)(UIImage * photo,NSString * fileName,NSUInteger idx))currentPhoto completion:(void (^)(NSArray <UIImage *>* photos))completion;

///结束快速连拍（与-startQuickShotWithSaveFolderPath:fileName:flashMode:currentPhoto:completion:配合使用）
-(void)stopQuickShot;

/**
 将系统坐标点转换为设备坐标点（因为摄像头坐标与系统坐标不同）

 @param layerPoint 系统坐标
 @return 设备坐标
 */
-(CGPoint)translateVideoLayerPointToCameraPoint:(CGPoint)layerPoint;


/**
 自动按点对焦及曝光

 @param layerPoint 输出视图层上的点
 
 注：即系统坐标系的点，无需转换至设备坐标
 */
-(void)focusAndExposeAtLayerPoint:(CGPoint)layerPoint;

///

/**
 设置为自动对焦及调整曝光
 
 注：当系统发出AVCaptureDeviceSubjectAreaDidChangeNotification通知后，如果需要，你最好调用一下此API。
 */
-(void)autoFocusAndExpose;

/**
 按设备坐标对焦

 @param focusMode 对焦模式
 @param point 设备坐标（需将系统坐标转换至设备坐标）
 @param monitorSubjectAreaChange 是否监测子区域变化
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode atPoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange;


/**
 按设备坐标曝光

 @param exposeMode 曝光模式
 @param point 设备坐标（需将系统坐标转换至设备坐标）
 @param monitorSubjectAreaChange 是否监测子区域变化
 */
-(void)exposeWithMode:(AVCaptureExposureMode)exposeMode atPoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange;

///按设备坐标对焦及曝光
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange;

@end

@interface DWCameraManagerView : UIView

@property (nonatomic ,strong) AVCaptureSession * session;

@end
