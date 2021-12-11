//
//  Target_GPS.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_GPS.h"
#import "G100DevGPSViewController.h"

@implementation Target_GPS

- (UIViewController *)Action_nativeFetchGPSViewController:(NSDictionary *)params {
    G100DevGPSViewController *viewController = [[G100DevGPSViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    return viewController;
}

@end
