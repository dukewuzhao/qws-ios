//
//  G100Mediator+BikeReport.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+BikeReport.h"

NSString * const kCTMediatorTargetBikeReport = @"BikeReport";

NSString * const kCTMediatorActionNativFetchBikeReportViewController = @"nativeFetchBikeReportViewController";

@implementation G100Mediator (BikeReport)

- (UIViewController *)G100Mediator_viewControllerForBikeReport:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBikeReport
                                                    action:kCTMediatorActionNativFetchBikeReportViewController
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
