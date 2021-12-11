//
//  G100Mediator+Settings.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+CSBBatteryDetail.h"

NSString * const kCTMediatorTargetCSBBatteryDetail = @"CSBBatteryDetail";

NSString * const kCTMediatorActionNativeFetchCSBBatteryDetailViewController = @"nativeFetchCSBBatteryDetailViewController";

@implementation G100Mediator (CSBBatteryDetail)

- (UIViewController *)G100Mediator_viewControllerForCSBBatteryDetail:(NSString *)userid bikeid:(NSString *)bikeid batteryid:(NSString *)batteryid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (batteryid) [params setObject:batteryid forKey:@"batteryid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetCSBBatteryDetail
                                                    action:kCTMediatorActionNativeFetchCSBBatteryDetailViewController
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
