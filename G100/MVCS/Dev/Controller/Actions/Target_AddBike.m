//
//  Target_AddBike.m
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_AddBike.h"
#import "G100NewBikeViewController.h"

@implementation Target_AddBike

- (UIViewController *)Action_nativeFetchAddBikeViewController:(NSDictionary *)params {
    G100NewBikeViewController *viewController = [[G100NewBikeViewController alloc] init];
    viewController.userid = params[@"userid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
