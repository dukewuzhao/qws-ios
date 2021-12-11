//
//  TrackControllView.h
//  G100
//
//  Created by Tilink on 15/2/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"

typedef void(^SliderChanged)();
typedef void(^SliderChangedComplete)();

@class G100BikeHisTrackDomain;
@interface TrackControllView : UIView <ASValueTrackingSliderDataSource>

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *speedBtn;

@property (strong, nonatomic) ASValueTrackingSlider * slider;
@property (strong, nonatomic) NSArray <G100BikeHisTrackDomain *>* tracks;

@property (assign, nonatomic) NSInteger pIndex;

@property (copy, nonatomic) void (^playBlock)(BOOL isSelected);
@property (copy, nonatomic) void (^speedBlock)(NSInteger speed);

@property (copy, nonatomic) NSString *(^changedBlock)(NSInteger pIndex);

@property (copy, nonatomic) SliderChanged sliderChanged;
@property (copy, nonatomic) SliderChangedComplete sliderChangedComplete;

@end
