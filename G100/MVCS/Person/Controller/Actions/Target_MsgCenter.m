//
//  Target_MsgCenter.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_MsgCenter.h"
#import "G100MsgCenterViewController.h"

@implementation Target_MsgCenter

- (UIViewController *)Action_nativeFetchMsgCenterViewController:(NSDictionary *)params {
    G100MsgCenterViewController * viewController = [[G100MsgCenterViewController alloc] init];
    viewController.userid = params[@"userid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return NO;
}

@end
