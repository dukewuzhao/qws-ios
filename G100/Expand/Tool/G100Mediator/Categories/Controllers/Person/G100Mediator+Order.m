//
//  G100Mediator+Order.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+Order.h"

NSString * const kCTMediatorTargetOrder = @"Order";

NSString * const kCTMediatorActionNativeFetchOrderViewController = @"nativeFetchOrderViewController";

@implementation G100Mediator (Order)

- (UIViewController *)G100Mediator_viewControllerForOrder:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetOrder
                                                    action:kCTMediatorActionNativeFetchOrderViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForOrder:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return [self performTarget:kCTMediatorTargetOrder
                        action:kCTMediatorActionNativeFetchOrderViewController
                        params:params];
}

@end
