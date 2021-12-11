//
//  G100Mediator+Register.h
//  G100
//
//  Created by William on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (Register)

- (UIViewController *)G100Mediator_viewControllerForRegister:(NSDictionary *)params;

- (void)G100Mediator_presentRegisterViewController:(NSDictionary *)params;

- (void)G100Mediator_presentRegisterViewController:(NSDictionary *)params completion:(void (^)())completion;

@end
