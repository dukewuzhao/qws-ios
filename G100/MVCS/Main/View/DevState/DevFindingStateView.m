//
//  DevFindingStateView.m
//  G100
//
//  Created by William on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DevFindingStateView.h"

@interface DevFindingStateView ()

@end

@implementation DevFindingStateView

- (void)awakeFromNib {
    [super awakeFromNib];
    // 寻车记录
    self.topView.functionType = GPSStateFunctionTypeFindingTip;
    
    // 远程断电
    self.secondView.functionType = GPSStateFunctionTypePowerRemote;
    self.secondView.powerRemoteState = GPSPowerRemoteStateOff;
    
    // 套装 安防设置
    self.gpsType = GPSTypeSuit;
    self.thirdView.securityModeType = GPSSecurityModeTypeStandard;
    /*
    // 非套装 用车报告
    self.gpsType = GPSTypeNoSuit;
    */
}

+ (instancetype)loadDevFindingStateView {
    return [[[NSBundle mainBundle] loadNibNamed:@"DevFindingStateView" owner:self options:nil]lastObject];
}

- (void)setGpsType:(GPSType)gpsType {
    _gpsType = gpsType;
    
    __weak DevFindingStateView * wself = self;
    self.topView.tapAction = ^(){
        wself.functionTap(0, gpsType);
    };
    
    self.secondView.tapAction = ^(){
        wself.functionTap(1, gpsType);
    };
    
    self.thirdView.tapAction = ^() {
        wself.functionTap(2, gpsType);
    };
    
    switch (gpsType) {
        case GPSTypeNoSuit:
        {
            self.thirdView.functionType = GPSStateFunctionTypeBikeReports;
        }
            break;
        case GPSTypeSuit:
        {
            self.thirdView.functionType = GPSStateFunctionTypeSecuritySettings;
        }
            break;
        default:
            break;
    }
}

- (void)setSecurityMode:(GPSSecurityModeType)securityMode {
    self.thirdView.securityModeType = securityMode;
}

@end
