//
//  G100Mediator+Settings.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+Settings.h"

NSString * const kCTMediatorTargetSettings = @"Settings";

NSString * const kCTMediatorActionNativFetchSettingsViewController = @"nativeFetchSettingsViewController";

@implementation G100Mediator (Settings)

- (UIViewController *)G100Mediator_viewControllerForSettings:(NSString *)userid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userid) {
        [params setObject:userid forKey:@"userid"];
    }
    UIViewController *viewController = [self performTarget:kCTMediatorTargetSettings
                                                    action:kCTMediatorActionNativFetchSettingsViewController
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
