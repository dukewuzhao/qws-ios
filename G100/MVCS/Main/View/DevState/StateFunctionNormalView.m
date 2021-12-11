//
//  StateFunctionNormalView.m
//  G100
//
//  Created by William on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "StateFunctionNormalView.h"
#import "XXNibBridge.h"
#import "G100ClickEffectView.h"

@interface StateFunctionNormalView () <XXNibBridge, G100TapAnimationDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *functionImageView;
@property (strong, nonatomic) IBOutlet UILabel *functionLabel;
@property (strong, nonatomic) IBOutlet G100ClickEffectView *clickEffectView;

@end

@implementation StateFunctionNormalView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clickEffectView.delegate = self;
    self.functionLabel.font = [UIFont systemFontOfSize:12];
}

+ (instancetype)loadStateFunctionNormalView {
    return [[[NSBundle mainBundle] loadNibNamed:@"StateFunctionNormalView" owner:self options:nil]lastObject];
}

#pragma mark - G100TapAnimationDelegate
- (void)viewTouchedEndWithView:(UIView *)touchedView touchPoint:(CGPoint)point{
    if (self.tapAction) {
        self.tapAction();
        /*
        if (_functionType == GPSStateFunctionTypePowerRemote) {
            [UIView animateWithDuration:0.3f animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                self.powerRemoteState = !self.powerRemoteState;
                [UIView animateWithDuration:0.3f animations:^{
                    self.alpha = 1;
                }];
            }];
        }
         */
    }
}

- (void)setFunctionType:(GPSStateFunctionType)functionType {
    _functionType = functionType;
    switch (functionType) {
        case GPSStateFunctionTypeSecuritySettings:
        {
            self.functionLabel.text = @"安防设置";
        }
            break;
        case GPSStateFunctionTypeBikeReports:
        {
            self.functionLabel.text = @"用车报告";
            self.functionImageView.image = [UIImage imageNamed:@"gps_bikereport"];
        }
            break;
        case GPSStateFunctionTypeHelpFinding:
        {
            self.functionLabel.text = @"帮我找车";
            self.functionImageView.image = [UIImage imageNamed:@"ic_helpfind"];
        }
            break;
        case GPSStateFunctionTypePowerRemote:
        {
            self.functionLabel.text = @"远程断电";
            self.functionImageView.image = [UIImage imageNamed:@"gps_power_off"];
        }
            break;
        case GPSStateFunctionTypeFindingTip:
        {
            self.functionLabel.text = @"寻车记录";
            self.functionImageView.image = [UIImage imageNamed:@"gps_finding"];
        }
            break;
        case GPSStateFunctionTypeService:
        {
            self.functionLabel.text = @"服务状态";
            self.functionImageView.image = [UIImage imageNamed:@"gps_service"];
        }
            break;
        default:
            break;
    }
}

- (void)setSecurityModeType:(GPSSecurityModeType)securityModeType {
    _securityModeType = securityModeType;
    switch (securityModeType) {
        case GPSSecurityModeTypeStandard:
            self.functionImageView.image = [UIImage imageNamed:@"gps_standardmode"];
            break;
        case GPSSecurityModeTypeWarn:
            self.functionImageView.image = [UIImage imageNamed:@"gps_warnmode"];
            break;
        case GPSSecurityModeTypeNoDisturb:
            self.functionImageView.image = [UIImage imageNamed:@"gps_nodisturb"];
            break;
        case GPSSecurityModeTypeDisArming:
            self.functionImageView.image = [UIImage imageNamed:@"gps_finding"];
            break;
        case GPSSecurityModeTypeNotiOff:
            self.functionImageView.image = [UIImage imageNamed:@"gps_offmode"];
            break;
        default:
            break;
    }
}

- (void)setPowerRemoteState:(GPSPowerRemoteState)powerRemoteState {
    _powerRemoteState = powerRemoteState;
    switch (powerRemoteState) {
        case GPSPowerRemoteStateOff:
            self.functionLabel.text = @"远程断电";
            self.functionImageView.image = [UIImage imageNamed:@"gps_power_off"];
            break;
        case GPSPowerRemoteStateOn:
            self.functionLabel.text = @"恢复供电";
            self.functionImageView.image = [UIImage imageNamed:@"gps_power_on"];
            break;
        default:
            break;
    }
}

@end
