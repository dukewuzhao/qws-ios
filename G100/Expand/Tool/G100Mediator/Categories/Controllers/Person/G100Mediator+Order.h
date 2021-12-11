//
//  G100Mediator+Order.h
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (Order)

- (UIViewController *)G100Mediator_viewControllerForOrder:(NSString *)userid;

- (UIViewController *)G100Mediator_viewControllerForOrder:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
