//
//  G100OverSpeedCustomeCell.m
//  G100
//
//  Created by 曹晓雨 on 2017/3/27.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100OverSpeedCustomeCell.h"

@implementation G100OverSpeedCustomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _slider.minimumTrackTintColor = [UIColor colorWithRed:0.03 green:0.73 blue:0.02 alpha:1.00];
    _slider.continuous = YES;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.speedLabel.text = [NSString stringWithFormat:@"%.0ldKm/H", (long)slider.value * 10];
    
    self.speedLableLeftConstraint.constant = (slider.value * 10 - slider.minimumValue * 10) / ((slider.maximumValue*10 - slider.minimumValue * 10) /(WIDTH - (28 + 48))) ;
    self.sliderValueBlock([NSString stringWithFormat:@"%.0ldKm/H", (long)slider.value * 10].integerValue);
}
- (void)setSliderValue:(float)sliderValue{
    if (sliderValue != _sliderValue) {
        self.speedLabel.text = [NSString stringWithFormat:@"%.0ldKm/H", (long)sliderValue * 10];
        
        self.speedLableLeftConstraint.constant = (sliderValue * 10 - _slider.minimumValue*10) / ((_slider.maximumValue*10 -_slider.minimumValue*10) /(WIDTH - (28 + 48))) ;
        
        _slider.value = [NSString stringWithFormat:@"%.0ldKm/H", (long)sliderValue].integerValue;
    }
 
}

- (void)setIsSelected:(BOOL)isSelected{
        if (!isSelected) {
            _slider.userInteractionEnabled = NO;
            _slider.thumbTintColor = [UIColor grayColor];
            _slider.minimumTrackTintColor = [UIColor grayColor];

        }else{
            _slider.userInteractionEnabled = YES;
            UIImage *image = [[UIImage imageNamed:@"sliderBG"] resizableImageWithCapInsets:UIEdgeInsetsZero];//图片模式，不设置的话会被压缩
            
            [_slider setMinimumTrackImage:image forState:UIControlStateNormal];
            [_slider setMaximumTrackImage:[UIImage imageNamed:@"sliderBG"] forState:UIControlStateNormal];
        }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
 
    // Configure the view for the selected state
}

@end
