//
//  G100Mediator+BikeTrack.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (BikeTrack)

- (UIViewController *)G100Mediator_viewControllerForBikeTrack:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid dayStr:(NSString *)dayStr begintime:(NSString *)begintime endtime:(NSString *)endtime;

@end
