//
//  Target_Insurance.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Insurance.h"
#import "G100MyInsurancesViewController.h"

@implementation Target_Insurance

- (UIViewController *)Action_nativeFetchInsuranceViewController:(NSDictionary *)params {
    G100MyInsurancesViewController *viewController = [[G100MyInsurancesViewController alloc] init];
    viewController.userid = params[@"userid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
