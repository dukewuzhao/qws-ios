//
//  G100Mediator+BikeDetail.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+BikeDetail.h"

NSString * const kCTMediatorTargetBikeDetail = @"BikeDetail";

NSString * const kCTMediatorActionNativFetchBikeDetailViewController = @"nativeFetchBikeDetailViewController";

@implementation G100Mediator (BikeDetail)

- (UIViewController *)G100Mediator_viewControllerForBikeDetail:(NSString *)userid bikeid:(NSString *)bikeid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBikeDetail
                                                    action:kCTMediatorActionNativFetchBikeDetailViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForBikeDetail:(NSString *)userid bikeid:(NSString *)bikeid loginHandler:(void (^)(UIViewController *, BOOL))loginHandler{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];

    UIViewController *viewController = [self performTarget:kCTMediatorTargetBikeDetail
                                                    action:kCTMediatorActionNativFetchBikeDetailViewController
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
