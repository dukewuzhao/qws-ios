//
//  G100Mediator+MyGarage.h
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (MyGarage)

- (UIViewController *)G100Mediator_viewControllerForMyGarageWithUserid:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
