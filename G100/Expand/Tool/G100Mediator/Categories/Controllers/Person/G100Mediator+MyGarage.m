//
//  G100Mediator+MyGarage.m
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator+MyGarage.h"

NSString * const kCTMediatorTargetMyGarage = @"MyGarage";

NSString * const kCTMediatorActionNativeFetchMyGarageViewController = @"nativeFetchMyGarageViewController";

@implementation G100Mediator (MyGarage)

- (UIViewController *)G100Mediator_viewControllerForMyGarageWithUserid:(NSString *)userid loginHandler:(void (^)(UIViewController *, BOOL))loginHandler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (userid) [params setObject:userid forKey:@"userid"];
    if (loginHandler) [params setObject:loginHandler forKey:@"loginHandler"];
    
    return [self performTarget:kCTMediatorTargetMyGarage
                        action:kCTMediatorActionNativeFetchMyGarageViewController
                        params:params];
}

@end
