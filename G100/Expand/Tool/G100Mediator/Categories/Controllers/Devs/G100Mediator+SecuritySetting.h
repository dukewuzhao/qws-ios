//
//  G100Mediator+SecuritySetting.h
//  G100
//
//  Created by yuhanle on 16/8/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (SecuritySetting)

- (UIViewController *)G100Mediator_viewControllerForSecuritySetting:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

@end
