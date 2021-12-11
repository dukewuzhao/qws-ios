//
//  CSBEffectiveElecView.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum
{
    DefaultCircleView = 1,    //默认
    CycleCircleView = 2
}CircleViewType;
@protocol EffectiveElecHelpBtnDelegate <NSObject>

- (void)helpBtnClicked;

@end

@class G100BatteryDomain;
@interface CSBEffectiveElectricityView : UIView
@property (weak, nonatomic) IBOutlet UILabel *electUseDays;
@property (weak, nonatomic) IBOutlet UIView *circleBackView;

@property (weak, nonatomic) IBOutlet UILabel *batteryUsedTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *batteryTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *batteyVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintView;

@property (weak, nonatomic) IBOutlet UIView *batteryBackView;
@property (nonatomic, weak)id<EffectiveElecHelpBtnDelegate> delegate;
@property (nonatomic, assign)BOOL showBackImgView;
@property (nonatomic, assign)CircleViewType type;

@property (nonatomic, strong)G100BatteryDomain *batteryDomain;

+ (instancetype)showView;

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated;


@end
