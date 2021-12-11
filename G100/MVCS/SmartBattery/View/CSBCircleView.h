//
//  CSBCircleView.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>


@class G100BatteryDomain;
@interface CSBCircleView : UIView


@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) G100BatteryDomain *batteryDomain;

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated;

@end
