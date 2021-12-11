//
//  Target_MyGarage.m
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_MyGarage.h"
#import "G100MyGarageViewController.h"

@implementation Target_MyGarage

- (UIViewController *)Action_nativeFetchMyGarageViewController:(NSDictionary *)params {
    G100MyGarageViewController *viewController = [[G100MyGarageViewController alloc] init];
    viewController.userid = params[@"userid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
