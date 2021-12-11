//
//  Target_DeviceDetail.m
//  G100
//
//  Created by yuhanle on 2017/1/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_DeviceDetail.h"
#import "G100DevManagementViewController.h"

@implementation Target_DeviceDetail

- (UIViewController *)Action_nativeFetchDeviceDetailViewController:(NSDictionary *)params {
    G100DevManagementViewController *viewController = [[G100DevManagementViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    return viewController;
}

@end
