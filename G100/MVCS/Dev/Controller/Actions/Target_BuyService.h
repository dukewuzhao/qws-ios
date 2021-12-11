//
//  Target_BuyService.h
//  G100
//
//  Created by yuhanle on 16/8/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"
#import "G100Mediator+Login.h"

@interface Target_BuyService : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchBuyServiceViewController:(NSDictionary *)params;

@end
