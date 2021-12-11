//
//  G100Mediator+InsuranceOrders.m
//  G100
//
//  Created by yuhanle on 2017/1/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator+InsuranceOrders.h"

NSString * const kCTMediatorTargetInsuranceOrders = @"InsuranceOrders";

NSString * const kCTMediatorActionNativeFetchInsuranceOrdersViewController = @"nativeFetchInsuranceOrdersViewController";

@implementation G100Mediator (InsuranceOrders)

- (UIViewController *)G100Mediator_viewControllerForInsuranceOrdersWithUserid:(NSString *)userid params:(NSDictionary *)params loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params2 = [NSMutableDictionary dictionaryWithDictionary:params];
    if (userid) [params2 setObject:userid forKey:@"userid"];
    if (loginHandler) [params2 setObject:loginHandler forKey:@"loginHandler"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetInsuranceOrders
                                                    action:kCTMediatorActionNativeFetchInsuranceOrdersViewController
                                                    params:params2];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

@end