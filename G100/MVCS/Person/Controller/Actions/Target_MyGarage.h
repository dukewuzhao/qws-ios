//
//  Target_MyGarage.h
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_Base.h"
#import "G100Mediator+Login.h"

@interface Target_MyGarage : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchMyGarageViewController:(NSDictionary *)params;

@end
