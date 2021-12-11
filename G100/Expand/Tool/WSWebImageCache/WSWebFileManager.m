//
//  WSWebFileManager.m
//  G100
//
//  Created by 温世波 on 15/12/8.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "WSWebFileManager.h"

@implementation WSWebFileManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static WSWebFileManager * instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSString *)filePath:(NSString *)fileName {
    NSString * homePath = NSHomeDirectory();
    homePath = [homePath stringByAppendingPathComponent:@"Documents"];
    homePath = [homePath stringByAppendingPathComponent:@"QwsDataCache"];
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:homePath]) {
        // 如果指定缓存目录不存在就创建
        [fm createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (fileName && fileName.length != 0) {
        homePath = [homePath stringByAppendingPathComponent:fileName];
    }

    return homePath;
}

@end
