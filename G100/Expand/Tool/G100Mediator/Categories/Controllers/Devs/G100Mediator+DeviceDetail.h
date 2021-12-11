//
//  G100Mediator+DeviceDetail.h
//  G100
//
//  Created by yuhanle on 2017/1/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (DeviceDetail)

- (UIViewController *)G100Mediator_viewControllerForDeviceDetail:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

@end
