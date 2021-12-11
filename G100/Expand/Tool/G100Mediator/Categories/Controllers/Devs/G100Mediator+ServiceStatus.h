//
//  G100Mediator+ServiceStatus.h
//  G100
//
//  Created by yuhanle on 16/8/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (ServiceStatus)

- (UIViewController *)G100Mediator_viewControllerForServiceStatus:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

@end
