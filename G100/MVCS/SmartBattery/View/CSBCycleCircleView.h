//
//  CSBCycleCircleView.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100BatteryDomain;
@interface CSBCycleCircleView : UIView
@property (nonatomic, assign) CGFloat cycleCount;

@property (nonatomic, strong) G100BatteryDomain *batteryDomain;

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated;


@end
