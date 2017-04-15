//
//  UIImage+DWImageUtils.m
//  Image
//
//  Created by Wicky on 2016/12/6.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIImage+DWImageUtils.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (DWImageInstanceUtils)

+(UIImage *)dw_ImageNamed:(NSString *)name
{
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    }
    if (!path) {
        return nil;
    }
    NSURL * url = [NSURL fileURLWithPath:path];
    return [self dw_ImageWithUrl:url];
}

+(UIImage *)dw_ImageWithUrl:(NSURL *)url
{
    NSDictionary*options = @{(__bridge id)kCGImageSourceShouldCache: @YES};
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url,NULL);CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source,0,(__bridge CFDictionaryRef)options);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(source);
    return image;
}

@end

@implementation UIImage (DWImageBase64Utils)

-(NSString *)dw_ImageToBase64String
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha]) {
        imageData = UIImagePNGRepresentation(self);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(self, 1.0f);
        mimeType = @"image/jpeg";
    }
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
}

+ (UIImage *)dw_ImageWithBase64String:(NSString *)base64String
{
    NSURL *url = [NSURL URLWithString: base64String];
    NSData *data = [NSData dataWithContentsOfURL: url];
    UIImage *image = [UIImage imageWithData: data];
    
    return image;
}

-(BOOL)imageHasAlpha
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

@end

@implementation UIImage (DWImageColorUtils)

-(UIColor *)dw_ColorAtPoint:(CGPoint)point;
{
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point))
    {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    
    ///创建1*1画布
    CGContextRef context = CGBitmapContextCreate(pixelData,1,1,bitsPerComponent,bytesPerRow,colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    ///绘图
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    ///取色
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+(UIImage *)dw_ImageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)dw_ConvertToGrayImage
{
    size_t width = self.size.width;
    size_t height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
    {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef contextRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:contextRef];
    CGContextRelease(context);
    CGImageRelease(contextRef);
    
    return grayImage;
}

-(UIImage *)dw_ConvertToReversedColor {
    return [self dw_ConvertImageWithPixelHandler:^(UInt8 *pixel, int x, int y) {
        UInt8 alpha = * (pixel + 3);
        if (alpha) {
            *pixel = 255 - *pixel;
            *(pixel + 1) = 255 - *(pixel + 1);
            *(pixel + 2) = 255 - *(pixel + 2);
        }
    }];
}

-(UIImage *)dw_ConvertToSketchWithColor:(UIColor *)color {
    NSInteger numComponents = CGColorGetNumberOfComponents(color.CGColor);
    NSInteger red , green , blue;
    red = green = blue = 0;
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        red = components[0] * 255;
        green = components[1] * 255;
        blue = components[2] * 255;
    }
    return [self dw_ConvertImageWithPixelHandler:^(UInt8 *pixel, int x, int y) {
        UInt8 alpha = * (pixel + 3);
        if (alpha) {
            *pixel = red;
            *(pixel + 1) = green;
            *(pixel + 2) = blue;
        }
    }];
}

-(UIImage *)dw_ConvertImageWithPixelHandler:(void (^)(UInt8 *, int, int))handler {
    if (!handler) {
        return self;
    }
    size_t width = self.size.width;
    size_t height = self.size.height;
    size_t bitsPerComponent = CGImageGetBitsPerComponent(self.CGImage);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(self.CGImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(self.CGImage);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(self.CGImage);
    bool shouldInterpolate = CGImageGetShouldInterpolate(self.CGImage);
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(self.CGImage);
    CGDataProviderRef provider = CGImageGetDataProvider(self.CGImage);
    CFDataRef data = CGDataProviderCopyData(provider);
    UInt8 * buffer = (UInt8 *)CFDataGetBytePtr(data);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            UInt8 * pixel = buffer + y * bytesPerRow + x * 4;
            handler(pixel,x,y);
        }
    }
    CFDataRef reverseData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    CGDataProviderRef reverseProvider = CGDataProviderCreateWithCFData(reverseData);
    CGImageRef reverseCGImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, reverseProvider, NULL, shouldInterpolate, intent);
    UIImage * reverseImage = [UIImage imageWithCGImage:reverseCGImage];
    CGImageRelease(reverseCGImage);
    CGDataProviderRelease(reverseProvider);
    CFRelease(reverseData);
    CFRelease(data);
    return reverseImage;
}

@end

@implementation UIImage (DWImageClipUtils)

-(UIImage *)dw_CornerRadius:(CGFloat)radius withWidth:(CGFloat)width contentMode:(DWContentMode)mode
{
    CGFloat originScale = self.size.width / self.size.height;
    CGFloat height = width / originScale;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat maxV = MAX(width, height);
    if (radius < 0) {
        radius = 0;
    }
    UIImage * image = nil;
    CGRect imageFrame;
    if (mode == DWContentModeScaleAspectFit) {//根据图片填充模式制定绘制frame
        if (originScale > 1) {//适应模式
            imageFrame = CGRectMake(0, (width - height) / 2, width,height);
        }
        else
        {
            imageFrame = CGRectMake((height - width) / 2, 0, width, height);
        }
    }
    else if (mode == DWContentModeScaleAspectFill)//填充模式
    {
        CGFloat newHeight;
        CGFloat newWidth;
        if (originScale > 1) {
            newHeight = width;
            newWidth = newHeight * originScale;
            imageFrame = CGRectMake( -(newWidth - newHeight) / 2, 0, newWidth, newHeight);
        }
        else
        {
            newWidth = height;
            newHeight = newWidth / originScale;
            imageFrame = CGRectMake(0, - (newHeight - newWidth) / 2, newWidth, newHeight);
        }
    }
    else//拉伸模式
    {
        imageFrame = CGRectMake(0, 0, maxV, maxV);
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(maxV, maxV), NO, scale);//以最大长度开启图片上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, maxV, maxV) cornerRadius:radius] addClip];//绘制一个圆形的贝塞尔曲线，并做遮罩
    [self drawInRect:imageFrame];//在指定的frame中绘制图片
    CGContextRotateCTM(context, M_PI_2);
    image = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获取图片
    UIGraphicsEndImageContext();//关闭上下文
    return image;
}

-(UIImage *)dw_ClipImageWithPath:(UIBezierPath *)path mode:(DWContentMode)mode
{
    CGFloat originScale = self.size.width * 1.0 / self.size.height;
    CGRect boxBounds = path.bounds;
    CGFloat width = boxBounds.size.width;
    CGFloat height = width / originScale;
    switch (mode) {
        case DWContentModeScaleAspectFit:
        {
            if (height > boxBounds.size.height) {
                height = boxBounds.size.height;
                width = height * originScale;
            }
        }
            break;
        case DWContentModeScaleAspectFill:
        {
            if (height < boxBounds.size.height) {
                height = boxBounds.size.height;
                width = height * originScale;
            }
        }
            break;
        default:
            if (height != boxBounds.size.height) {
                height = boxBounds.size.height;
            }
            break;
    }
    
    ///开启上下文
    UIGraphicsBeginImageContextWithOptions(boxBounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    ///归零path
    UIBezierPath * newPath = [path copy];
    [newPath applyTransform:CGAffineTransformMakeTranslation(-path.bounds.origin.x, -path.bounds.origin.y)];
    [newPath addClip];
    
    ///移动原点至图片中心
    CGContextTranslateCTM(bitmap, boxBounds.size.width / 2.0, boxBounds.size.height / 2.0);
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-width / 2, -height / 2, width, height), self.CGImage);
    
    ///生成图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIImage (DWImageTransformUtils)

-(UIImage *)dw_RotateImageWithAngle:(CGFloat)angle
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    ///开启上下文
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [UIScreen mainScreen].scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    ///移动原点至图片中心
    CGContextTranslateCTM(bitmap, rotatedSize.width/2.0, rotatedSize.height/2.0);
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextRotateCTM(bitmap, -angle);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    ///生成图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

///按给定的方向旋转图片
-(UIImage*)dw_RotateWithOrient:(UIImageOrientation)orient
{
    CGRect bnds = CGRectZero;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size = self.size;
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return self;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            return self;
    }
    
    UIGraphicsBeginImageContextWithOptions(bnds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, self.CGImage);
    
    UIImage* copy  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}

/** 垂直翻转 */
- (UIImage *)dw_FlipVertical
{
    return [self dw_RotateWithOrient:UIImageOrientationDownMirrored];
}

/** 水平翻转 */
- (UIImage *)dw_FlipHorizontal
{
    return [self dw_RotateWithOrient:UIImageOrientationUpMirrored];
}

#pragma mark - 压缩图片至指定尺寸
- (UIImage *)dw_RescaleImageToSize:(CGSize)size
{
    CGRect rect = (CGRect){CGPointZero, size};
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [self drawInRect:rect];
    
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resImage;
}

#pragma mark - 压缩图片至指定像素
- (UIImage *)dw_RescaleImageToPX:(CGFloat )toPX
{
    CGSize size = self.size;
    
    if(size.width <= toPX && size.height <= toPX)
    {
        return self;
    }
    
    CGFloat scale = size.width / size.height;
    
    if(size.width > size.height)
    {
        size.width = toPX;
        size.height = size.width / scale;
    }
    else
    {
        size.height = toPX;
        size.width = size.height * scale;
    }
    
    return [self dw_RescaleImageToSize:size];
}



-(UIImage *)dw_FixOrientation
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

///交换宽和高
static inline CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat swap = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    return rect;
}
@end

@implementation UIImage (DWImageCanvasUtils)

#pragma mark - 截取当前image对象rect区域内的图像
- (UIImage *)dw_SubImageWithRect:(CGRect)rect {
    ///防止处理过image的scale不为1情况rect错误
    CGFloat scale = self.scale;
    CGRect scaleRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(self.CGImage, scaleRect);
    UIImage *newImage = [[UIImage imageWithCGImage:newImageRef] dw_RescaleImageToSize:rect.size];
    CGImageRelease(newImageRef);
    return newImage;
}

#pragma mark - 指定大小生成一个平铺的图片
- (UIImage *)dw_GetTiledImageWithSize:(CGSize)size
{
    UIView *tempView = [[UIView alloc] init];
    tempView.bounds = (CGRect){CGPointZero, size};
    tempView.backgroundColor = [UIColor colorWithPatternImage:self];
    return [UIImage dw_ImageFromView:tempView];
}

#pragma mark - UIView转化为UIImage
+(UIImage *)dw_ImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 将两个图片生成一张图片
+(UIImage*)dw_MergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage
{
    CGImageRef firstImageRef = firstImage.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    CGImageRef secondImageRef = secondImage.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    UIGraphicsBeginImageContextWithOptions(mergedSize, NO, [UIScreen mainScreen].scale);
    [firstImage drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [secondImage drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
