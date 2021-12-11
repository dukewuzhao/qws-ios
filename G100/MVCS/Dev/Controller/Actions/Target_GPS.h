//
//  Target_GPS.h
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_Base.h"

@interface Target_GPS : Target_Base

- (UIViewController *)Action_nativeFetchGPSViewController:(NSDictionary *)params;

@end
