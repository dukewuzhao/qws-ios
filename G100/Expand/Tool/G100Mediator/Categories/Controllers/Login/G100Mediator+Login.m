//
//  G100Mediator+Login.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+Login.h"

NSString * const kCTMediatorTargetLogin = @"Login";

NSString * const kCTMediatorActionNativeFetchLoginViewController = @"nativeFetchLoginViewController";

NSString * const kCTMediatorActionNativeIsLogined = @"nativeIsLogined";

NSString * const kCTMediatorActionNativePresentLoginViewController = @"nativePresentLoginViewController";

@implementation G100Mediator (Login)

- (UIViewController *)G100Mediator_viewControllerForLogin:(NSDictionary *)params {
    UIViewController *viewController = [self performTarget:kCTMediatorTargetLogin
                                                    action:kCTMediatorActionNativeFetchLoginViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (BOOL)G100Mediator_isLogined {
    return [self performTarget:kCTMediatorTargetLogin
                        action:kCTMediatorActionNativeIsLogined
                        params:nil] ? YES : NO;
}

- (void)G100Mediator_presentViewControllerForLogin:(NSDictionary *)params {
    [self performTarget:kCTMediatorTargetLogin
                 action:kCTMediatorActionNativePresentLoginViewController
                 params:params];
}

- (void)G100Mediator_presentViewControllerForLogin:(NSDictionary *)params completion:(void (^)())completion {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:params];
    if (completion) [dict setObject:completion forKey:@"completion"];
    [self performTarget:kCTMediatorTargetLogin
                 action:kCTMediatorActionNativePresentLoginViewController
                 params:dict];
}

@end
