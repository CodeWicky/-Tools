//
//  DWImageViewer.m
//  GomeLoanClient
//
//  Created by Wicky on 2018/1/21.
//  Copyright © 2018年 GMJK. All rights reserved.
//

#import "DWImageViewer.h"
#import "AppDelegate.h"

@interface DWImageViewerController : UIViewController<UIScrollViewDelegate>

@property (nonatomic ,strong) UIImageView * image;

@property (nonatomic ,assign) CGRect oriRect;

@property (nonatomic ,strong) UIButton * uploadBtn;

@property (nonatomic ,strong) UIButton * cancelBtn;

@property (nonatomic ,strong) UIWindow * window;

@property (nonatomic ,copy) dispatch_block_t handler;

@property (nonatomic ,assign) BOOL hasUploadAction;

@property (nonatomic ,strong) UIScrollView * scrView;

@end

@implementation DWImageViewerController

#pragma mark --- interface method ---

-(instancetype)initWithImageView:(UIImageView *)img uploadHandler:(dispatch_block_t)handler {
    if (self = [super init]) {
        if (handler) {
            self.handler = handler;
            self.hasUploadAction = YES;
        } else {
            self.hasUploadAction = NO;
        }
        [self setupUIWithImageView:img];
    }
    return self;
}

-(void)setupUIWithImageView:(UIImageView *)img {
    self.scrView = [[UIScrollView alloc] initWithFrame:ApplicationDelegate.window.bounds];
    [self.view addSubview:self.scrView];
    self.scrView.contentSize = self.scrView.bounds.size;
    self.scrView.delegate = self;
    self.scrView.maximumZoomScale = 2;
    self.scrView.minimumZoomScale = 0.5;
    
    CGRect frame = [img.superview convertRect:img.frame toView:ApplicationDelegate.window];
    self.oriRect = frame;
    self.image = [[UIImageView alloc] initWithFrame:frame];
    self.image.contentMode = img.contentMode;
    self.image.image = img.image;
    [self.scrView addSubview:self.image];
    
    if (self.hasUploadAction) {
        self.cancelBtn = normalBtn(@"取消",self,@selector(dismissViewer));
        self.uploadBtn = normalBtn(@"重新上传", self, @selector(uploadAction));
        
        CGFloat margin = 20;
        CGFloat bottomM = -15;
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(margin);
            make.bottom.mas_equalTo(bottomM);
        }];
        
        [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-margin);
            make.bottom.mas_equalTo(bottomM);
        }];
    }
}

-(void)addGesToImageView {
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewer)];
    self.image.userInteractionEnabled = YES;
    [self.scrView addGestureRecognizer:tap];
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.35 animations:^{
        self.image.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        if (!self.hasUploadAction) {
            [self addGesToImageView];
        }
    }];
}

-(void)dismissViewer {
    
    CGRect frame = CGRectOffset(self.oriRect, self.scrView.contentOffset.x, self.scrView.contentOffset.y);
    
    [UIView animateWithDuration:0.35 animations:^{
        self.image.frame = frame;
        self.window.alpha = 0;
    } completion:^(BOOL finished) {
        self.window = nil;
        self.handler = nil;
    }];
}

-(void)uploadAction {
    if (self.handler) {
        self.handler();
    }
    [self dismissViewer];
}

#pragma mark --- delegate ---
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self calculateDisplayImageViewFrame];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.image;
}

#pragma mark --- tool method ---
/** 计算显示图片的frame */
- (void)calculateDisplayImageViewFrame {
    //最大尺寸
    CGRect maxRect = self.scrView.frame;
    //获取图片的frame
    CGRect originFrame = self.image.frame;
    CGFloat displayViewX = 0;
    CGFloat displayViewY = 0;
    //scrollView的滚动范围
    CGFloat scrollViewContextW = 0;
    CGFloat scrollViewContextH = 0;
    if (originFrame.size.width < maxRect.size.width ) {
        displayViewX = (maxRect.size.width - originFrame.size.width)/2.0;
    }else {
        scrollViewContextW = originFrame.size.width;
    }
    if (originFrame.size.height < maxRect.size.height ) {
        displayViewY = (maxRect.size.height - originFrame.size.height)/2.0;
    }else {
        scrollViewContextH = originFrame.size.height;
    }
    self.image.frame = CGRectMake(displayViewX, displayViewY, originFrame.size.width, originFrame.size.height);
    self.scrView.contentSize = CGSizeMake(scrollViewContextW, scrollViewContextH);
}

#pragma mark --- tool func ---
static inline UIButton * normalBtn(NSString * title,UIViewController * vc,SEL selector) {
    UIButton * btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btn setTitle:title forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [vc.view addSubview:btn];
    [btn addTarget:vc action:selector forControlEvents:(UIControlEventTouchUpInside)];
    return btn;
}

-(void)dealloc {
    NSLog(@"dealloc");
}

@end



@implementation DWImageViewer

+(void)viewImageView:(UIImageView *)view {
    [self viewImageView:view uploadHandler:nil];
}



+(void)viewImageView:(UIImageView *)view uploadHandler:(dispatch_block_t)handler {
    DWImageViewer * v = [[DWImageViewer alloc] initWithFrame:[UIScreen mainScreen].bounds];
    v.windowLevel = UIWindowLevelAlert;
    v.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    v.hidden = NO;
    v.alpha = 1;
    DWImageViewerController * vc = [[DWImageViewerController alloc] initWithImageView:view uploadHandler:handler];
    v.rootViewController = vc;
    vc.window = v;
}

-(void)dealloc {
    NSLog(@"window dealloc");
}

@end
