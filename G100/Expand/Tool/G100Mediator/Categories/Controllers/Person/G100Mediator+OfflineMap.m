//
//  G100Mediator+OfflineMap.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+OfflineMap.h"

NSString * const kCTMediatorTargetOfflineMap = @"OfflineMap";

NSString * const kCTMediatorActionNativFetchOfflineMapViewController = @"nativeFetchOfflineMapViewController";

@implementation G100Mediator (OfflineMap)

- (UIViewController *)G100Mediator_viewControllerForOfflineMap {
    UIViewController *viewController = [self performTarget:kCTMediatorTargetOfflineMap
                                                    action:kCTMediatorActionNativFetchOfflineMapViewController
                                                    params:@{}];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

@end
