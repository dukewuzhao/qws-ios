//
//  Target_BikeReport.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BikeReport.h"
#import "G100DevLogsViewController.h"

@implementation Target_BikeReport

- (UIViewController *)Action_nativeFetchBikeReportViewController:(NSDictionary *)params {
    G100DevLogsViewController *viewController = [[G100DevLogsViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    return viewController;
}

@end
