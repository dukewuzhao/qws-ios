//
//  G100Mediator+BikeDetail.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (BikeEdit)

- (UIViewController *)G100Mediator_viewControllerForBikeEdit:(NSString *)userid bikeid:(NSString *)bikeid entranceFrom:(NSInteger)entranceFrom;

- (UIViewController *)G100Mediator_viewControllerForBikeEdit:(NSString *)userid bikeid:(NSString *)bikeid entranceFrom:(NSInteger)entranceFrom loginHandler:(void (^)(UIViewController *, BOOL))loginHandler;

@end
