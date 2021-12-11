//
//  DevFindingStateView.h
//  G100
//
//  Created by William on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateFunctionNormalView.h"
#import "StateFunctionCustomView.h"

typedef NS_ENUM(NSInteger, GPSType) {
    GPSTypeNoSuit,
    GPSTypeSuit
};

typedef void (^FindingFunctionTapAction)(NSInteger index, GPSType type);

@interface DevFindingStateView : UIView

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *topView;

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *secondView;

@property (strong, nonatomic) IBOutlet StateFunctionNormalView *thirdView;

@property (assign, nonatomic) GPSType gpsType;

@property (assign, nonatomic)  GPSSecurityModeType securityMode;

@property (copy, nonatomic) FindingFunctionTapAction functionTap;

+ (instancetype)loadDevFindingStateView;

@end
