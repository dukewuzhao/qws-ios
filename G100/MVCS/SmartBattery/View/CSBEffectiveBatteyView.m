//
//  CSBEffectiveBatteyView.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CSBEffectiveBatteyView.h"
#import "G100BatteryDomain.h"
#import "UILabeL+AjustFont.h"

@implementation CSBEffectiveBatteyView

+ (instancetype)showView
{
    CSBEffectiveBatteyView *view = [[[NSBundle mainBundle]loadNibNamed:@"CSBEffectiveBatteyView" owner:nil options:nil] lastObject];
    return view;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
     self.mAhView.image = [[UIImage imageNamed:@"Ah"]imageWithTintColor:[UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1.00]];
    [UILabel adjustAllLabel:self multiple:0.5];
}
- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain
{
    _batteryDomain = batteryDomain;
    _effectiveBatteryLabel.text = [NSString stringWithFormat:@"%.1f ",_batteryDomain.performance.valid_c / 1000];
    if ((int)(_batteryDomain.performance.rated_c / 1000) == (_batteryDomain.performance.rated_c / 1000)) {
        _designEffectiveBatteryLabel.text = [NSString stringWithFormat:@"%.0f ", _batteryDomain.performance.rated_c /1000];
    }else{
            _designEffectiveBatteryLabel.text = [NSString stringWithFormat:@"%.1f ", _batteryDomain.performance.rated_c /1000];
    }

    if (batteryDomain.performance.valid_c * 1.00 /  _batteryDomain.performance.rated_c < 0.3) {
        _effectiveBatteryLabel.textColor = [UIColor colorWithRed:0.93 green:0.08 blue:0.08 alpha:1.00];
        _vaildBatteryHintLabel.textColor = [UIColor colorWithRed:0.93 green:0.08 blue:0.08 alpha:1.00];
        _vaildmAhView.image = [[UIImage imageNamed:@"Ah"]imageWithTintColor:[UIColor colorWithRed:0.93 green:0.08 blue:0.08 alpha:1.00]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
