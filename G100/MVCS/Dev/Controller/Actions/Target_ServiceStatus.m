//
//  Target_ServiceStatus.m
//  G100
//
//  Created by yuhanle on 16/8/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_ServiceStatus.h"
#import "G100BikeInfoDetailViewController.h"
#import "G100DevManagementViewController.h"

@implementation Target_ServiceStatus

- (UIViewController *)Action_nativeFetchServiceStatusViewController:(NSDictionary *)params {
    NSString *userid = params[@"userid"];
    NSString *bikeid = params[@"bikeid"];
    NSString *devid = params[@"devid"];
    
    if (NOT_NULL(devid)) {
        G100DevManagementViewController *viewController = [[G100DevManagementViewController alloc] init];
        viewController.userid = userid;
        viewController.bikeid = bikeid;
        viewController.devid = devid;
        return viewController;
    }else {
        G100BikeInfoDetailViewController *viewController = [[G100BikeInfoDetailViewController alloc] init];
        viewController.userid = userid;
        viewController.bikeid = bikeid;
        return viewController;
    }
}

@end
