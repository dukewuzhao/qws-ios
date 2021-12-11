//
//  G100Mediator+Login.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (Login)

- (UIViewController *)G100Mediator_viewControllerForLogin:(NSDictionary *)params;

- (void)G100Mediator_presentViewControllerForLogin:(NSDictionary *)params;

- (void)G100Mediator_presentViewControllerForLogin:(NSDictionary *)params completion:(void (^)())completion;

- (BOOL)G100Mediator_isLogined;

@end
