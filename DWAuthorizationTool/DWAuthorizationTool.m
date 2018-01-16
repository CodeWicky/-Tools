//
//  DWAuthorizationTool.m
//  a
//
//  Created by 张丁文 on 2018/1/15.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWAuthorizationTool.h"
#import <Contacts/Contacts.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <EventKit/EventKit.h>

#define DWAuthorizationToolErrorDomain @"DWAuthorizationToolError"

typedef NS_ENUM(NSUInteger, AuthorizationType) {
    AddressBook,
    Camera,
    Location,
    PhotoAlbum,
    Microphone,
    Calendar,
    Reminder,
};

@interface DWAuthorizationTool ()<CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager * locM;

@property (nonatomic ,copy)RequestAuthorization requestCompletion;

@property (nonatomic ,assign) BOOL requestingLocation;

@end

static DWAuthorizationTool * tool = nil;
@implementation DWAuthorizationTool

#pragma mark --- Query ---
+(DWAuthorizationStatus)queryAddressBookStatus {
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    return authStatus(authorizationStatus);
}

+(DWAuthorizationStatus)queryCameraStauts {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus(authorizationStatus);
}

+(DWAuthorizationStatus)queryLocationStatus {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    return authStatus(authorizationStatus);
}

+(DWAuthorizationStatus)queryPhotoAlbumStatus {
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    return authStatus(authorizationStatus);
}

+(DWAuthorizationStatus)queryMicrophoneStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return authStatus(authorizationStatus);
}

+(DWAuthorizationStatus)queryCalendarStatus {
    EKAuthorizationStatus authorizationStatus = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    return authStatus(authorizationStatus);
}

+(DWAuthorizationStatus)queryReminderStatus {
    EKAuthorizationStatus authorizationStatus = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeReminder];
    return authStatus(authorizationStatus);
}

#pragma mark --- Request ---
+(void)requestAddressBook:(RequestAuthorization)completion {
    [self requestWithAuthorizationType:AddressBook authorizationKey:@"NSContactsUsageDescription" completion:completion authorizationAction:^{
        [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (completion) {
                completion(granted,granted?DWAuthorizationStatusAuthorized:DWAuthorizationStatusDenied,error);
            }
        }];
    }];
}

+(void)requestCamera:(RequestAuthorization)completion {
    
    [self requestWithAuthorizationType:Camera authorizationKey:@"NSCameraUsageDescription" completion:completion authorizationAction:^{
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (completion) {
                completion(granted,granted?DWAuthorizationStatusAuthorized:DWAuthorizationStatusDenied,nil);
            }
        }];
    }];
}

+(void)requestLocation:(RequestAuthorization)completion {
    DWAuthorizationStatus status = [self queryLocationStatus];
    if (status != DWAuthorizationStatusNotDetermined) {
        if (completion) {
            completion((status == DWAuthorizationStatusAuthorized),status,nil);
        }
        return;
    }
    DWAuthorizationTool * t = [DWAuthorizationTool shareTool];
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSString * locString = infoDic[@"NSLocationAlwaysAndWhenInUseUsageDescription"];
    if([locString length] > 0) {
        [t.locM requestAlwaysAuthorization];
        [t startRequestingLocationWithCompletion:completion];
    } else {
        locString = infoDic[@"NSLocationAlwaysUsageDescription"];
        if ([locString length] > 0) {
            [t.locM requestAlwaysAuthorization];
            [t startRequestingLocationWithCompletion:completion];
        } else {
            locString = infoDic[@"NSLocationWhenInUseUsageDescription"];
            if ([locString length] > 0) {
                [t.locM requestWhenInUseAuthorization];
                [t startRequestingLocationWithCompletion:completion];
                NSArray *backModes = infoDic[@"UIBackgroundModes"];
                if ([backModes containsObject:@"location"]) {
                    t.locM.allowsBackgroundLocationUpdates = YES;
                }
            } else {
                completion(NO,status,errorWithMessage(@"未设置获取定位权限描述",@"NSLocationAlwaysAndWhenInUseUsageDescription/NSLocationAlwaysUsageDescription/NSLocationWhenInUseUsageDescription"));
            }
        }
    }
}

+(void)requestPhotoAlbum:(RequestAuthorization)completion {
    [self requestWithAuthorizationType:PhotoAlbum authorizationKey:@"NSPhotoLibraryUsageDescription" completion:completion authorizationAction:^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (completion) {
                DWAuthorizationStatus authorizationStatus = authStatus(status);
                completion((authorizationStatus == DWAuthorizationStatusAuthorized),authorizationStatus,nil);
            }
        }];
    }];
}

+(void)requestMicrophone:(RequestAuthorization)completion {
    [self requestWithAuthorizationType:Microphone authorizationKey:@"NSMicrophoneUsageDescription" completion:completion authorizationAction:^{
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (completion) {
                completion(granted,granted?DWAuthorizationStatusAuthorized:DWAuthorizationStatusDenied,nil);
            }
        }];
    }];
}

+(void)requestCalendar:(RequestAuthorization)completion {
    [self requestWithAuthorizationType:Calendar authorizationKey:@"NSCalendarsUsageDescription" completion:completion authorizationAction:^{
        [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if (completion) {
                completion(granted,granted?DWAuthorizationStatusAuthorized:DWAuthorizationStatusDenied,error);
            }
        }];
    }];
}

+(void)requestReminder:(RequestAuthorization)completion {
    [self requestWithAuthorizationType:Reminder authorizationKey:@"NSRemindersUsageDescription" completion:completion authorizationAction:^{
        [[EKEventStore new] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            if (completion) {
                completion(granted,granted?DWAuthorizationStatusAuthorized:DWAuthorizationStatusDenied,error);
            }
        }];
    }];
}

#pragma mark --- CLDelegate ---
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.requestingLocation) {
        DWAuthorizationStatus authorizationStatus = authStatus(status);
        if (authorizationStatus != DWAuthorizationStatusNotDetermined) {
            if (self.requestCompletion) {
                self.requestCompletion((authorizationStatus == DWAuthorizationStatusAuthorized), authorizationStatus, nil);
            }
            [self resignLocManager];
        }
    }
}

#pragma mark --- tool func ---
static inline NSError * errorWithMessage(NSString * msg,NSString * key) {
    if (!msg.length) {
        return nil;
    }
    NSError * error = [[NSError alloc] initWithDomain:DWAuthorizationToolErrorDomain code:10000 userInfo:@{@"ErrDesc":[NSString stringWithFormat:@"%@-%@",msg,key]}];
    return error;
}

static inline NSString * authorizationTypeString(AuthorizationType type) {
    switch (type) {
        case AddressBook:
        {
            return @"通讯录";
        }
        case Camera:
        {
            return @"相机";
        }
        case Location:
        {
            return @"定位";
        }
        case PhotoAlbum:
        {
            return @"相册";
        }
        case Microphone:
        {
            return @"麦克风";
        }
        case Calendar:
        {
            return @"日历";
        }
        case Reminder:
        {
            return @"备忘录";
        }
        default:///默认为通讯录权限
            return @"通讯录";
    }
}

static DWAuthorizationStatus authStatus(int status) {
    if (status == 0) {
        return DWAuthorizationStatusNotDetermined;
    } else if (status == 1) {
        return DWAuthorizationStatusRestricted;
    } else if (status == 2) {
        return DWAuthorizationStatusDenied;
    } else {
        return DWAuthorizationStatusAuthorized;
    }
}

#pragma mark --- tool method ---

+(DWAuthorizationStatus)queryWithAuthorizationType:(AuthorizationType)type {
    switch (type) {
        case AddressBook:
        {
            return [self queryAddressBookStatus];
        }
        case Camera:
        {
            return [self queryCameraStauts];
        }
        case Location:
        {
            return [self queryLocationStatus];
        }
        case PhotoAlbum:
        {
            return [self queryPhotoAlbumStatus];
        }
        case Microphone:
        {
            return [self queryMicrophoneStatus];
        }
        case Calendar:
        {
            return [self queryCalendarStatus];
        }
        case Reminder:
        {
            return [self queryReminderStatus];
        }
        default:///默认为通讯录权限
            return [self queryAddressBookStatus];
    }
}

+(void)requestWithAuthorizationType:(AuthorizationType)type authorizationKey:(NSString *)key  completion:(RequestAuthorization)completion authorizationAction:(dispatch_block_t)action {
    DWAuthorizationStatus status = [self queryWithAuthorizationType:type];
    if (status != DWAuthorizationStatusNotDetermined) {
        if (completion) {
            completion((status == DWAuthorizationStatusAuthorized),status,nil);
        }
        return;
    }
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSString * desString = infoDic[key];
    if ([desString length] == 0) {
        if (completion) {
            completion(NO,DWAuthorizationStatusNotDetermined,errorWithMessage([NSString stringWithFormat:@"未设置获取%@权限描述",authorizationTypeString(type)],key));
        }
        return;
    }
    if (action) {
        action();
    }
}

-(void)startRequestingLocationWithCompletion:(RequestAuthorization)comlpetion {
    self.requestingLocation = YES;
    self.requestCompletion = comlpetion;
}

-(void)resignLocManager {
    self.locM = nil;
    self.requestingLocation = NO;
    self.requestCompletion = nil;
}

#pragma mark --- setter/getter ---
-(CLLocationManager *)locM {
    if (!_locM) {
        _locM = [[CLLocationManager alloc] init];
        _locM.delegate = self;
    }
    return _locM;
}

#pragma mark --- Singleton ---
+(instancetype)shareTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [super allocWithZone:zone];
    });
    return tool;
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

@end
