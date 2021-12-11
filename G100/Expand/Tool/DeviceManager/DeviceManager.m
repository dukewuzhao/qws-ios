//
//  DeviceManager.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "DeviceManager.h"
#import "sys/utsname.h"
#import "CHKeychain.h"

@interface DeviceManager ()

@property (nonatomic, copy) NSString *devid; //!< 设备信息

@end

@implementation DeviceManager

+ (instancetype)sharedInstance {
    static DeviceManager * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSInteger)currentScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (NSInteger)currentScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (BOOL)isIOS7Version {
    NSString *version = [UIDevice currentDevice].systemVersion;
    if ([version floatValue]>=7.0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isIOS8Version {
    NSString *version = [UIDevice currentDevice].systemVersion;

    if ([version hasPrefix:@"8"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isIOS8ADDVersion {
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    if ([version floatValue] >= 8.0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isIOS9Version {
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    if ([version hasPrefix:@"9"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isIOS10Version {
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    if ([version hasPrefix:@"10"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)currentDeviceModel {
    return [UIDevice currentDevice].model;
}

+ (BOOL)isIphone4 {
    if ([DeviceManager currentScreenHeight] == 480) {
        return YES;
    }else{
        
        return NO;
    }
}

+ (BOOL)isIphone5{
    if ([DeviceManager currentScreenHeight] == 568) {
        return YES;
    }else{
        
        return NO;
    }
}

+ (BOOL)isIphone6{
    if ([DeviceManager currentScreenHeight] == 667) {
        return YES;
    }else{
        
        return NO;
    }
}

+ (BOOL)isIphone6p{
    if ([DeviceManager currentScreenHeight] == 736) {
        return YES;
    }else{
        
        return NO;
    }
}
+ (BOOL)isIphoneX{
    if ([DeviceManager currentScreenHeight] == 812) {
        return YES;
    }else{
        
        return NO;
    }
}
+ (BOOL)isIphone{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return YES;
    }else{
        
        return NO;
    }
}

+ (NSString *)getDeviceAndOSInfo
{
    if ([[DeviceManager sharedInstance] devid]) {
        return [[DeviceManager sharedInstance] devid];
    }
    
    [DeviceManager sharedInstance].devid = [NSString stringWithFormat:@"%@|iOS%@|%@",
                                            [DeviceManager platform],
                                            [[UIDevice currentDevice] systemVersion],
                                            GetUUID()];
    return [[DeviceManager sharedInstance] devid];
}

+ (NSString *)osInfo {
    return [NSString stringWithFormat:@"iOS%@", [[UIDevice currentDevice] systemVersion]];
}

#pragma mark - 获取设备UUID
NSString * GetUUID () {
    if ([CHKeychain load:UUIDKEY]) {
        NSString *result = [CHKeychain load:UUIDKEY];
        return result;
    }else {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        
        NSMutableString * tmpResult = result.mutableCopy;
        NSRange range = [tmpResult rangeOfString:@"-"];
        
        while (range.location != NSNotFound) {
            [tmpResult deleteCharactersInRange:range];
            
            range = [tmpResult rangeOfString:@"-"];
        }
        [CHKeychain save:UUIDKEY data:tmpResult.copy];
        
        return tmpResult.copy;
    }
    
    return nil;
}

+ (NSString *)platform {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return platform;
}

+ (NSString *)visualizationPlatform {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPod Touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 3G";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 3G";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 3G";
    if ([platform isEqualToString:@"iPad5,1"])   return @"iPad Mini 4G";
    if ([platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4G";
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad6,3"])   return @"iPad Pro (9.7 inch)";
    if ([platform isEqualToString:@"iPad6,4"])   return @"iPad Pro (9.7 inch)";
    if ([platform isEqualToString:@"iPad6,7"])   return @"iPad Pro (12.9 inch)";
    if ([platform isEqualToString:@"iPad6,8"])   return @"iPad Pro (12.9 inch)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

@end
