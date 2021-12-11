//
//  G100Mediator+PersonProfile.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+PersonProfile.h"

NSString * const kCTMediatorTargetPersonProfile = @"PersonProfile";

NSString * const kCTMediatorActionNativeFetchPersonProfileViewController = @"nativeFetchPersonProfileViewController";

@implementation G100Mediator (PersonProfile)

- (UIViewController *)G100Mediator_viewControllerForPersonProfile:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetPersonProfile
                                                    action:kCTMediatorActionNativeFetchPersonProfileViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForPersonProfile:(NSString *)userid loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return [self performTarget:kCTMediatorTargetPersonProfile
                        action:kCTMediatorActionNativeFetchPersonProfileViewController
                        params:params];
}

@end
