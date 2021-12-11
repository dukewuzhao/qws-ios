//
//  Target_BikeFinding.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BikeFinding.h"
#import "G100DevUnderFindingViewController.h"

@implementation Target_BikeFinding

- (UIViewController *)Action_nativeFetchBikeFindingViewController:(NSDictionary *)params {
    G100DevUnderFindingViewController *viewController = [[G100DevUnderFindingViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    //TODO: 切换正确的设备id
    viewController.devid = params[@"bikeid"];
    viewController.lostid = [params[@"lostid"] integerValue];
    return viewController;
}

@end
