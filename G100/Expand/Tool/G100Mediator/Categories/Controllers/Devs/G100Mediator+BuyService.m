//
//  G100Mediator+BuyService.m
//  G100
//
//  Created by yuhanle on 16/8/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+BuyService.h"

NSString * const kCTMediatorTargetBuyService = @"BuyService";

NSString * const kCTMediatorActionNativFetchBuyServiceViewController = @"nativeFetchBuyServiceViewController";

@implementation G100Mediator (BuyService)

- (UIViewController *)G100Mediator_viewControllerForBuyService:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBuyService
                                                    action:kCTMediatorActionNativFetchBuyServiceViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}
- (UIViewController *)G100Mediator_viewControllerForBuyService:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid fromVc:(NSNumber *)fromVc{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (devid)  [params  setObject:devid forKey:@"devid"];
    if (fromVc) [params setObject:fromVc forKey:@"fromvc"];
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBuyService
                                                    action:kCTMediatorActionNativFetchBuyServiceViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForBuyServiceUserid:(NSString *)userid params:(NSDictionary *)params loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params2 = [NSMutableDictionary dictionaryWithDictionary:params];
    if (userid) [params2 setObject:userid forKey:@"userid"];
    if (loginHandler) [params2 setObject:loginHandler forKey:@"loginHandler"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetBuyService
                                                    action:kCTMediatorActionNativFetchBuyServiceViewController
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
