//
//  DWGradientView.m
//  AccountBook
//
//  Created by Wicky on 2018/10/16.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWGradientView.h"

@interface DWGradientView ()

@property (nonatomic ,strong ,readonly) CAGradientLayer * layer;

@end

@implementation DWGradientView
@dynamic layer;

+(Class)layerClass {
    return [CAGradientLayer class];
}

-(void)setColors:(NSArray*)colors {
    self.layer.colors = colors;
}

-(NSArray *)colors {
    return self.layer.colors;
}

-(void)setLocations:(NSArray<NSNumber *> *)locations {
    self.layer.locations = locations;
}

-(NSArray<NSNumber *> *)locations {
    return self.layer.locations;
}

-(void)setStartPoint:(CGPoint)startPoint {
    self.layer.startPoint = startPoint;
}

-(CGPoint)startPoint {
    return self.layer.startPoint;
}

-(void)setEndPoint:(CGPoint)endPoint {
    self.layer.endPoint = endPoint;
}

-(CGPoint)endPoint {
    return self.layer.endPoint;
}


@end
