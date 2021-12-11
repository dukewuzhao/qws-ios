//
//  G100Mediator+QWSMall.m
//  G100
//
//  Created by yuhanle on 2017/7/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator+QWSMall.h"

NSString * const kCTMediatorTargetQWSMall = @"QWSMall";

NSString * const kCTMediatorActionNativFetchQWSMallViewController = @"nativeFetchQWSMallViewController";

@implementation G100Mediator (QWSMall)

- (UIViewController *)G100Mediator_viewControllerForQWSMallWithParams:(NSDictionary *)params {
    UIViewController *viewController = [self performTarget:kCTMediatorTargetQWSMall
                                                    action:kCTMediatorActionNativFetchQWSMallViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForQWSMallWithUserid:(NSString *)userid bikeid:(NSString *)bikeid params:(NSDictionary *)params {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (userid) [result setObject:userid forKey:@"userid"];
    if (bikeid) [result setObject:bikeid forKey:@"bikeid"];
    
    return [self G100Mediator_viewControllerForQWSMallWithParams:result];
}

@end
