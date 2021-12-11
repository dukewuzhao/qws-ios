//
//  G100Mediator+BuyService.h
//  G100
//
//  Created by yuhanle on 16/8/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"


@interface G100Mediator (BuyService)

- (UIViewController *)G100Mediator_viewControllerForBuyService:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

- (UIViewController *)G100Mediator_viewControllerForBuyService:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid fromVc:(NSNumber *)fromVc;

- (UIViewController *)G100Mediator_viewControllerForBuyServiceUserid:(NSString *)userid params:(NSDictionary *)params loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
