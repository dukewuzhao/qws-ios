
//
//  G100TrackInfoView.m
//  G100
//
//  Created by 曹晓雨 on 2017/8/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TrackInfoView.h"

@implementation G100TrackInfoView

+ (instancetype)loadXibView {
    G100TrackInfoView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"G100TrackInfoView" owner:self options:nil] lastObject];
    return xibView;
}
- (IBAction)maxSpeedBtnClicked:(id)sender {
    if (!self.overSpeedOpen) {
        self.maxSpeedBtnClicked();
    }
}

- (void)setSummaryDomain:(G100BikeHisSummaryDomain *)summaryDomain{
    _summaryDomain = summaryDomain;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f",_summaryDomain.distance];
    NSInteger time = _summaryDomain.time;
    _timeLabel.text = [NSString stringWithFormat:@"%.1f",  (float)time / 60.0];
    if (self.overSpeedOpen) {
      [_maxSpeedBtn setTitle:[NSString stringWithFormat:@"%dkm/h",_summaryDomain.max_speed]  forState:UIControlStateNormal];
    }else{
        [_maxSpeedBtn setTitle:@"已关闭-点击设置"  forState:UIControlStateNormal];
    }
    
    if (_maxSpeed == 0) {
        _overSpeedDistanceLabel.text = @"超速提醒未选择";
    }else{
        _overSpeedDistanceLabel.text = [NSString stringWithFormat:@"%dkm",_summaryDomain.over_speed_dis];
    }
    _speedLabel.text = [NSString stringWithFormat:@"%d",summaryDomain.ride_speed];
    _speedHintLabel.text = summaryDomain.remind_content;
    }

- (void)setMaxSpeed:(CGFloat)maxSpeed{
    _maxSpeed = maxSpeed;
    if (_maxSpeed == 0) {
        _overSpeedDistanceLabel.text = @"超速提醒未选择";
    }else{
       _overSpeedDistanceLabel.text = [NSString stringWithFormat:@"%dkm",_summaryDomain.over_speed_dis];
    }
}

@end
