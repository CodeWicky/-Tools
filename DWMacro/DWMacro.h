//
//  DWMacro.h
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#ifndef DWMacro_h
#define DWMacro_h

//MARK: - Quick Variable

/****** 引用相关 ******/
///弱引用，使用如：DWWeak(alert) 之后调用weakalert
#define DWWeak(type)  __weak typeof(type) weak##type = type;

///强引用，用法参见弱引用
#define DWStrong(type)  __strong typeof(type) type = weak##type;

/****** IndexPath相关 ******/
///快速生成NSIndexPath
#define DWIndexPath(section,row) ([NSIndexPath indexPathForRow:row inSection:section])

///NSIndexPath的文字化
#define NSStringFromIndexPath(idxP) ([NSString stringWithFormat:@"S%ldR%ld",idxP.section,idxP.row])

/****** 错误相关 ******/
///快速生成error对象
#define DWErrorWithDescription(aCode,desc) ([NSError errorWithDomain:@"com.Wicky.DWWebImage" code:aCode userInfo:@{NSLocalizedDescriptionKey:desc}])

/****** 颜色相关 ******/
///快速以rgba生成UIColor对象
#define DWRGBAColor(r,g,b,a) ([UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a])

///快速以16进制数字生成UIColor对象，使用如：DWHEXColor(0xd8d8d8)
#define DWHexColor(hex) ([UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0])

/****** 字体相关 ******/
#define DWFont(size) ([UIFont systemFontOfSize:size])

/****** 字符串相关 ******/
///快速返回字符串高度
#define DWStringHeight(string,widthLimit,font) ([string boundingRectWithSize:CGSizeMake(widthLimit, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height)

/****** 图片相关 ******/
///快速返回图片，png需文件全名
#define DWImage(name) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]]

/****** 视图相关 ******/
///快速返回视图中心
#define DWViewCenter(view) (CGPointMake(view.bounds.size.width / 2,view.bounds.size.height / 2))

///设备宽度
#define DWDeviceWidth ([UIScreen mainScreen].bounds.size.width)

///设备高度
#define DWDeviceHeight ([UIScreen mainScreen].bounds.size.height)

///状态栏与导航栏高度之和
#define DWHeightUnderNavigationBar 64

///导航栏高度
#define DWHeightOfNavigationBar 44

///选项栏高度
#define DWHeightOfTabBar 49


//MARK: - Additional Function

///安全回到主线程
#define dispatch_async_main_safe(block)\
if ([NSThread currentThread].isMainThread) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(),block);\
}

///改变Layer属性是否需要动画
#define DWLayerTransactionWithAnimation(animated,animationBlock) \
[CATransaction begin];\
if (!animated) {\
[CATransaction setAnimationDuration:0];\
}\
animationBlock();\
[CATransaction commit];\

///角度转弧度
#define DWDegreesToRadian(x) (M_PI * (x) / 180.0)

///弧度转角度
#define DWRadianToDegrees(radian) (radian*180.0)/(M_PI)

///版本判断
#define DW_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define DW_SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define DW_SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define DW_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define DW_SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define DW_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

///设备判断
#define DW_Device_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define DW_Device_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define DW_Device_IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

///Log
#ifdef DEBUG
#define DWLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DWLog(...)
#endif

#endif /* DWMacro_h */
