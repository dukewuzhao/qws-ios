//
//  G100Mediator+DevUpdate.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/26.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator+DevUpdate.h"
NSString * const kCTMediatorTargetDevUpdate = @"DevUpdate";

NSString * const kCTMediatorActionNativFetchDevUpdateViewController = @"nativeFetchDevUpdateViewController";
@implementation G100Mediator (DevUpdate)
- (UIViewController *)G100Mediator_viewControllerForDevUpdate:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetDevUpdate
                                                    action:kCTMediatorActionNativFetchDevUpdateViewController
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
