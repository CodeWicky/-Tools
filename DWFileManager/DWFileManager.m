//
//  DWFileManager.m
//  video
//
//  Created by Wicky on 2017/4/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFileManager.h"

#define DefaultFileManager [NSFileManager defaultManager]

@implementation DWFileManager

+(NSString *)dw_HomeDir {
    return NSHomeDirectory();
}

+(NSString *)dw_DocumentsDir {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+(NSString *)dw_LibraryDir {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

+(NSString *)dw_PreferencesDir {
    return [[self dw_LibraryDir] stringByAppendingPathComponent:@"Preferences"];
}

+(NSString *)dw_CachesDir {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+(NSString *)dw_TmpDir {
    return NSTemporaryDirectory();
}

+(NSDictionary *)dw_AttributesOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [DefaultFileManager attributesOfItemAtPath:path error:error];
}

+(NSDictionary *)dw_AttributesOfItemAtPath:(NSString *)path {
    return [self dw_AttributesOfItemAtPath:path error:nil];
}

+(id)dw_AttributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [[self dw_AttributesOfItemAtPath:path error:error] objectForKey:key];
}

+(id)dw_AttributeOfItemAtPath:(NSString *)path forKey:(NSString *)key {
    return [self dw_AttributeOfItemAtPath:path forKey:key error:nil];
}

+(BOOL)dw_IsDirectoryAtPath:(NSString *)path {
    BOOL isDir = NO;
    BOOL exist = [DefaultFileManager fileExistsAtPath:path isDirectory:&isDir];
    return (exist && isDir);
}

+(BOOL)dw_IsFileAtPath:(NSString *)path {
    BOOL isDir = NO;
    BOOL exist = [DefaultFileManager fileExistsAtPath:path isDirectory:&isDir];
    return (exist && !isDir);
}

+(NSArray<DWFileManagerFile *> *)dw_ListFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    if (deep) {///深遍历
        return [self dw_ListFilesInDirectoryAtPath:path depth:1];
    } else {///浅遍历
        NSMutableArray * arr = [NSMutableArray array];
        NSArray * files = [DefaultFileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString * file in files) {
            NSString * fullName = [path stringByAppendingPathComponent:file];
            DWFileManagerFile * fileIns = [DWFileManagerFile new];
            fileIns.fileName = file;
            fileIns.path = path;
            if ([self dw_IsDirectoryAtPath:fullName]) {
                fileIns.isFolder = YES;
            }
            [arr addObject:fileIns];
        }
        return arr;
    }
}

///递归调用，深层遍历
+(NSArray<DWFileManagerFile *> *)dw_ListFilesInDirectoryAtPath:(NSString *)path depth:(NSUInteger)depth {
    NSMutableArray * arr = [NSMutableArray array];
    NSArray * files = [DefaultFileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString * file in files) {
        NSString * fullName = [path stringByAppendingPathComponent:file];
        DWFileManagerFile * fileIns = [DWFileManagerFile new];
        fileIns.fileName = file;
        fileIns.path = path;
        fileIns.depth = depth;
        if ([self dw_IsDirectoryAtPath:fullName]) {
            fileIns.isFolder = YES;
            fileIns.showContent = YES;
            fileIns.files = [self dw_ListFilesInDirectoryAtPath:fullName depth:depth + 1];
        }
        [arr addObject:fileIns];
    }
    return arr;
}

+(BOOL)dw_CreateDirectoryAtPath:(NSString *)path {
    return [self dw_CreateDirectoryAtPath:path error:nil];
}

+(BOOL)dw_CreateDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [DefaultFileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+(BOOL)dw_IsDirectoryIsEmptyAtPath:(NSString *)path {
    if (![self dw_IsDirectoryAtPath:path]) {
        return NO;
    }
    return ([self dw_ListFilesInDirectoryAtPath:path deep:NO].count == 0);
}

+(BOOL)dw_RemoveItemAtPath:(NSString *)path {
    return [DefaultFileManager removeItemAtPath:path error:nil];
}

+(BOOL)dw_ClearDirectoryAtPath:(NSString *)path {
    NSArray *subFiles = [self dw_ListFilesInDirectoryAtPath:path deep:NO];
    BOOL isSuccess = YES;
    for (DWFileManagerFile *file in subFiles) {
        NSString *absolutePath = [path stringByAppendingPathComponent:file.fileName];
        isSuccess &= [self dw_RemoveItemAtPath:absolutePath];
    }
    return isSuccess;
}

+(BOOL)dw_ClearCache {
    return [self dw_ClearDirectoryAtPath:[self dw_CachesDir]];
}

+(BOOL)dw_ClearTmp {
    return [self dw_ClearDirectoryAtPath:[self dw_TmpDir]];
}

+(BOOL)dw_CreateFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    if ([self dw_IsFileAtPath:path] && !overwrite) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":@"attemp to write a file which is already exist."}]);
        return NO;
    }
    
    if (![self dw_CreateDirectoryAtPath:[self dw_DirectoryPathAtPath:path] error:error]) {
        return NO;
    }
    BOOL isSuccess = [DefaultFileManager createFileAtPath:path contents:nil attributes:nil];
    if (content) {
        [self dw_WriteFileAtPath:path content:content error:error];
    }
    return isSuccess;
}

+(BOOL)dw_CreateFileAtPath:(NSString *)path {
    return [self dw_CreateFileAtPath:path content:nil overwrite:NO error:nil];
}

+(BOOL)dw_WriteFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    if (!content) {
        [NSException raise:@"非法的文件内容" format:@"文件内容不能为nil"];
        return NO;
    }
    if ([self dw_IsFileAtPath:path]) {
        if ([content isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSArray class]]) {
            [(NSArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableData class]]) {
            [(NSMutableData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSData class]]) {
            [(NSData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
            [(NSMutableDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSDictionary class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[UIImage class]]) {
            [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
        }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
            [NSKeyedArchiver archiveRootObject:content toFile:path];
        }else {
            [NSException raise:@"非法的文件内容" format:@"文件类型%@异常，无法被处理。", NSStringFromClass([content class])];
            
            return NO;
        }
    }else {
        return NO;
    }
    return YES;
}

+(BOOL)dw_CopyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    if (![self dw_IsFileAtPath:path]) {
        safeLinkError(error, [NSError errorWithDomain:@"Read File Error!" code:10002 userInfo:@{@"reason":[NSString stringWithFormat:@"file not exist at %@.",path]}]);
        return NO;
    }
    if ([self dw_IsFileAtPath:toPath] && !overwrite) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":@"attemp to write a file which is already exist."}]);
        return NO;
    }
    if (![self dw_CreateDirectoryAtPath:toPath]) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":[NSString stringWithFormat:@"can not create folder at %@.",toPath]}]);
        return NO;
    }
    return [DefaultFileManager copyItemAtPath:path toPath:toPath error:error];
}

+(BOOL)dw_MoveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    BOOL isSuccess = [self dw_CopyItemAtPath:path toPath:toPath overwrite:overwrite error:error];
    if (!isSuccess) {
        return NO;
    }
    isSuccess = [self dw_RemoveItemAtPath:path];
    if (!isSuccess) {
        safeLinkError(error, [NSError errorWithDomain:@"Remove File Error!" code:10003 userInfo:@{@"reason":[NSString stringWithFormat:@"can not remove file at %@.",path]}]);
        return NO;
    }
    return YES;
}

+(NSString *)dw_FileNameAtPath:(NSString *)path extention:(BOOL)extention {
    path = [path lastPathComponent];
    if (!extention) {
        path = [path stringByDeletingPathExtension];
    }
    return path;
}

+(NSString *)dw_DirectoryPathAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

+(NSString *)dw_ExtentionAtPath:(NSString *)path {
    return [path pathExtension];
}

+ (NSNumber *)dw_SizeOfDirectoryAtPath:(NSString *)path {
    if ([self dw_IsDirectoryAtPath:path]) {
        NSArray *subPaths = [self dw_ListFilesInDirectoryAtPath:path deep:YES];
        NSEnumerator *contentsEnumurator = [subPaths objectEnumerator];
        NSString *file;
        unsigned long long int folderSize = 0;
        while (file = [contentsEnumurator nextObject]) {
            NSDictionary *fileAttributes = [DefaultFileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
            folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
        }
        return [NSNumber numberWithUnsignedLongLong:folderSize];
    }
    return nil;
}

+(NSNumber *)dw_SizeOfFileAtPath:(NSString *)path {
    if (![self dw_IsFileAtPath:path]) {
        return nil;
    }
    return (NSNumber *)[self dw_AttributeOfItemAtPath:path forKey:NSFileSize];
}

+(NSDate *)dw_CreationDateOfItemAtPath:(NSString *)path {
    if (![self dw_IsFileAtPath:path] && ![self dw_IsDirectoryAtPath:path]) {
        return nil;
    }
    return (NSDate *)[self dw_AttributeOfItemAtPath:path forKey:NSFileCreationDate error:nil];
}

+(NSDate *)dw_ModificationDateOfItemAtPath:(NSString *)path {
    if (![self dw_IsFileAtPath:path] && ![self dw_IsDirectoryAtPath:path]) {
        return nil;
    }
    return (NSDate *)[self dw_AttributeOfItemAtPath:path forKey:NSFileModificationDate error:nil];
}

+(BOOL)dw_IsExecutableItemAtPath:(NSString *)path {
    return [DefaultFileManager isExecutableFileAtPath:path];
}

+(BOOL)dw_IsReadableItemAtPath:(NSString *)path {
    return [DefaultFileManager isReadableFileAtPath:path];
}

+(BOOL)dw_IsWritableItemAtPath:(NSString *)path {
    return [DefaultFileManager isWritableFileAtPath:path];
}

static inline void safeLinkError(NSError * __autoreleasing * error ,NSError * error2Link) {
    if (error != NULL) {
        *error = error2Link;
    }
}

@end

@implementation DWFileManagerFile

-(NSArray *)files {
    if (!_files) {
        _files = [NSArray array];
    }
    return _files;
}

-(NSString *)description {
    if (!self.isFolder) {
        return self.fileName;
    }
    if (self.showContent) {
        NSString * fileStr = @"(";
        NSString * blankStr = @"";
        for (int i = 0; i < self.depth; i ++) {
            blankStr = [blankStr stringByAppendingString:@"    "];
        }
        for (DWFileManagerFile * file in self.files) {
            fileStr = [fileStr stringByAppendingString:[NSString stringWithFormat:@"\r%@%@",[blankStr stringByAppendingString:@"    "],file]];
            if ([file isEqual:self.files.lastObject]) {
                fileStr = [fileStr stringByAppendingString:[NSString stringWithFormat:@"\r%@",blankStr]];
            }
        }
        fileStr = [fileStr stringByAppendingString:[NSString stringWithFormat:@")"]];
        return [NSString stringWithFormat:@"[%@]->%@",self.fileName,fileStr];
    }
    return [NSString stringWithFormat:@"[%@]",self.fileName];
}

@end

