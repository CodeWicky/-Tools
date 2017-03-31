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

///快速生成NSIndexPath
#define DWIndexPath(section,row) [NSIndexPath indexPathForRow:row inSection:section]

///NSIndexPath的文字化
#define NSStringFromIndexPath(idxP) [NSString stringWithFormat:@"S%ldR%ld",idxP.section,idxP.row]

///快速生成error对象
#define DWErrorWithDescription(aCode,desc) [NSError errorWithDomain:@"com.Wicky.DWWebImage" code:aCode userInfo:@{NSLocalizedDescriptionKey:desc}]

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


#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

#endif /* DWMacro_h */
