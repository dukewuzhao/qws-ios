//
//  UserAccount.m
//  G100
//
//  Created by Tilink on 15/2/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "UserAccount.h"

@implementation UserAccount

+(instancetype)sharedInfo {
    if (!IsLogin()) {
        return nil;
    }
    
    static UserAccount * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserAccount alloc]init];
    });
    
    NSDictionary * dict = [[G100InfoHelper shareInstance] currentAccountInfo];
    if (!dict) {
        dict = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXAccountInfo];
    }
    
    [instance setValuesForKeysWith_MyDict:dict];
    
    return instance;
}

@end
