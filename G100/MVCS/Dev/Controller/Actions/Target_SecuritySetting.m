//
//  Target_SecuritySetting.m
//  G100
//
//  Created by yuhanle on 16/8/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_SecuritySetting.h"
#import "G100FunctionViewController.h"

@implementation Target_SecuritySetting

- (UIViewController *)Action_nativeFetchSecuritySettingViewController:(NSDictionary *)params {
    G100FunctionViewController *viewController = [[G100FunctionViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    return viewController;
}

@end
