//
//  G100Mediator+HelpFindBike.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (HelpFindBike)

- (UIViewController *)G100Mediator_viewControllerForHelpFindBike:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

- (UIViewController *)G100Mediator_viewControllerForHelpFindBike:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid lostid:(NSInteger)lostid firstPublishTime:(NSString *)firstPublishTime;

@end
