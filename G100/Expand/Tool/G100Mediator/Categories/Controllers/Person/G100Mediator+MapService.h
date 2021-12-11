//
//  G100Mediator+MapService.h
//  G100
//
//  Created by sunjingjing on 17/3/15.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (MapService)

- (UIViewController *)G100Mediator_viewControllerForMapService;

- (UIViewController *)G100Mediator_viewControllerForMapService:(NSString *)userid webTitle:(NSString *)webTitle httpUrl:(NSString *)httpUrl loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;
@end
