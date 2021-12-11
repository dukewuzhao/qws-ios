//
//  G100OverSpeedCustomeCell.h
//  G100
//
//  Created by 曹晓雨 on 2017/3/27.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^sliderValueChangedBlock)(float value);

@interface G100OverSpeedCustomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speedLableLeftConstraint;

@property (copy, nonatomic) sliderValueChangedBlock sliderValueBlock;

@property (nonatomic, assign) float sliderValue;
@property (nonatomic, assign) BOOL isSelected;
@end
