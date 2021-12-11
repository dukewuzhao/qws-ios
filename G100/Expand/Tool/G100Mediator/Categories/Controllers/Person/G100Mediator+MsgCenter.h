//
//  G100Mediator+MsgCenter.h
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (MsgCenter)

- (UIViewController *)G100Mediator_viewControllerForMsgCenter:(NSString *)userid;

- (UIViewController *)G100Mediator_viewControllerForMsgCenter:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
