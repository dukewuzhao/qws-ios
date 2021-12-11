//
//  Target_Settings.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Settings.h"
#import "G100SettingsViewController.h"

@implementation Target_Settings

- (UIViewController *)Action_nativeFetchSettingsViewController:(NSDictionary *)params {
    G100SettingsViewController * viewController = [[G100SettingsViewController alloc]init];
    viewController.userid = params[@"userid"];
    return viewController;
}

@end
