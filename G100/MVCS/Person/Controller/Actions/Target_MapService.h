//
//  Target_MapService.h
//  G100
//
//  Created by sunjingjing on 17/3/15.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_Base.h"
#import "G100Mediator+Login.h"

@interface Target_MapService : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchMapServiceViewController:(NSDictionary *)params;

@end
