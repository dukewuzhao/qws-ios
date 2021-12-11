//
//  Target_Register.h
//  G100
//
//  Created by William on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"

@interface Target_Register : Target_Base

- (UIViewController *)Action_nativeFetchRegisterViewController:(NSDictionary *)params;

- (id)Action_nativePresentRegisterViewController:(NSDictionary *)params;

@end
