//
//  G100Mediator+ScanCode.m
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator+ScanCode.h"

NSString * const kCTMediatorTargetPScanCode = @"ScanCode";

NSString * const kCTMediatorActionNativeFetchScanCodeViewController = @"nativeFetchScanCodeViewController";

@implementation G100Mediator (ScanCode)

- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bindMode:(int)bindMode {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bindMode) [params setObject:@(bindMode) forKey:@"bindMode"];
    
    return  [self performTarget:kCTMediatorTargetPScanCode
                         action:kCTMediatorActionNativeFetchScanCodeViewController
                         params:params];
}

- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bikeid:(NSString *)bikeid bindMode:(int)bindMode loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bikeid) [params setObject:bikeid forKey:@"bikeid"];
    if (bikeid) [params setObject:bikeid forKey:@"qrcode"];
    if (bindMode) [params setObject:@(bindMode) forKey:@"bindMode"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return  [self performTarget:kCTMediatorTargetPScanCode
                         action:kCTMediatorActionNativeFetchScanCodeViewController
                         params:params];
}

- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bindMode:(int)bindMode loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bindMode) [params setObject:@(bindMode) forKey:@"bindMode"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return  [self performTarget:kCTMediatorTargetPScanCode
                         action:kCTMediatorActionNativeFetchScanCodeViewController
                         params:params];
}

- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid devid:(NSString *)devid bindMode:(int)bindMode loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (devid) [params setObject:devid forKey:@"devid"];
    if (devid) [params setObject:devid forKey:@"qrcode"];
    if (bindMode) [params setObject:@(bindMode) forKey:@"bindMode"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return  [self performTarget:kCTMediatorTargetPScanCode
                         action:kCTMediatorActionNativeFetchScanCodeViewController
                         params:params];
}

- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bindMode:(int)bindMode operation:(int)operation loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (bindMode) [params setObject:@(bindMode) forKey:@"bindMode"];
    if (operation) [params setObject:@(operation) forKey:@"operationMethod"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return  [self performTarget:kCTMediatorTargetPScanCode
                         action:kCTMediatorActionNativeFetchScanCodeViewController
                         params:params];
}

@end
