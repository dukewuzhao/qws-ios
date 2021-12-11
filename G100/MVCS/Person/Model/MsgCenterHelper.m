//
//  MsgCenterHelper.m
//  G100
//
//  Created by yuhanle on 2018/7/13.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "MsgCenterHelper.h"

@implementation MsgCenterHelper

+ (instancetype)sharedInstace {
    static MsgCenterHelper *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[MsgCenterHelper alloc] init];
    });
    return instance;
}

- (void)loadUnReadMsgStatusWithUserid:(NSString *)userid success:(void(^)(NSInteger personalUnreadNum, NSInteger systemUnreadNum))block {
    [[DatabaseOperation operation] countUnreadNumberWithUserid:[userid integerValue] success:^(NSInteger personalUnreadNum, NSInteger systemUnreadNum) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.unReadMsgCount = personalUnreadNum + systemUnreadNum;
            
            if (block) {
                block(personalUnreadNum, systemUnreadNum);
            }
        });
    }];
}

@end
