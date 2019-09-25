//
//  UIDevice+DWDeviceUtils.m
//  DWLogger
//
//  Created by Wicky on 2017/10/9.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "UIDevice+DWDeviceUtils.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <Security/Security.h>

static NSDictionary * infoDic = nil;

@implementation UIDevice (DWDeviceSystemInfo)

+(NSString *)dw_projectBuildNo {
    return getInfoFromSystemInfoDic(CFBridgingRelease(kCFBundleVersionKey));
}

+(NSString *)dw_projectBundleId {
    return getInfoFromSystemInfoDic(CFBridgingRelease(kCFBundleIdentifierKey));
}

+(NSString *)dw_projectDisplayName {
    return getInfoFromSystemInfoDic(CFBridgingRelease(kCFBundleExecutableKey));
}

+(NSString *)dw_projectVersion {
    return getInfoFromSystemInfoDic(@"CFBundleShortVersionString");
}

+(NSString *)dw_deviceUUID {
    return loadUUID();
}

+(NSString *)dw_deviceUserName {
    return [UIDevice currentDevice].name;
}

+(NSString *)dw_deviceName {
    return [UIDevice currentDevice].systemName;
}

+(NSString *)dw_deviceSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+(NSString *)dw_deviceModel {
    return [UIDevice currentDevice].model;
}

+(NSString *)dw_devicePlatform {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
}

+(NSString *)dw_deviceDetailModel {
    NSString * platform = [self dw_devicePlatform];
    if([platform isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
    if([platform isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    if([platform isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    if([platform isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    if([platform isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
    if([platform isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
    if([platform isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    if([platform isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    if([platform isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    if([platform isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
    if([platform isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
    if([platform isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
    if([platform isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
    if([platform isEqualToString:@"iPhone6,3"])  return @"iPhone 5s";
    if([platform isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    if([platform isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    if([platform isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    if([platform isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    if([platform isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    if([platform isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    if([platform isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";
    if([platform isEqualToString:@"iPhone9,3"])  return @"iPhone 7 Plus";
    if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS MAX";
    if([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS MAX";
    if([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if([platform isEqualToString:@"iPod1,1"])  return @"iPod Touch 1G";
    if([platform isEqualToString:@"iPod2,1"])  return @"iPod Touch 2G";
    if([platform isEqualToString:@"iPod3,1"])  return @"iPod Touch 3G";
    if([platform isEqualToString:@"iPod4,1"])  return @"iPod Touch 4G";
    if([platform isEqualToString:@"iPod5,1"])  return @"iPod Touch 5G";
    if([platform isEqualToString:@"iPad1,1"])  return @"iPad 1G";
    if([platform isEqualToString:@"iPad2,1"])  return @"iPad 2";
    if([platform isEqualToString:@"iPad2,2"])  return @"iPad 2";
    if([platform isEqualToString:@"iPad2,3"])  return @"iPad 2";
    if([platform isEqualToString:@"iPad2,4"])  return @"iPad 2";
    if([platform isEqualToString:@"iPad2,5"])  return @"iPad Mini 1G";
    if([platform isEqualToString:@"iPad2,6"])  return @"iPad Mini 1G";
    if([platform isEqualToString:@"iPad2,7"])  return @"iPad Mini 1G";
    if([platform isEqualToString:@"iPad3,1"])  return @"iPad 3";
    if([platform isEqualToString:@"iPad3,2"])  return @"iPad 3";
    if([platform isEqualToString:@"iPad3,3"])  return @"iPad 3";
    if([platform isEqualToString:@"iPad3,4"])  return @"iPad 4";
    if([platform isEqualToString:@"iPad3,5"])  return @"iPad 4";
    if([platform isEqualToString:@"iPad3,6"])  return @"iPad 4";
    if([platform isEqualToString:@"iPad4,1"])  return @"iPad Air";
    if([platform isEqualToString:@"iPad4,2"])  return @"iPad Air";
    if([platform isEqualToString:@"iPad4,3"])  return @"iPad Air";
    if([platform isEqualToString:@"iPad4,4"])  return @"iPad Mini 2G";
    if([platform isEqualToString:@"iPad4,5"])  return @"iPad Mini 2G";
    if([platform isEqualToString:@"iPad4,6"])  return @"iPad Mini 2G";
    if([platform isEqualToString:@"iPad4,7"])  return @"iPad Mini 3";
    if([platform isEqualToString:@"iPad4,8"])  return @"iPad Mini 3";
    if([platform isEqualToString:@"iPad4,9"])  return @"iPad Mini 3";
    if([platform isEqualToString:@"iPad5,1"])  return @"iPad Mini 4";
    if([platform isEqualToString:@"iPad5,2"])  return @"iPad Mini 4";
    if([platform isEqualToString:@"iPad5,3"])  return @"iPad Air 2";
    if([platform isEqualToString:@"iPad5,4"])  return @"iPad Air 2";
    if([platform isEqualToString:@"iPad6,3"])  return @"iPad Pro 9.7";
    if([platform isEqualToString:@"iPad6,4"])  return @"iPad Pro 9.7";
    if([platform isEqualToString:@"iPad6,7"])  return @"iPad Pro 12.9";
    if([platform isEqualToString:@"iPad6,8"])  return @"iPad Pro 12.9";
    if([platform isEqualToString:@"i386"])  return @"iPhone Simulator";
    if([platform isEqualToString:@"x86_64"])  return @"iPhone Simulator";
    return platform;
}

+(NSString *)dw_deviceCPUType {
    NSString * platform = [self dw_devicePlatform];
    if([platform isEqualToString:@"iPhone1,1"])  return @"ARMv6";
    if([platform isEqualToString:@"iPhone1,2"])  return @"ARMv6";
    if([platform isEqualToString:@"iPhone2,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPhone3,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPhone3,2"])  return @"ARMv7";
    if([platform isEqualToString:@"iPhone3,3"])  return @"ARMv7";
    if([platform isEqualToString:@"iPhone4,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPhone5,1"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPhone5,2"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPhone5,3"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPhone5,4"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPhone6,1"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone6,2"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone6,3"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone7,1"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone7,2"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone8,1"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone8,2"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone8,4"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone9,1"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone9,2"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone9,3"])  return @"ARMv8";
    if([platform isEqualToString:@"iPhone10,1"]) return @"ARMv8-A";
    if([platform isEqualToString:@"iPhone10,4"]) return @"ARMv8-A";
    if([platform isEqualToString:@"iPhone10,2"]) return @"ARMv8-A";
    if([platform isEqualToString:@"iPhone10,5"]) return @"ARMv8-A";
    if([platform isEqualToString:@"iPhone10,3"]) return @"ARMv8-A";
    if([platform isEqualToString:@"iPhone10,6"]) return @"ARMv8-A";
    if([platform isEqualToString:@"iPhone11,2"]) return @"ARM64e";
    if([platform isEqualToString:@"iPhone11,4"]) return @"ARM64e";
    if([platform isEqualToString:@"iPhone11,6"]) return @"ARM64e";
    if([platform isEqualToString:@"iPhone11,8"]) return @"ARM64e";
    if([platform isEqualToString:@"iPod1,1"])  return @"ARMv6";
    if([platform isEqualToString:@"iPod2,1"])  return @"ARMv6";
    if([platform isEqualToString:@"iPod3,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPod4,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPod5,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad1,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,2"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,3"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,4"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,5"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,6"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad2,7"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad3,1"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad3,2"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad3,3"])  return @"ARMv7";
    if([platform isEqualToString:@"iPad3,4"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPad3,5"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPad3,6"])  return @"ARMv7s";
    if([platform isEqualToString:@"iPad4,1"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,2"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,3"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,4"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,5"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,6"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,7"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,8"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad4,9"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad5,1"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad5,2"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad5,3"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad5,4"])  return @"ARMv8";
    if([platform isEqualToString:@"iPad6,3"])  return @"ARMv8-A";
    if([platform isEqualToString:@"iPad6,4"])  return @"ARMv8-A";
    if([platform isEqualToString:@"iPad6,7"])  return @"ARMv8-A";
    if([platform isEqualToString:@"iPad6,8"])  return @"ARMv8-A";
    return platform;
}

+(CGFloat)dw_deviceTotalMemory {
    float size = 0.0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: nil];
    if (dictionary) {
        NSNumber *_total = [dictionary objectForKey:NSFileSystemSize];
        size = [_total unsignedLongLongValue]*1.0/(1024);
    }
    return size;
}

+(CGFloat)dw_deviceFreeMemory {
    float size = 0.0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: nil];
    if (dictionary)
    {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        size = [_free unsignedLongLongValue]*1.0/(1024);
    }
    return size;
}

+(NSString *)dw_mobileOperator {
    CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier * carrier = [info subscriberCellularProvider];
    NSString * mCarrier = [NSString stringWithFormat:@"%@",[carrier carrierName]];
    return mCarrier;
}

+(NSString *)dw_developSDKVersion {
    return getInfoFromSystemInfoDic(@"DTSDKBuild");
}

+(CGFloat)dw_batteryVolumn {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
    return deviceLevel;
}

#pragma mark --- tool func ---
NS_INLINE id getInfoFromSystemInfoDic(NSString * key) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoDic = [[NSBundle mainBundle] infoDictionary];
    });
    return [infoDic objectForKey:key];
}

NS_INLINE NSString * uuidString() {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuidValue = (__bridge_transfer NSString *)uuidStringRef;
    uuidValue = [uuidValue lowercaseString];
    uuidValue = [uuidValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidValue;
}

NS_INLINE NSString * loadUUID() {
    NSString * uuid = nil;
    NSString * storeKey = uuidKey();
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    uuid = [ud valueForKey:storeKey];
    
    if (uuid.length) {
        return uuid;
    }

    uuid = loadUUIDFromKeyChain(storeKey);

    if (uuid.length) {
        [ud setValue:uuid forKey:storeKey];
        [ud synchronize];
        return uuid;
    }
    
    uuid = uuidString();
    if (uuid) {
        [ud setValue:uuid forKey:storeKey];
        [ud synchronize];
        saveUUIDToKeyChain(uuid, storeKey);
    }
    return uuid;
}

NS_INLINE NSString * uuidKey() {
    return [NSString stringWithFormat:@"uuid-for-%@",[UIDevice dw_projectBundleId]];
}

NS_INLINE NSString * loadUUIDFromKeyChain(NSString * storeKey) {
    if (!storeKey.length) {
        return nil;
    }
    
    CFTypeRef result = NULL;
    NSMutableDictionary *query = queryDictionary(storeKey);
    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess) {
        return nil;
    }
    
    NSData * data = (__bridge_transfer NSData *)result;
    if ([data length]) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

NS_INLINE void saveUUIDToKeyChain(NSString * uuid,NSString * storeKey) {
    
    if (!uuid.length || !storeKey.length) {
        return;
    }
    
    NSData * uuidData = [uuid dataUsingEncoding:NSUTF8StringEncoding];
    if (!uuidData.length) {
        return;
    }
    
    NSMutableDictionary *query = nil;
    NSMutableDictionary *searchQuery = queryDictionary(storeKey);
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
    if (status == errSecSuccess) {
        query = [NSMutableDictionary dictionary];
        [query setObject:uuidData forKey:(__bridge id)kSecValueData];
        status = SecItemUpdate((__bridge CFDictionaryRef)(searchQuery), (__bridge CFDictionaryRef)(query));
    } else if (status == errSecItemNotFound){
        query = queryDictionary(storeKey);
        [query setObject:uuidData forKey:(__bridge id)kSecValueData];
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
}

NS_INLINE NSMutableDictionary * queryDictionary(NSString * storeKey) {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:storeKey forKey:(__bridge id)kSecAttrService];
    [query setObject:storeKey forKey:(__bridge id)kSecAttrAccount];
    [query setObject:(__bridge id)(kSecAttrSynchronizableAny) forKey:(__bridge id)(kSecAttrSynchronizable)];
    return query;
}

@end
