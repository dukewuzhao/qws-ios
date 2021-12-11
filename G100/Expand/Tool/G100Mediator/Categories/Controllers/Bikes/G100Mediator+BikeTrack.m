//
//  G100Mediator+BikeTrack.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+BikeTrack.h"

NSString * const kCTMediatorTargetBikeTrack = @"BikeTrack";

NSString * const kCTMediatorActionNativFetchBikeTrackViewController = @"nativeFetchBikeTrackViewController";

@implementation G100Mediator (BikeTrack)

- (UIViewController *)G100Mediator_viewControllerForBikeTrack:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid dayStr:(NSString *)dayStr begintime:(NSString *)begintime endtime:(NSString *)endtime {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    if (dayStr) [params setObject:dayStr forKey:@"dayStr"];
    if (begintime) [params setObject:begintime forKey:@"begintime"];
    if (endtime) [params setObject:endtime forKey:@"endtime"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBikeTrack
                                                    action:kCTMediatorActionNativFetchBikeTrackViewController
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
