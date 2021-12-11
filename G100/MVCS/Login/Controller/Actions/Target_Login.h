//
//  Target_Login.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"

@interface Target_Login : Target_Base

- (UIViewController *)Action_nativeFetchLoginViewController:(NSDictionary *)params;

- (id)Action_nativeIsLogined:(NSDictionary *)params;

- (id)Action_nativePresentLoginViewController:(NSDictionary *)params;

@end
