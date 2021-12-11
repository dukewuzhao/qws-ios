//
//  Target_Register.m
//  G100
//
//  Created by William on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Register.h"
#import "TLNavigationController.h"
#import "G100UserRegisterViewController.h"

@implementation Target_Register

- (UIViewController *)Action_nativeFetchRegisterViewController:(NSDictionary *)params {
    G100UserRegisterViewController *viewController = [[G100UserRegisterViewController alloc] initWithNibName:@"G100UserRegisterViewController" bundle:nil];
    viewController.loginResult = params[@"loginResult"];
    return viewController;
}

- (id)Action_nativePresentRegisterViewController:(NSDictionary *)params {
    G100UserRegisterViewController *viewController = [[G100UserRegisterViewController alloc] initWithNibName:@"G100UserRegisterViewController" bundle:nil];
    viewController.loginResult = params[@"loginResult"];
    TLNavigationController *nav = [[TLNavigationController alloc] initWithRootViewController:viewController];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:^{
        void (^completion)() = params[@"completion"];
        if (completion) {
            completion();
        }
    }];
    return @(YES);
}

@end
