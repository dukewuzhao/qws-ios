//
//  G100Mediator+BikeFinding.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (BikeFinding)

- (UIViewController *)G100Mediator_viewControllerForBikeFinding:(NSString *)userid bikeid:(NSString *)bikeid lostid:(NSInteger)lostid;

- (UIViewController *)G100Mediator_viewControllerForBikeFinding:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid lostid:(NSInteger)lostid;

@end
