//
//  G100Mediator+Register.m
//  G100
//
//  Created by William on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+Register.h"

NSString * const kCTMediatorTargetRegister = @"Register";

NSString * const kCTMediatorActionNativeFetchRegisterViewController   = @"nativeFetchRegisterViewController";
NSString * const kCTMediatorActionNativePresentRegisterViewController = @"nativePresentRegisterViewController";

@implementation G100Mediator (Register)

- (UIViewController *)G100Mediator_viewControllerForRegister:(NSDictionary *)params {
    UIViewController *viewController = [self performTarget:kCTMediatorTargetRegister
                                                    action:kCTMediatorActionNativeFetchRegisterViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (void)G100Mediator_presentRegisterViewController:(NSDictionary *)params {
    [self performTarget:kCTMediatorTargetRegister
                 action:kCTMediatorActionNativePresentRegisterViewController
                 params:params];
}

- (void)G100Mediator_presentRegisterViewController:(NSDictionary *)params completion:(void (^)())completion {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:params];
    if (completion) [dict setObject:completion forKey:@"completion"];
    [self performTarget:kCTMediatorTargetRegister
                 action:kCTMediatorActionNativePresentRegisterViewController
                 params:dict];
}

@end
