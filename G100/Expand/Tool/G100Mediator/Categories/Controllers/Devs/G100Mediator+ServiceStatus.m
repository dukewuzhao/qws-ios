//
//  G100Mediator+ServiceStatus.m
//  G100
//
//  Created by yuhanle on 16/8/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+ServiceStatus.h"

NSString * const kCTMediatorTargetServiceStatus = @"ServiceStatus";

NSString * const kCTMediatorActionNativFetchServiceStatusViewController = @"nativeFetchServiceStatusViewController";

@implementation G100Mediator (ServiceStatus)

- (UIViewController *)G100Mediator_viewControllerForServiceStatus:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetServiceStatus
                                                    action:kCTMediatorActionNativFetchServiceStatusViewController
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
