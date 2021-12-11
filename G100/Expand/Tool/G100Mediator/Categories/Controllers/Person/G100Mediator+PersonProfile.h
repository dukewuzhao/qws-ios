//
//  G100Mediator+PersonProfile.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (PersonProfile)

- (UIViewController *)G100Mediator_viewControllerForPersonProfile:(NSString *)userid;

- (UIViewController *)G100Mediator_viewControllerForPersonProfile:(NSString *)userid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
