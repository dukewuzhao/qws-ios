//
//  DevFeatureSaveView.m
//  G100
//
//  Created by yuhanle on 16/3/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DevFeatureSaveView.h"
#import "G100DeviceDomain.h"

@interface DevFeatureSaveView ()

- (IBAction)saveDevInfoBtnClick:(UIButton *)sender;

@end

@implementation DevFeatureSaveView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.devInfoSaveBtn.exclusiveTouch = YES;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    UIImage * selectedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    UIImage * normalImage = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    
    [self.devInfoSaveBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.devInfoSaveBtn setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [self.devInfoSaveBtn setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
}

- (void)setBikeDomain:(G100BikeDomain *)bikeDomain {
    _bikeDomain = bikeDomain;
    
    if (bikeDomain.isMaster) {
        self.devInfoSaveBtn.hidden = NO;
    }else {
        self.devInfoSaveBtn.hidden = YES;
    }
}

- (void)setDeviceDomain:(G100DeviceDomain *)deviceDomain {
    _deviceDomain = deviceDomain;
    
    if (!deviceDomain) {
        _devBindTimeLabel.text = [NSString stringWithFormat:@"绑定日期：%@", @"暂无"];
        _devVersionLabel.text = [NSString stringWithFormat:@"设备版本号：%@", @"暂无"];
        _devAlertorVersionLabel.text = [NSString stringWithFormat:@"套装版本号：%@", @"暂无"];
        
        _devBindTimeLabel.hidden = YES;
        _devVersionLabel.hidden = YES;
        _devAlertorVersionLabel.hidden = YES;
        
        return;
    }else {
        _devBindTimeLabel.hidden = NO;
        _devVersionLabel.hidden = NO;
        _devAlertorVersionLabel.hidden = NO;
    }
    
    _devBindTimeLabel.text = [NSString stringWithFormat:@"绑定日期：%@", deviceDomain.service.binded_date];
    _devVersionLabel.text = [NSString stringWithFormat:@"设备版本号：%@", deviceDomain.firm];
    
    if (0 == deviceDomain.func.alertor.version.length) {
        _devAlertorVersionLabel.hidden = YES;
    }else{
        _devAlertorVersionLabel.hidden = NO;
        _devAlertorVersionLabel.text = [NSString stringWithFormat:@"套装版本号：%@",deviceDomain.func.alertor.version];
    }
}

- (IBAction)saveDevInfoBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(devFeatureSaveView:saveBtn:)]) {
        [self.delegate devFeatureSaveView:self saveBtn:sender];
    }
}

@end
