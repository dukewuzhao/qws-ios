//
//  G100Mediator+HelpFindBike.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+HelpFindBike.h"

NSString * const kCTMediatorTargetHelpFindBike = @"HelpFindBike";

NSString * const kCTMediatorActionNativFetchHelpFindBikeViewController = @"nativeFetchHelpFindBikeViewController";

@implementation G100Mediator (HelpFindBike)

- (UIViewController *)G100Mediator_viewControllerForHelpFindBike:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetHelpFindBike
                                                    action:kCTMediatorActionNativFetchHelpFindBikeViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForHelpFindBike:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid lostid:(NSInteger)lostid firstPublishTime:(NSString *)firstPublishTime {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    if (lostid) [params setObject:@(lostid) forKey:@"lostid"];
    if (firstPublishTime) [params setObject:firstPublishTime forKey:@"firstPublishTime"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetHelpFindBike
                                                    action:kCTMediatorActionNativFetchHelpFindBikeViewController
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
