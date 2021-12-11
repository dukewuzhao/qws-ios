//
//  CSBEffectiveBatteyView.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>


@class G100BatteryDomain;
@interface CSBEffectiveBatteyView : UIView
@property (weak, nonatomic) IBOutlet UILabel *effectiveBatteryLabel;

@property (weak, nonatomic) IBOutlet UILabel *designEffectiveBatteryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mAhView;
@property (weak, nonatomic) IBOutlet UIImageView *vaildmAhView;
@property (weak, nonatomic) IBOutlet UILabel *vaildBatteryHintLabel;

@property (nonatomic, strong)G100BatteryDomain *batteryDomain;
+ (instancetype)showView;
@end
