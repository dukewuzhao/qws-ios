//
//  StateFunctionNormalView.h
//  G100
//
//  Created by William on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GPSStateFunctionType) {
    GPSStateFunctionTypeSecuritySettings,
    GPSStateFunctionTypeBikeReports,
    GPSStateFunctionTypeHelpFinding,
    GPSStateFunctionTypePowerRemote,
    GPSStateFunctionTypeFindingTip,
    GPSStateFunctionTypeService
};

typedef NS_ENUM(NSInteger, GPSSecurityModeType) {
    GPSSecurityModeTypeStandard = 2,
    GPSSecurityModeTypeWarn = 3,
    GPSSecurityModeTypeNoDisturb = 1,
    GPSSecurityModeTypeDisArming = 8,
    GPSSecurityModeTypeNotiOff = 9
};

typedef NS_ENUM(NSInteger, GPSPowerRemoteState) {
    GPSPowerRemoteStateOff,
    GPSPowerRemoteStateOn
};

typedef void (^TapAction)();

@interface StateFunctionNormalView : UIView

@property (copy, nonatomic) TapAction tapAction;

@property (assign, nonatomic) GPSStateFunctionType functionType;

@property (assign, nonatomic) GPSSecurityModeType securityModeType;

@property (assign, nonatomic) GPSPowerRemoteState powerRemoteState;

+ (instancetype)loadStateFunctionNormalView;

@end
