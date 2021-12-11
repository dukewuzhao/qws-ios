//
//  G100Mediator+WebBrowser.m
//  G100
//
//  Created by yuhanle on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+WebBrowser.h"

NSString * const kCTMediatorTargetWebBrowser = @"WebBrowser";

NSString * const kCTMediatorActionNativFetchWebBrowserViewController = @"nativeFetchWebBrowserViewController";

@implementation G100Mediator (WebBrowser)

- (UIViewController *)G100Mediator_viewControllerForWebBrowser:(NSString *)httpUrl {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (httpUrl) [params setObject:httpUrl forKey:@"httpUrl"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetWebBrowser
                                                    action:kCTMediatorActionNativFetchWebBrowserViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForWebBrowser:(NSString *)userid bikeid:(NSString *)bikeid httpUrl:(NSString *)httpUrl {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (httpUrl) [params setObject:httpUrl forKey:@"httpUrl"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetWebBrowser
                                                    action:kCTMediatorActionNativFetchWebBrowserViewController
                                                    params:params];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[G100NotFoundViewController alloc] init];
    }
}

- (UIViewController *)G100Mediator_viewControllerForWebBrowserWithUserid:(NSString *)userid bikeid:(NSString *)bikeid httpUrl:(NSString *)httpUrl params:(NSDictionary *)otherParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:otherParams];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (httpUrl) [params setObject:httpUrl forKey:@"httpUrl"];
    
    UIViewController *viewController = [self performTarget:kCTMediatorTargetWebBrowser
                                                    action:kCTMediatorActionNativFetchWebBrowserViewController
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
