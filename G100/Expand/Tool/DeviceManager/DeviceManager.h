//
//  DeviceManager.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UUIDKEY @"uniqueidentify"

@interface DeviceManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  屏幕的高度
 *
 *  @return 屏幕的高度
 */
+ (NSInteger)currentScreenHeight;
/**
 *  屏幕的宽度
 *
 *  @return 屏幕的宽度
 */
+ (NSInteger)currentScreenWidth;
/**
 *  设备类型 如 iPhone 或 iPod touch
 *
 *  @return iPhone
 */
+ (NSString *)currentDeviceModel;
/**
 *  获取自定义的设备系统信息
 *
 *  @return 如："iPhone7,2|iOS9.3.1|5E3813D223234571BA7C870314241D50"
 */
+ (NSString *)getDeviceAndOSInfo;
/**
 *  可视化机型 如 iPhone 6s
 *
 *  @return iPhone 6s
 */
+ (NSString *)visualizationPlatform;
/**
 *  机型 如 iPhone7,2
 *
 *  @return iPhone7,2
 */
+ (NSString *)platform;
/**
 *  系统信息
 *
 *  @return iOS9.3.1
 */
+ (NSString *)osInfo;

// 系统版本型号
+ (BOOL)isIOS7Version;

+ (BOOL)isIOS8Version;

+ (BOOL)isIOS8ADDVersion;

+ (BOOL)isIOS9Version;

+ (BOOL)isIOS10Version;

// 硬件版本型号
+ (BOOL)isIphone4;

+ (BOOL)isIphone5;

+ (BOOL)isIphone6;

+ (BOOL)isIphone6p;

+ (BOOL)isIphoneX;

+ (BOOL)isIphone;

@end
