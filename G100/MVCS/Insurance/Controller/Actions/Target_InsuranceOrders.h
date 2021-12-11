//
//  Target_InsuranceOrders.h
//  G100
//
//  Created by yuhanle on 2017/1/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_Base.h"

@interface Target_InsuranceOrders : Target_Base <G100ShouldLoginProtocol>

- (UIViewController *)Action_nativeFetchInsuranceOrdersViewController:(NSDictionary *)params;

@end
