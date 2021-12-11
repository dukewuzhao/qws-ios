//
//  Target_Order.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Order.h"
#import "G100MyOrderViewController.h"

@implementation Target_Order

- (UIViewController *)Action_nativeFetchOrderViewController:(NSDictionary *)params {
    G100MyOrderViewController * viewController = [[G100MyOrderViewController alloc]init];
    viewController.userid = params[@"userid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
