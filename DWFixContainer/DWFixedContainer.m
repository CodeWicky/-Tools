//
//  DWFixedArray.m
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFixedContainer.h"

@interface DWFixedArray ()

@property (nonatomic ,assign) NSUInteger volumn;

@property (nonatomic ,strong) NSMutableArray * array;

@end

@implementation DWFixedArray

+(instancetype)arrayWithVolunm:(NSUInteger)volumn
{
    if (volumn == 0) {
        return nil;
    }
    DWFixedArray * arr = [DWFixedArray new];
    arr.array = [NSMutableArray array];
    arr.volumn = volumn;
    return arr;
}

-(void)dequeueAnObject:(id)obj {
    if (![self.array containsObject:obj]) {
        return;
    }
    if (self.objectDequeueBlock) {
        self.objectDequeueBlock(obj);
    }
    [self.array removeObject:obj];
}

-(void)addObject:(id)anObject {
    while (self.array.count >= self.volumn) {
        [self dequeueAnObject:self.array.firstObject];
    }
    [self.array addObject:anObject];
}

-(void)removeObject:(id)anObject {
    if ([self.array containsObject:anObject]) {
        [self.array removeObject:anObject];
    }
}

-(void)removeAllObjects {
    if (self.array.count) {
        [self.array removeAllObjects];
    }
}

-(BOOL)containsObject:(id)anObject {
    return [self.array containsObject:anObject];
}

-(NSUInteger)count {
    return self.array.count;
}

-(NSString *)description {
    return self.array.description;
}
@end

@interface DWFixedDictionary ()

@property (nonatomic ,strong) NSMutableArray * array;

@property (nonatomic ,strong) NSMutableDictionary * dictionary;

@property (nonatomic ,assign) NSUInteger volumn;

@end

@implementation DWFixedDictionary

+(instancetype)dictionaryWithVolumn:(NSUInteger)volumn
{
    if (volumn == 0) {
        return nil;
    }
    DWFixedDictionary * dic = [[DWFixedDictionary alloc] init];
    dic.dictionary = [NSMutableDictionary dictionary];
    dic.volumn = volumn;
    dic.array = [NSMutableArray array];
    return dic;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([self.array containsObject:key]) {
        if (self.objectDequeueBlock) {
            self.objectDequeueBlock(self.dictionary[key]);
        }
        [self.array removeObject:key];
    } else if (self.array.count == self.volumn) {
        if (self.objectDequeueBlock) {
            self.objectDequeueBlock(self.dictionary[self.array.firstObject]);
        }
        NSString * tempKey = self.array.firstObject;
        [self.array removeObject:tempKey];
        [self.dictionary removeObjectForKey:tempKey];
    }
    [self.array addObject:key];
    [self.dictionary setValue:value forKey:key];
}

-(id)valueForKey:(NSString *)key {
    return [self.dictionary valueForKey:key];
}

-(void)removeObjectForKey:(NSString *)key {
    [self.dictionary removeObjectForKey:key];
}

-(BOOL)containsKey:(NSString *)key {
    return [self.array containsObject:key];
}

-(BOOL)containsObject:(id)obj {
    return [self.dictionary.allValues containsObject:obj];
}

-(NSString *)description {
    return self.dictionary.description;
}

-(NSUInteger)count {
    return self.array.count;
}

-(NSArray *)allKeys {
    return [self.array copy];
}

-(NSArray *)allValues {
    return self.dictionary.allValues;
}
@end
