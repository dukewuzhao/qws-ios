//
//  Target_HelpFindBike.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_HelpFindBike.h"
#import "G100DevLostInfoViewController.h"

@implementation Target_HelpFindBike

- (UIViewController *)Action_nativeFetchHelpFindBikeViewController:(NSDictionary *)params {
    G100DevLostInfoViewController *viewController = [[G100DevLostInfoViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    //TODO: 切换正确的设备id
    viewController.devid = params[@"bikeid"];
    viewController.lostid = [params[@"lostid"] integerValue];
    viewController.firstPublishTime = params[@"firstPublishTime"];
    return viewController;
}

@end
