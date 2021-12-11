//
//  Target_UserInfo.m
//  G100
//
//  Created by William on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_UserInfo.h"
#import "G100UserInfoViewController.h"

@implementation Target_UserInfo

- (UIViewController *)Action_nativeFetchUserInfoViewController:(NSDictionary *)params {
    G100UserInfoViewController *viewController = [[G100UserInfoViewController alloc]initWithNibName:@"G100UserInfoViewController" bundle:nil];
    return viewController;
}

@end
