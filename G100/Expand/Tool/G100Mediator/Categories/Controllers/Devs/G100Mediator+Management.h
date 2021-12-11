//
//  G100Mediator+Management.h
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (Management)

- (UIViewController *)G100Mediator_viewControllerForManagement:(NSString *)userid;

- (UIViewController *)G100Mediator_viewControllerForManagement:(NSString *)userid bikeid:(NSString *)bikeid;

@end
