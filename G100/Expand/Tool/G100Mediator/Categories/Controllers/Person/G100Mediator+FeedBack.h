//
//  G100Mediator+FeedBack.h
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (FeedBack)

- (UIViewController *)G100Mediator_viewControllerForFeedBack;

- (UIViewController *)G100Mediator_viewControllerForFeedBack:(NSString *)userid;

@end
