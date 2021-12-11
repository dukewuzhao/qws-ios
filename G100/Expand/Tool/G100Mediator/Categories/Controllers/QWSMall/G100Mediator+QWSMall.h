//
//  G100Mediator+QWSMall.h
//  G100
//
//  Created by yuhanle on 2017/7/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (QWSMall)

- (UIViewController *)G100Mediator_viewControllerForQWSMallWithParams:(NSDictionary *)params;

- (UIViewController *)G100Mediator_viewControllerForQWSMallWithUserid:(NSString *)userid bikeid:(NSString *)bikeid params:(NSDictionary *)params;

@end
