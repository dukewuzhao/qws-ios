//
//  DevNormalStateView.h
//  G100
//
//  Created by William on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateFunctionNormalView.h"
#import "StateFunctionCustomView.h"

typedef void (^NormalFunctionTapAction)(NSInteger index);

@interface DevNormalStateView : UIView

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *securityView;

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *bikeReportView;

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *helpFindView;

@property (strong, nonatomic) IBOutlet StateFunctionCustomView *gprsServiceView;

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *serviceView;

@property (assign, nonatomic)  GPSSecurityModeType securityMode;

+ (instancetype)loadDevNormalStateView;

@property (copy, nonatomic) NormalFunctionTapAction functionTap;

@end
