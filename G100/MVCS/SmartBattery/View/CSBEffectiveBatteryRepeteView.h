//
//  CSBEffectiveBatteryRepeteView.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BatteryDomain.h"

@interface CSBEffectiveBatteryRepeteView : UIView

@property (weak, nonatomic) IBOutlet UILabel *batteryUsedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *theoreticalCircleCountLabel;

@property (nonatomic, strong)G100BatteryDomain *batteryDomain;
+ (instancetype)showView;

@end
