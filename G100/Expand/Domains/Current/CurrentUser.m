//
//  CurrentUser.m
//  G100
//
//  Created by Tilink on 15/6/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

+ (instancetype)sharedInfo {
    static CurrentUser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CurrentUser alloc] init];
    });
    
    if (!IsLogin()) {
        return nil;
    }
    
    NSDictionary * dict = [[G100InfoHelper shareInstance] currentUserInfo];
    if (!dict) {
        dict = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXUserInfo];
    }
    
    [instance setValuesForKeysWith_MyDict:dict];
    
    return instance;
}

@end
