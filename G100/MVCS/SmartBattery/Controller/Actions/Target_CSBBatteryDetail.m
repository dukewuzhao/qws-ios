//
//  Target_CSBBatteryDetail.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_CSBBatteryDetail.h"
#import "CSBBatteryDetailViewController.h"

@implementation Target_CSBBatteryDetail

- (UIViewController *)Action_nativeFetchCSBBatteryDetailViewController:(NSDictionary *)params {
    CSBBatteryDetailViewController *viewController = [[CSBBatteryDetailViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.batteryid = params[@"batteryid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
