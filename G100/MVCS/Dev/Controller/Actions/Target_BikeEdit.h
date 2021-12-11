//
//  Target_BikeDetail.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"
#import "G100Mediator+Login.h"

@interface Target_BikeEdit : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchBikeEditViewController:(NSDictionary *)params;

@end
