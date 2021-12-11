//
//  Target_AddBike.h
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"
#import "G100Mediator+Login.h"

@interface Target_AddBike : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchAddBikeViewController:(NSDictionary *)params;

@end
