//
//  G100Mediator+MapService.m
//  G100
//
//  Created by sunjingjing on 17/3/15.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator+MapService.h"

NSString * const kCTMediatorTargetMapService = @"MapService";

NSString * const kCTMediatorActionNativFetchMapServiceViewController = @"nativeFetchMapServiceViewController";

@implementation G100Mediator (MapService)

- (UIViewController *)G100Mediator_viewControllerForMapService {
    UIViewController *viewController = [self performTarget:kCTMediatorTargetMapService
                                                    action:kCTMediatorActionNativFetchMapServiceViewController
                                                    params:@{}];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForMapService:(NSString *)userid webTitle:(NSString *)webTitle httpUrl:(NSString *)httpUrl loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userid) [params setObject:userid forKey:@"userid"];
    if (webTitle) [params setObject:webTitle forKey:@"webTitle"];
    if (httpUrl) [params setObject:httpUrl forKey:@"httpUrl"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return [self performTarget:kCTMediatorTargetMapService
                        action:kCTMediatorActionNativFetchMapServiceViewController
                        params:params];
}
@end
