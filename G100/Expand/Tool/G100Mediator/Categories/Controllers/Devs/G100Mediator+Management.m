//
//  G100Mediator+Management.m
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+Management.h"

NSString * const kCTMediatorTargetManagement = @"Management";

NSString * const kCTMediatorActionNativFetchManagementViewController = @"nativeFetchManagementViewController";

@implementation G100Mediator (Management)

- (UIViewController *)G100Mediator_viewControllerForManagement:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetManagement
                                                    action:kCTMediatorActionNativFetchManagementViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForManagement:(NSString *)userid bikeid:(NSString *)bikeid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetManagement
                                                    action:kCTMediatorActionNativFetchManagementViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

@end
