//
//  DWTransformUtils.h
//  layer
//
//  Created by Wicky on 16/12/25.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWTransformLeanType) {///倾斜类型
    DWTransformLeanTypeTopSideToLeft,///顶边左倾
    DWTransformLeanTypeTopSideToRight,///顶边右倾
    DWTransformLeanTypeBottomSideToLeft,///底边左倾
    DWTransformLeanTypeBottomSideToRight,///底边右倾
    DWTransformLeanTypeLeftSideToUp,///左边上倾
    DWTransformLeanTypeLeftSideToDown,///左边下倾
    DWTransformLeanTypeRightSideToUp,///右边上倾
    DWTransformLeanTypeRightSideToDown///右边下倾
};

@interface DWTransformUtils : NSObject

+(CGAffineTransform)transformWithOriginSize:(CGSize)size leanOffset:(CGFloat)offset leanType:(DWTransformLeanType)leanType;

+(CATransform3D)transform3DWithOriginSize:(CGSize)size leanOffset:(CGFloat)offset leanType:(DWTransformLeanType)leanType;

@end
