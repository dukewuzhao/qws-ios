//
//  TrackControllView.m
//  G100
//
//  Created by Tilink on 15/2/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "TrackControllView.h"
#import "G100BikeHisTrackDomain.h"

#define MINVALUE    0.0f
#define MAXVALUE    1439.0f

@interface TrackControllView () {
    UIView * _minTrackView;
    NSInteger _currentSpeed;
}

@property (strong, nonatomic) UIView * sliderView;

@end

@implementation TrackControllView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _currentSpeed = 1;
    self.playBtn.v_left = 10.0f;
    self.speedBtn.v_right = WIDTH -  10.0f;
    
    self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(self.playBtn.v_right + 10, (self.v_height - 16)/2, WIDTH - 40 - self.playBtn.v_width * 2, 16)];
    self.sliderView.clipsToBounds = YES;
    self.sliderView.layer.masksToBounds = YES;
    self.sliderView.layer.cornerRadius = 8.0f;
    self.sliderView.backgroundColor = [UIColor colorWithRed:202.0 / 255.0 green:202.0 / 255.0 blue:202.0 / 255.0 alpha:1];
    [self addSubview:self.sliderView];
    
    _minTrackView = [[UIView alloc]initWithFrame:CGRectMake(-1, -1, 1, self.sliderView.v_height + 3)];
    _minTrackView.clipsToBounds = YES;
    
    UIImageView * minImage = [[UIImageView alloc]initWithFrame:CGRectMake(-1, -1, self.sliderView.v_width + 2, self.sliderView.v_height + 3)];
    minImage.image = [UIImage imageNamed:@"ic_history_slider_bg"];
    [_minTrackView addSubview:minImage];
    [self.sliderView addSubview:_minTrackView];
    
    self.slider = [[ASValueTrackingSlider alloc]initWithFrame:self.sliderView.frame];
    [self.slider setMaxFractionDigitsDisplayed:0];
    self.slider.minimumValue = MINVALUE;
    self.slider.maximumValue = MAXVALUE;
    self.slider.popUpViewCornerRadius = 6.0;
    self.slider.popUpViewColor = [UIColor whiteColor];
    self.slider.font = [UIFont systemFontOfSize:12];
    self.slider.dataSource = self;
    self.slider.textColor = [UIColor blackColor];
    
    //滑块图片
    UIImage * thumbImage = [UIImage imageNamed:@"ic_history_slider_btn"];
    self.slider.backgroundColor = [UIColor clearColor];
    self.slider.thumbTintColor = [UIColor clearColor];
    [self.slider setMinimumTrackTintColor:[UIColor clearColor]];
    [self.slider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.slider];
}

- (void)setTracks:(NSArray *)tracks {
    _tracks = tracks;
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = self.tracks.count - 1;
}

- (CGFloat)widthForMinTrackView:(CGFloat)currentValue {
    CGFloat w = 0;
    w = ((currentValue - self.slider.minimumValue) / (self.slider.maximumValue - self.slider.minimumValue)) * self.sliderView.v_width;
    
    return w + 1;
}
- (void)updateTrackView {
    _minTrackView.v_width = [self widthForMinTrackView:self.slider.value];
}

- (void)setPIndex:(NSInteger)pIndex {
    _pIndex = pIndex;
    self.slider.value = pIndex;
}

#pragma mark - 滑动条事件
- (void)sliderValueChanged:(ASValueTrackingSlider *)slider {
    NSInteger index = (NSInteger)slider.value;
    
    if (_tracks && _tracks.count) {
        if (_sliderChanged) {
            self.sliderChanged(index);
        }
    }
}

- (void)sliderDragUp:(ASValueTrackingSlider *)slider {
    NSInteger index = (NSInteger)slider.value;
    
    if (_tracks && _tracks.count) {
        if (_sliderChanged) {
            self.sliderChanged(index);
        }
        
        if (_sliderChangedComplete) {
            self.sliderChangedComplete();
        }
    }
}
- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value {
    [self updateTrackView];
    
    if (self.changedBlock) {
        return self.changedBlock((NSInteger)slider.value);
    }
    
    return @"";
}

- (void)animateSlider:(ASValueTrackingSlider*)slider toValue:(float)value {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [UIView animateWithDuration:0.6 animations:^{
            [slider setValue:value animated:YES];
        }];
    }
    else {
        [slider setValue:value animated:YES];
    }
}

#pragma mark - Actions
- (IBAction)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.playBlock) {
        self.playBlock(sender.selected);
    }
}

- (IBAction)speedBtnClick:(UIButton *)sender {
    switch (_currentSpeed) {
        case 1:
        {
            [sender setTitle:@"4x" forState:UIControlStateNormal];
            _currentSpeed = 2;
        }
            break;
        case 2:
        {
            [sender setTitle:@"16x" forState:UIControlStateNormal];
            _currentSpeed = 4;
        }
            break;
        case 4:
        {
            [sender setTitle:@"32x" forState:UIControlStateNormal];
            _currentSpeed = 8;
        }
            break;
        case 8:
        {
            [sender setTitle:@"64x" forState:UIControlStateNormal];
            _currentSpeed = 16;
        }
            break;
        case 16:
        {
            [sender setTitle:@"1x" forState:UIControlStateNormal];
            _currentSpeed = 1;
        }
            break;
        default:
            break;
    }
    
    if (_speedBlock) {
        self.speedBlock(_currentSpeed);
    }
}

@end
