//
//  DWTiledImageView.m
//  DWTiledImageView
//
//  Created by Wicky on 2019/4/26.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWTiledImageView.h"

#define CGFloatEqualTo(a,b) (fabs(a - b) <= FLT_EPSILON)

@interface DWTiledImageInternalView : UIView

@property (nonatomic ,strong) UIImage * image;

@property (nonatomic ,assign) CGFloat imageHorScale;

@property (nonatomic ,assign) CGFloat imageVerScale;

@property (nonatomic ,assign) size_t levelsOfDetail;

@property (nonatomic ,assign) size_t levelsOfDetailBias;

@property (nonatomic ,assign) CGSize tileSize;

@end

@implementation DWTiledImageInternalView

#pragma mark --- override ---
+(Class)layerClass {
    return [CATiledLayer class];
}

-(void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:1];
}

-(void)drawRect:(CGRect)rect {
    CGRect imageCutRect = CGRectMake(rect.origin.x / self.imageHorScale,rect.origin.y / self.imageVerScale,rect.size.width / self.imageHorScale,rect.size.height / self.imageVerScale);
    
    @autoreleasepool{
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage, imageCutRect);
        UIImage *tileImage = [UIImage imageWithCGImage:imageRef];
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(context);
        [tileImage drawInRect:rect];
        UIGraphicsPopContext();
    }
}

#pragma mark --- setter/getter ---
-(void)setLevelsOfDetailBias:(size_t)levelsOfDetailBias {
    if (_levelsOfDetailBias != levelsOfDetailBias) {
        _levelsOfDetailBias = levelsOfDetailBias;
        ((CATiledLayer *)self.layer).levelsOfDetailBias = levelsOfDetailBias;
    }
}

-(void)setTileSize:(CGSize)tileSize {
    if (!CGSizeEqualToSize(_tileSize, tileSize)) {
        _tileSize = tileSize;
        ((CATiledLayer *)self.layer).tileSize = tileSize;
    }
}

@end

@interface DWTiledImageView ()

@property (nonatomic ,strong) DWTiledImageInternalView * tiledView;

@property (nonatomic ,assign) CGFloat mediaScale;

@property (nonatomic ,assign) CGFloat viewScale;

@property (nonatomic ,assign) CGFloat viewWidth;

@property (nonatomic ,assign) CGFloat viewHeight;

@end

@implementation DWTiledImageView

#pragma mark --- tool method ---
-(void)calculateImageScale {
    if (_viewScale * _mediaScale != 0) {
        
        switch (self.contentMode) {
            case UIViewContentModeScaleToFill:
            {
                if (CGFloatEqualTo(_viewScale, _mediaScale)) {
                    _tiledView.imageHorScale = _tiledView.imageVerScale = _tiledView.bounds.size.width / self.image.size.width;
                } else {
                    _tiledView.imageHorScale = _tiledView.bounds.size.width / self.image.size.width;
                    _tiledView.imageVerScale = _tiledView.bounds.size.height / self.image.size.height;
                }
            }
                break;
            default:
            {
                _tiledView.imageHorScale = _tiledView.imageVerScale = _tiledView.bounds.size.width / self.image.size.width;
            }
                break;
        }
        CGFloat imageScale = MAX(_tiledView.imageHorScale, _tiledView.imageVerScale);
        int lev = ceil(log2( 1 / imageScale ))+1;
        self.tiledView.levelsOfDetailBias = lev;
    } else {
        _tiledView.imageHorScale = _tiledView.imageVerScale = _tiledView.bounds.size.width / self.image.size.width;
    }
}

-(void)resizeTiledLayer {
    if (_viewScale * _mediaScale == 0) {
        return;
    }
    switch (self.contentMode) {
        case UIViewContentModeScaleToFill:
        {
            self.tiledView.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
        }
            break;
        case UIViewContentModeScaleAspectFit:
        {
            if (CGFloatEqualTo(_mediaScale, _viewScale)) {
                self.tiledView.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
            } else if (_mediaScale / _viewScale > 1) {
                CGFloat tileHeight = _viewHeight * _viewScale / _mediaScale;
                self.tiledView.frame = CGRectMake(0, (_viewHeight - tileHeight) / 2, _viewWidth, tileHeight);
            } else {
                CGFloat tileWidth = _viewWidth * _mediaScale / _viewScale;
                self.tiledView.frame = CGRectMake((_viewWidth - tileWidth) / 2, 0, tileWidth, _viewHeight);
            }
        }
            break;
        case UIViewContentModeScaleAspectFill:
        {
            if (CGFloatEqualTo(_mediaScale, _viewScale)) {
                self.tiledView.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
            } else if (_mediaScale / _viewScale > 1) {
                CGFloat tileWidth = _viewWidth * _mediaScale / _viewScale;
                self.tiledView.frame = CGRectMake((_viewWidth - tileWidth) / 2, 0, tileWidth, _viewHeight);
            } else {
                CGFloat tileHeight = _viewHeight * _viewScale / _mediaScale;
                self.tiledView.frame = CGRectMake(0, (_viewHeight - tileHeight) / 2, _viewWidth, tileHeight);
            }
        }
            break;
        case UIViewContentModeTop:
        {
            self.tiledView.frame = CGRectMake((_viewWidth - self.image.size.width) / 2, 0, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeBottom:
        {
            self.tiledView.frame = CGRectMake((_viewWidth - self.image.size.width) / 2, _viewHeight - self.image.size.height, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeLeft:
        {
            self.tiledView.frame = CGRectMake(0, (_viewHeight - self.image.size.height) / 2, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeRight:
        {
            self.tiledView.frame = CGRectMake(_viewWidth - self.image.size.width, (_viewHeight - self.image.size.height) / 2, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeTopLeft:
        {
            self.tiledView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeTopRight:
        {
            self.tiledView.frame = CGRectMake(_viewWidth - self.image.size.width, 0, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeBottomLeft:
        {
            self.tiledView.frame = CGRectMake(0, _viewHeight - self.image.size.height, self.image.size.width, self.image.size.height);
        }
            break;
        case UIViewContentModeBottomRight:
        {
            self.tiledView.frame = CGRectMake(_viewWidth - self.image.size.width, _viewHeight - self.image.size.height, self.image.size.width, self.image.size.height);
        }
            break;
        default:
        {
            self.tiledView.frame = CGRectMake((_viewWidth - self.image.size.width) / 2, (_viewHeight - self.image.size.height) / 2, self.image.size.width, self.image.size.height);
        }
            break;
    }
}

#pragma mark --- override ---
-(void)drawRect:(CGRect)rect {
    if (self.mediaScale * self.viewScale == 0) {
        return;
    }
    [super drawRect:rect];
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _tiledView = [[DWTiledImageInternalView alloc] initWithFrame:frame];
        [self addSubview:_tiledView];
        self.levelsOfDetail = 4;
        self.tileSize = CGSizeMake(100, 100);
    }
    return self;
}

-(void)setContentMode:(UIViewContentMode)contentMode {
    if (self.contentMode != contentMode) {
        [super setContentMode:contentMode];
        _tiledView.contentMode = contentMode;
        [self resizeTiledLayer];
        [self calculateImageScale];
    }
}

-(void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        _viewWidth = frame.size.width;
        _viewHeight = frame.size.height;
        if (_viewHeight != 0) {
            _viewScale = fabs(_viewWidth / _viewHeight);
        } else {
            _viewScale = 0;
        }
        [self resizeTiledLayer];
        [self calculateImageScale];
    }
}

#pragma mark --- setter/getter ---

-(void)setTileSize:(CGSize)tileSize {
    if (!CGSizeEqualToSize(_tileSize, tileSize)) {
        _tileSize = tileSize;
        int widthFactor = ceil(self.bounds.size.width / tileSize.width);
        int heightFactor = ceil(self.bounds.size.height / tileSize.height);
        self.tiledView.tileSize = CGSizeMake(_viewWidth / widthFactor, _viewHeight / heightFactor);
    }
}

-(void)setLevelsOfDetail:(size_t)levelsOfDetail {
    if (_levelsOfDetail != levelsOfDetail) {
        _levelsOfDetail = levelsOfDetail;
        self.tiledView.levelsOfDetail = levelsOfDetail;
    }
}

-(void)setImage:(UIImage *)image {
    if (![_image isEqual:image]) {
        _image = image;
        _tiledView.image = image;
        if (image.size.height * image.size.width > 0) {
            _mediaScale = fabs(image.size.width / image.size.height);
        } else {
            _mediaScale = 0;
        }
        [self resizeTiledLayer];
        [self calculateImageScale];
    }
}

@end

