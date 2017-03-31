//
//  DWSlider.m
//  a
//
//  Created by Wicky on 2017/3/21.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWSlider.h"

@interface DWSlider ()

@property (nonatomic ,strong) CALayer * trackBgLayer;

@property (nonatomic ,strong) CALayer * trackUpLayer;

@property (nonatomic ,strong) CALayer * trackDownLayer;

@property (nonatomic ,strong) CAShapeLayer * trackUpLayerMask;

@property (nonatomic ,strong) CAShapeLayer * trackDownLayerMask;

@property (nonatomic ,strong) CALayer * thumbLayer;

@property (nonatomic ,assign) BOOL clickOnThumb;

@end

@implementation DWSlider
@synthesize trackHeight = _trackHeight;
@synthesize thumbSize = _thumbSize;
@synthesize trackCornerRadius = _trackCornerRadius;
@synthesize thumbCornerRadius = _thumbCornerRadius;

#pragma mark --- interface Method ---
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeDefaultValue];
        [self createComponent];
    }
    return self;
}

-(void)initializeDefaultValue {
    _maximumValue = 1;
    _minimumValue = 0;
    _value = 0;
    _thumbCornerRadius = 0;
    _thumbMargin = self.thumbSize.width / 2;
    _thumbCornerRadius = -1;
    _trackCornerRadius = -1;
}

-(void)createComponent {
    ///create
    [self.layer addSublayer:self.trackBgLayer];
    [self.layer addSublayer:self.trackUpLayer];
    [self.layer addSublayer:self.trackDownLayer];
    [self.layer addSublayer:self.thumbLayer];
    
    ///color
    self.trackUpLayer.backgroundColor = [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1].CGColor;
    self.trackDownLayer.backgroundColor = [UIColor colorWithRed:0.717 green:0.717 blue:0.717 alpha:1].CGColor;
    self.thumbLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    ///update
    [self updateAllLayersAnimated:NO];
}

#pragma mark --- calculate Rect Method ---

///背景滑竿尺寸
-(CGRect)trackRectForBounds:(CGRect)bounds {
    CGPoint origin = CGPointZero;
    CGFloat trackHeight = self.trackHeight;
    CGFloat thumbHeight = self.thumbSize.height;
    CGSize size = CGSizeMake(bounds.size.width, trackHeight);
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
        {
            origin.y = (bounds.size.height - trackHeight) / 2.0;
            break;
        }
        case UIControlContentVerticalAlignmentTop:
        {
            origin.y = (thumbHeight - trackHeight) / 2;
            break;
        }
        case UIControlContentVerticalAlignmentBottom:
        {
            origin.y = bounds.size.height - (thumbHeight - trackHeight) / 2;
            break;
        }
        default:
            size.height = bounds.size.height;
            break;
    }
    CGRect rect = CGRectZero;
    rect.origin = origin;
    rect.size = size;
    return rect;
}

///滑块缩进尺寸
-(CGFloat)thumbMarginForBounds:(CGRect)bounds {
    return FitMarginForThumb(self.thumbSize, self.thumbMargin);
}

///滑块尺寸
-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGFloat margin = FitMarginForThumb(self.thumbSize, [self thumbMarginForBounds:self.bounds]);
    CGFloat width = rect.size.width - margin * 2;
    CGFloat percent = ((self.maximumValue != self.minimumValue) && (value >= self.minimumValue))?(value - self.minimumValue) / (self.maximumValue - self.minimumValue):0;
    CGRect frame = CGRectZero;
    frame.size = self.thumbSize;
    CGPoint origin = CGPointMake(width * percent + rect.origin.x + margin - self.thumbSize.width / 2, rect.origin.y + rect.size.height / 2.0 - self.thumbSize.height / 2.0);
    frame.origin = origin;
    return frame;
}

///滑竿有效值尺寸
-(CGRect)valueTrackForBounds:(CGRect)bounds {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGSize thumbSize = self.thumbSize;
    CGFloat margin = FitMarginForThumb(thumbSize, [self thumbMarginForBounds:self.bounds]);
    CGFloat width = trackRect.size.width - margin * 2;
    CGRect frame = CGRectZero;
    CGPoint origin = CGPointMake(trackRect.origin.x + margin - thumbSize.width / 2, trackRect.origin.y);
    CGSize size = CGSizeMake(width + thumbSize.width, trackRect.size.height);
    frame.origin = origin;
    frame.size = size;
    return frame;
}


#pragma mark --- update Layer ---
-(void)updateTrackBgLayerAnimated:(BOOL)animated {
    TransactionWithAnimation(animated, ^{
        self.trackBgLayer.frame = [self trackRectForBounds:self.bounds];
        self.trackBgLayer.cornerRadius =  FitCornerRadius(self.trackBgLayer, self.trackCornerRadius);
    });
}

-(void)updateTrackValueLayerAnimated:(BOOL)animated {
    TransactionWithAnimation(animated, ^{
        CGRect bounds = [self valueTrackForBounds:self.bounds];
        CGFloat strokeValue = StrokeValueWithFixValue(self.value - self.minimumValue, bounds.size.width, self.thumbSize.width);
        HandleValueTrack(self, self.trackUpLayer, self.trackUpLayerMask, bounds);
        self.trackUpLayerMask.strokeEnd = strokeValue;
        HandleValueTrack(self, self.trackDownLayer, self.trackDownLayerMask, bounds);
        self.trackDownLayerMask.strokeStart = strokeValue;
    });
}

-(void)updateThumbLayerAnimated:(BOOL)animated {
    TransactionWithAnimation(animated, ^{
        self.thumbLayer.frame = [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
        self.thumbLayer.cornerRadius = FitCornerRadius(self.thumbLayer, self.thumbCornerRadius);
    });
}

-(void)updateAllLayersAnimated:(BOOL)animated {
    [self updateTrackBgLayerAnimated:animated];
    [self updateTrackValueLayerAnimated:animated];
    [self updateThumbLayerAnimated:animated];
}

-(void)updateValueAnimated:(BOOL)animated {
    [self updateTrackValueLayerAnimated:animated];
    [self updateThumbLayerAnimated:animated];
}

#pragma mark --- tracking Method ---
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    location = [self.thumbLayer convertPoint:location fromLayer:self.layer];
    if ([PathWithBounds(self.thumbLayer.bounds, FitCornerRadius(self.thumbLayer, self.thumbCornerRadius)) containsPoint:location]) {
        self.clickOnThumb = YES;
        return YES;
    }
    location = [self.trackBgLayer convertPoint:location fromLayer:self.thumbLayer];
    if ([PathWithBounds(self.trackBgLayer.bounds, FitCornerRadius(self.trackBgLayer, self.trackCornerRadius)) containsPoint:location]) {
        self.clickOnThumb = NO;
        return YES;
    }
    return NO;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    CGFloat margin = FitMarginForThumb(self.thumbSize, [self thumbMarginForBounds:self.bounds]);
    location.x -= margin;
    CGFloat actualW = CGRectGetWidth([self trackRectForBounds:self.bounds]) - margin * 2;
    if (location.x < 0) {
        location.x = 0;
    } else if (location.x > actualW) {
        location.x = actualW;
    }
    CGFloat percent = location.x / actualW;
    CGFloat value = self.minimumValue + (self.maximumValue - self.minimumValue) * percent;
    if (value == self.value) {
        return YES;
    }
    _value = value;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (self.clickOnThumb) {
        [self updateValueAnimated:NO];
        return YES;
    } else {
        [self updateValueAnimated:YES];
        self.clickOnThumb = NO;
        return NO;
    }
}

-(void)cancelTrackingWithEvent:(UIEvent *)event {
    self.clickOnThumb = NO;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.clickOnThumb = NO;
}

#pragma mark --- inline Method ---

///设置是否有动画效果
static inline void TransactionWithAnimation(BOOL animated,void(^animation)()) {
    [CATransaction begin];
    if (!animated) {
        [CATransaction setAnimationDuration:0];
    }
    animation();
    [CATransaction commit];
}

///返回加圆角后的路径
static inline UIBezierPath * PathWithBounds(CGRect bounds,CGFloat radius) {
    return [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
}

///返回适配后的圆角尺寸
static inline CGFloat FitCornerRadius(id image,CGFloat radius) {
    if (![image isKindOfClass:[CALayer class]] && ![image isKindOfClass:[UIView class]]) {
        return 0;
    }
    CGRect frame = [[image valueForKey:@"frame"] CGRectValue];
    return MIN(MIN(frame.size.height,frame.size.width) / 2, radius);
}

///返回适配后的指示器尺寸
static inline CGSize FitSizeForThumb(CGRect bounds,CGSize size) {
    size.width = size.width < bounds.size.width ? size.width : bounds.size.width;
    size.height = size.height < bounds.size.height ? size.height : bounds.size.height;
    return size;
}

///返回适配后的指示器缩进
static inline CGFloat FitMarginForThumb(CGSize thumbSize,CGFloat margin) {
    return ((thumbSize.width > margin * 2) ? thumbSize.width / 2 : margin);
}

///返回valueTrack在对应value时的宽度
static inline CGFloat WidthForValueTrack(CGFloat fixValue,CGFloat trackWidth,CGFloat thumbWidth) {
    if (thumbWidth == trackWidth) {
        return 0;
    }
    CGFloat width = trackWidth;
    CGFloat criticalValue = thumbWidth / 2 / trackWidth;
    if (fixValue < criticalValue) {
        width = thumbWidth / criticalValue * fixValue;
    } else if (fixValue > (1 - criticalValue)) {
        width = trackWidth - thumbWidth / criticalValue * (1 - fixValue);
    } else {
        width = (trackWidth - thumbWidth * 2) / (1 - criticalValue * 2) * (fixValue - criticalValue) + thumbWidth;
    }
    return width;
}

///返回对应尺寸中线路径
static inline UIBezierPath * LinePathWithBounds(CGRect bounds) {
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, bounds.size.height / 2)];
    [path addLineToPoint:CGPointMake(bounds.size.width, bounds.size.height / 2)];
    return path;
}

///返回valueTrack对应value的stroke值
static inline CGFloat StrokeValueWithFixValue(CGFloat fixValue,CGFloat trackWidth,CGFloat thumbWidth) {
    return (WidthForValueTrack(fixValue, trackWidth, thumbWidth) / trackWidth);
}

///返回通用的遮罩层
static inline CAShapeLayer * MaskLayerMaker(DWSlider * slider,BOOL up) {
    CAShapeLayer * layer;
    layer = [CAShapeLayer layer];
    layer.strokeColor = [UIColor blackColor].CGColor;
    CGRect valueTrackBounds = [slider valueTrackForBounds:slider.bounds];
    layer.frame = CGRectMake(0, 0, valueTrackBounds.size.width, valueTrackBounds.size.height);
    layer.lineWidth = valueTrackBounds.size.height;
    layer.path = LinePathWithBounds(valueTrackBounds).CGPath;
    if (up) {
        layer.strokeEnd = StrokeValueWithFixValue(slider.value - slider.minimumValue, valueTrackBounds.size.width, slider.thumbSize.width);
    } else {
        layer.strokeStart = StrokeValueWithFixValue(slider.value - slider.minimumValue, valueTrackBounds.size.width, slider.thumbSize.width);
    }
    return layer;
}

///返回通用layer
static inline CALayer * NormalLayer() {
    CALayer * layer = [CALayer layer];
    layer.masksToBounds = YES;
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

///处理valueTrack的值
static inline void HandleValueTrack(DWSlider * slider,CALayer * valueTrack,CAShapeLayer * trackMask,CGRect trackBounds) {
    valueTrack.frame = trackBounds;
    valueTrack.cornerRadius = FitCornerRadius(valueTrack, slider.trackCornerRadius);
    trackMask.frame = CGRectMake(0, 0,trackBounds.size.width, trackBounds.size.height);
    trackMask.lineWidth = valueTrack.bounds.size.height;
    trackMask.path = LinePathWithBounds(trackMask.bounds).CGPath;
    valueTrack.mask = trackMask;
}

#pragma mark --- setter/getter ---
-(CALayer *)trackBgLayer {
    if (!_trackBgLayer) {
        _trackBgLayer = NormalLayer();
    }
    return _trackBgLayer;
}

-(CALayer *)trackUpLayer {
    if (!_trackUpLayer) {
        _trackUpLayer = NormalLayer();
    }
    return _trackUpLayer;
}

-(CALayer *)trackDownLayer {
    if (!_trackDownLayer) {
        _trackDownLayer = NormalLayer();
    }
    return _trackDownLayer;
}

-(CALayer *)thumbLayer {
    if (!_thumbLayer) {
        _thumbLayer = NormalLayer();
        _thumbLayer.borderWidth = 0.5;
        _thumbLayer.borderColor = [UIColor colorWithRed:0.827 green:0.827 blue:0.827 alpha:1].CGColor;
    }
    return _thumbLayer;
}

-(CAShapeLayer *)trackUpLayerMask {
    if (!_trackUpLayerMask) {
        _trackUpLayerMask = MaskLayerMaker(self,YES);
    }
    return _trackUpLayerMask;
}

-(CAShapeLayer *)trackDownLayerMask {
    if (!_trackDownLayerMask) {
        _trackDownLayerMask = MaskLayerMaker(self, NO);
    }
    return _trackDownLayerMask;
}

-(CGFloat)trackHeight {
    if (_trackHeight <= 0) {
        return 2;
    } else if (_trackHeight > self.bounds.size.height) {
        return self.bounds.size.height;
    }
    return _trackHeight;
}

-(void)setTrackHeight:(CGFloat)trackHeight {
    if (_trackHeight != trackHeight) {
        _trackHeight = trackHeight;
        [self updateTrackBgLayerAnimated:YES];
        [self updateTrackValueLayerAnimated:YES];
    }
}

-(CGFloat)trackCornerRadius {
    if (_trackCornerRadius == -1) {
        return self.trackHeight / 2;
    }
    return _trackCornerRadius;
}

-(void)setTrackCornerRadius:(CGFloat)trackCornerRadius {
    if (_trackCornerRadius != trackCornerRadius) {
        _trackCornerRadius = trackCornerRadius;
        [self updateTrackBgLayerAnimated:YES];
        [self updateTrackValueLayerAnimated:YES];
    }
}

-(CGSize)thumbSize {
    if (CGSizeEqualToSize(_thumbSize, CGSizeZero)) {
        return FitSizeForThumb(self.bounds, CGSizeMake(31, 31));
    }
    return FitSizeForThumb(self.bounds, _thumbSize);
}

-(void)setThumbSize:(CGSize)thumbSize {
    if (!CGSizeEqualToSize(_thumbSize, thumbSize)) {
        _thumbSize = thumbSize;
        [self updateAllLayersAnimated:YES];
    }
}

-(CGFloat)thumbCornerRadius {
    if (_thumbCornerRadius == -1) {
        return MIN(self.thumbSize.width, self.thumbSize.height) / 2;
    }
    return _thumbCornerRadius;
}

-(void)setThumbCornerRadius:(CGFloat)thumbCornerRadius {
    if (_thumbCornerRadius != thumbCornerRadius) {
        _thumbCornerRadius = thumbCornerRadius;
        [self updateThumbLayerAnimated:YES];
    }
}

-(void)setThumbMargin:(CGFloat)thumbMargin {
    if (_thumbMargin != thumbMargin) {
        _thumbMargin = thumbMargin;
        [self updateValueAnimated:YES];
    }
}

-(void)setThumbImage:(UIImage *)thumbImage {
    if (_thumbImage != thumbImage) {
        _thumbImage = thumbImage;
        self.thumbLayer.contents = (id)thumbImage.CGImage;
        self.thumbLayer.borderWidth = thumbImage ? 0 : 0.5;
    }
}

-(void)setMaxTrackImage:(UIImage *)maxTrackImage {
    if (_maxTrackImage != maxTrackImage) {
        _maxTrackImage = maxTrackImage;
        self.trackDownLayer.contents = (id)maxTrackImage.CGImage;
    }
}

-(void)setMinTrackImage:(UIImage *)minTrackImage {
    if (_minTrackImage != minTrackImage) {
        _minTrackImage = minTrackImage;
        self.trackUpLayer.contents = (id)minTrackImage.CGImage;
    }
}

-(void)setTrackBgImage:(UIImage *)trackBgImage {
    if (_trackBgImage != trackBgImage) {
        _trackBgImage = trackBgImage;
        self.trackBgLayer.contents = (id)trackBgImage.CGImage;
        if (trackBgImage) {
            self.trackUpLayer.hidden = YES;
            self.trackDownLayer.hidden = YES;
        }
    }
}

-(void)setMinTrackColor:(UIColor *)minTrackColor {
    if (_minTrackColor != minTrackColor) {
        _minTrackColor = minTrackColor;
        self.trackUpLayer.backgroundColor = minTrackColor.CGColor;
        if (!self.trackBgImage) {
            self.trackUpLayer.hidden = NO;
        }
    }
}

-(void)setMaxTrackColor:(UIColor *)maxTrackColor {
    if (_maxTrackColor != maxTrackColor) {
        _maxTrackColor = maxTrackColor;
        self.trackDownLayer.backgroundColor = maxTrackColor.CGColor;
        if (!self.trackBgImage) {
            self.trackUpLayer.hidden = NO;
        }
    }
}

-(void)setValue:(CGFloat)value {
    [self setValue:value updateThumb:YES];
}

-(void)setValue:(CGFloat)value updateThumb:(BOOL)update {
    CGFloat fixValue = (value < self.minimumValue) ? self.minimumValue : ((value > self.maximumValue) ? self.maximumValue : value);
    if (_value != fixValue) {
        _value = fixValue;
        if (update) {
            [self updateValueAnimated:YES];
        }
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateAllLayersAnimated:YES];
}

-(void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    [super setContentVerticalAlignment:contentVerticalAlignment];
    [self updateAllLayersAnimated:YES];
}

@end
