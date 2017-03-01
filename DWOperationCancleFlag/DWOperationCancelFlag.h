//
//  DWOperationCancelFlag.h
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#define CancelFlag(flag) flag.cancelFlag()

#import <Foundation/Foundation.h>

@interface DWOperationCancelFlag : NSObject

@property (nonatomic ,copy) BOOL (^cancelFlag)();

-(void)start;

-(void)cancel;

@end
