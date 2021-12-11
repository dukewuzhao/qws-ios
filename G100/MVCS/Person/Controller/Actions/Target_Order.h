//
//  Target_Order.h
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"
#import "G100Mediator+Login.h"

@interface Target_Order : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchOrderViewController:(NSDictionary *)params;

@end
