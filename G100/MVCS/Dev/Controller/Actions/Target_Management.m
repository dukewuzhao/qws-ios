//
//  Target_Management.m
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Management.h"
#import "G100UserAndDevManagementViewController.h"

@implementation Target_Management

- (UIViewController *)Action_nativeFetchManagementViewController:(NSDictionary *)params {
    G100UserAndDevManagementViewController *viewController = [[G100UserAndDevManagementViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    return viewController;
}


@end
