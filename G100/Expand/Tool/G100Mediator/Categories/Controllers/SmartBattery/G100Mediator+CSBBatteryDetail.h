//
//  G100Mediator+Settings.h
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (CSBBatteryDetail)

- (UIViewController *)G100Mediator_viewControllerForCSBBatteryDetail:(NSString *)userid bikeid:(NSString *)bikeid batteryid:(NSString *)batteryid loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
