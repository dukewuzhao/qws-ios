//
//  G100Mediator+AddBike.m
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+AddBike.h"

NSString * const kCTMediatorTargetAddBike = @"AddBike";

NSString * const kCTMediatorActionNativeFetchAddBikeViewController = @"nativeFetchAddBikeViewController";

@implementation G100Mediator (AddBike)

- (UIViewController *)G100Mediator_viewControllerForAddBike:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetAddBike
                                                    action:kCTMediatorActionNativeFetchAddBikeViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForAddBike:(NSString *)userid loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetAddBike
                                                    action:kCTMediatorActionNativeFetchAddBikeViewController
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
