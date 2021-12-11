//
//  G100Mediator+BikeDetail.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (BikeDetail)

- (UIViewController *)G100Mediator_viewControllerForBikeDetail:(NSString *)userid bikeid:(NSString *)bikeid;

- (UIViewController *)G100Mediator_viewControllerForBikeDetail:(NSString *)userid bikeid:(NSString *)bikeid loginHandler:(void (^)(UIViewController *, BOOL))loginHandler;

@end
