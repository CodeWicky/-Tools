//
//  DWFixedContainer.h
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWFixedContainer
 总量固定的数组/字典，遵循FIFO
 */

#import <Foundation/Foundation.h>

@interface DWFixedArray : NSObject

@property (nonatomic ,copy) void (^objectDequeueBlock)(id obj);

@property (nonatomic ,assign ,readonly) NSUInteger count;

+(instancetype)arrayWithVolunm:(NSUInteger)volumn;

-(void)addObject:(id)anObject;

-(void)removeObject:(id)anObject;

-(void)removeAllObjects;

-(BOOL)containsObject:(id)anObject;

@end

@interface DWFixedDictionary : NSObject

@property (nonatomic ,copy) void (^objectDequeueBlock)(id obj);

@property (nonatomic ,assign) NSUInteger count;

@property (nonatomic ,strong ,readonly) NSArray * allKeys;

@property (nonatomic ,strong ,readonly) NSArray * allValues;

+(instancetype)dictionaryWithVolumn:(NSUInteger)volumn;

-(void)setValue:(id)value forKey:(NSString *)key;

-(id)valueForKey:(NSString *)key;

-(void)removeObjectForKey:(NSString *)key;

-(BOOL)containsObject:(id)obj;

-(BOOL)containsKey:(NSString *)key;

@end
