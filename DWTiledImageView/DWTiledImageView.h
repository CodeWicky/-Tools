//
//  DWTiledImageView.h
//  DWTiledImageView
//
//  Created by Wicky on 2019/4/26.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWTiledImageView : UIView

@property (nonatomic ,strong) UIImage * image;

@property (nonatomic ,assign) CGSize tileSize;

@property (nonatomic ,assign) size_t levelsOfDetail;

@end

NS_ASSUME_NONNULL_END
