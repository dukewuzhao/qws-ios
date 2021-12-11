//
//  G100Mediator+BikeFinding.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+BikeFinding.h"

NSString * const kCTMediatorTargetBikeFinding = @"BikeFinding";

NSString * const kCTMediatorActionNativFetchBikeFindingViewController = @"nativeFetchBikeFindingViewController";

@implementation G100Mediator (BikeFinding)

- (UIViewController *)G100Mediator_viewControllerForBikeFinding:(NSString *)userid bikeid:(NSString *)bikeid lostid:(NSInteger)lostid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (lostid) [params setObject:@(lostid) forKey:@"lostid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBikeFinding
                                                    action:kCTMediatorActionNativFetchBikeFindingViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForBikeFinding:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid lostid:(NSInteger)lostid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid && bikeid) [params setObject:bikeid forKey:@"devid"];
    if (lostid) [params setObject:@(lostid) forKey:@"lostid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBikeFinding
                                                    action:kCTMediatorActionNativFetchBikeFindingViewController
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
