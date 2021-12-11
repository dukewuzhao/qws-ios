//
//  G100Mediator+FeedBack.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+FeedBack.h"

NSString * const kCTMediatorTargetFeedBack = @"FeedBack";

NSString * const kCTMediatorActionNativFetchFeedBackViewController = @"nativeFetchFeedBackViewController";

@implementation G100Mediator (FeedBack)

- (UIViewController *)G100Mediator_viewControllerForFeedBack {
    UIViewController *viewController = [self performTarget:kCTMediatorTargetFeedBack
                                                    action:kCTMediatorActionNativFetchFeedBackViewController
                                                    params:@{}];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForFeedBack:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userid) {
        [params setObject:userid forKey:@"userid"];
    }
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetFeedBack
                                                    action:kCTMediatorActionNativFetchFeedBackViewController
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
