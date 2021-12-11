//
//  G100Mediator+MsgCenter.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+MsgCenter.h"

NSString * const kCTMediatorTargetMsgCenter = @"MsgCenter";

NSString * const kCTMediatorActionNativeFetchMsgCenterViewController = @"nativeFetchMsgCenterViewController";

@implementation G100Mediator (MsgCenter)

- (UIViewController *)G100Mediator_viewControllerForMsgCenter:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetMsgCenter
                                                    action:kCTMediatorActionNativeFetchMsgCenterViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForMsgCenter:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return [self performTarget:kCTMediatorTargetMsgCenter
                        action:kCTMediatorActionNativeFetchMsgCenterViewController
                        params:params];
}

@end
