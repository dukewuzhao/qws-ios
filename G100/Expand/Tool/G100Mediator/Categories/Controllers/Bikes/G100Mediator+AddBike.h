//
//  G100Mediator+AddBike.h
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (AddBike)

- (UIViewController *)G100Mediator_viewControllerForAddBike:(NSString *)userid;

- (UIViewController *)G100Mediator_viewControllerForAddBike:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
