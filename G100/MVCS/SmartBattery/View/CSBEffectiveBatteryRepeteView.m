//
//  CSBEffectiveBatteryRepeteView.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CSBEffectiveBatteryRepeteView.h"
#import "UILabeL+AjustFont.h"

@implementation CSBEffectiveBatteryRepeteView

+ (instancetype)showView {
    CSBEffectiveBatteryRepeteView *view = [[[NSBundle mainBundle]loadNibNamed:@"CSBEffectiveBatteryRepeteView" owner:nil options:nil] lastObject];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [UILabel adjustAllLabel:self multiple:0.5];
}

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain {
    _batteryDomain = batteryDomain;
    _batteryUsedCountLabel.text = [NSString stringWithFormat:@"%ld ", (long)_batteryDomain.use_cycle.use_num];
    _theoreticalCircleCountLabel.text = [NSString stringWithFormat:@"%ld ", (long)_batteryDomain.use_cycle.rated_num];
}

@end
