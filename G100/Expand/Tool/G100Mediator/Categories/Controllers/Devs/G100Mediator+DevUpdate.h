//
//  G100Mediator+DevUpdate.h
//  G100
//
//  Created by 曹晓雨 on 2017/10/26.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (DevUpdate)
- (UIViewController *)G100Mediator_viewControllerForDevUpdate:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;
@end
