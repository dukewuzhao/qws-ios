//
//  G100Mediator+GPS.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (GPS)

- (UIViewController *)G100Mediator_viewControllerForGPS:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

@end
