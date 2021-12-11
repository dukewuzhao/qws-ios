//
//  Target_Login.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Login.h"
#import "G100UserLoginViewController.h"
#import "TLNavigationController.h"

@implementation Target_Login

- (UIViewController *)Action_nativeFetchLoginViewController:(NSDictionary *)params {
    G100UserLoginViewController *viewController = [[G100UserLoginViewController alloc] initWithNibName:@"G100UserLoginViewController" bundle:nil];
    viewController.loginResult = params[@"loginResult"];
    return viewController;
}

- (id)Action_nativeIsLogined:(NSDictionary *)params {
    return @(IsLogin());
}

- (id)Action_nativePresentLoginViewController:(NSDictionary *)params {
    G100UserLoginViewController *viewController = [[G100UserLoginViewController alloc] initWithNibName:@"G100UserLoginViewController" bundle:nil];
    viewController.loginResult = params[@"loginResult"];
    TLNavigationController * navc = [[TLNavigationController alloc]initWithRootViewController:viewController];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navc animated:YES completion:^{
        void (^completion)() = params[@"completion"];
        if (completion) {
            completion();
        }
    }];
    return @(YES);
}

@end
