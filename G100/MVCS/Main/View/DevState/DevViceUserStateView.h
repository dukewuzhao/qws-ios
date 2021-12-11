//
//  DevViceUserStateView.h
//  G100
//
//  Created by William on 16/8/10.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateFunctionNormalView.h"
#import "StateFunctionCustomView.h"

typedef void (^ViceUserFunctionTapAction)();

@interface DevViceUserStateView : UIView

@property (strong, nonatomic) IBOutlet StateFunctionCustomView *gprsServiceView;

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *serviceView;

@property (copy, nonatomic) ViceUserFunctionTapAction functionTap;

+ (instancetype)loadDevViceUserStateView;

@end
