//
//  DWTransformUtils.m
//  layer
//
//  Created by Wicky on 16/12/25.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWTransformUtils.h"

@implementation DWTransformUtils

+(CGAffineTransform)dw_TransformWithOriginSize:(CGSize)size leanOffset:(CGFloat)offset leanType:(DWTransformLeanType)leanType
{
    CGAffineTransform trans = CGAffineTransformIdentity;
    switch (leanType) {
        case DWTransformLeanTypeTopSideToLeft:
        {
            trans.c = offset / size.height;
            trans.tx = - trans.c * 0.5 * size.width;
        }
            break;
        case DWTransformLeanTypeTopSideToRight:
        {
            trans.c = - offset / size.height;
            trans.tx = - trans.c * 0.5 * size.width;
        }
            break;
        case DWTransformLeanTypeBottomSideToLeft:
        {
            trans.c = - offset / size.height;
            trans.tx = trans.c * 0.5 * size.width;
        }
            break;
        case DWTransformLeanTypeBottomSideToRight:
        {
            trans.c = offset / size.height;
            trans.tx = trans.c * 0.5 * size.width;
        }
            break;
        case DWTransformLeanTypeLeftSideToUp:
        {
            
            trans.b = offset / size.width;
            trans.ty = - trans.b * 0.5 * size.height;
        }
            break;
        case DWTransformLeanTypeLeftSideToDown:
        {
            trans.b = - offset / size.width;
            trans.ty = - trans.b * 0.5 * size.height;
        }
            break;
        case DWTransformLeanTypeRightSideToUp:
        {
            trans.b = - offset / size.width;
            trans.ty = trans.b * 0.5 * size.height;
        }
            break;
        case DWTransformLeanTypeRightSideToDown:
        {
            trans.b = offset / size.width;
            trans.ty = trans.b * 0.5 * size.height;
        }
            break;
        default:
            break;
    }
    return trans;
}

+(CATransform3D)dw_Transform3DWithOriginSize:(CGSize)size leanOffset:(CGFloat)offset leanType:(DWTransformLeanType)leanType
{
    return CATransform3DMakeAffineTransform([self dw_TransformWithOriginSize:size leanOffset:offset leanType:leanType]);
}

+(CGFloat)dw_GetScaleXByTransform:(CGAffineTransform)trans
{
    return sqrt(trans.a * trans.a + trans.c * trans.c);
}

+(CGFloat)dw_GetScaleYByTransform:(CGAffineTransform)trans
{
    return sqrt(trans.b * trans.b + trans.d * trans.d);
}

+(CGFloat)dw_GetTranslateXByTransform:(CGAffineTransform)trans
{
    return trans.tx;
}

+(CGFloat)dw_GetTranslateYByTransform:(CGAffineTransform)trans
{
    return trans.ty;
}

+(CGFloat)dw_GetRotateByTransform:(CGAffineTransform)trans
{
    return atan2(trans.b, trans.a);
}
@end
