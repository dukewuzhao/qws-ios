//
//  G100WeatherAndCarView.m
//  G100
//
//  Created by sunjingjing on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100WeatherAndCarView.h"

@interface G100WeatherAndCarView ()

@property (assign, nonatomic) BOOL hasDevice;
@end
@implementation G100WeatherAndCarView

+ (instancetype)showView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100WeatherAndCarView" owner:nil options:nil] firstObject];
}

- (instancetype)initViewWithIsBike:(BOOL)hasBike andIsDevice:(BOOL)hasDevice
{
    self =[[[NSBundle mainBundle] loadNibNamed:@"G100WeatherAndCarView" owner:nil options:nil] firstObject];
    if (self) {
        self.weaView = [G100WeatherView showView];
        //self.weaView.frame = self.weatherView.bounds;
        [self.weatherView addSubview:self.weaView];
        [self.weaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        if (hasBike) {
            if (!hasDevice) {
                // self.carView.frame = self.carDeteView.bounds;
                self.noCarView.noLabel.text = @"快来添加车辆吧!";
                [self.carDeteView addSubview:self.noCarView];
                [self.noCarView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(@0);
                }];
            }else
            {
                self.carView = [CarDetectionView showView];
                // self.carView.frame = self.carDeteView.bounds;
                [self.carDeteView addSubview:self.carView];
                [self.carView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(@0);
                }];
            }
        }else
        {
            // self.carView.frame = self.carDeteView.bounds;
            self.noCarView.noLabel.text = @"快来添加车辆吧!";
            [self.carDeteView addSubview:self.noCarView];
            [self.noCarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
    }
    
    return self;
}

- (void)updateViewWithisDevice:(BOOL)isDevice andIsBike:(BOOL)isBike
{
    if (isDevice && self.noCarView) {
        [self.noCarView removeFromSuperview];
        self.noCarView = nil;
        self.carView = [CarDetectionView showView];
        [self.carDeteView addSubview:self.carView];
        [self.carView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }else if(!isDevice && self.carView)
    {
        [self.carView removeFromSuperview];
        self.carView = nil;
        self.noCarView.noLabel.text = @"快来添加车辆吧!";
        [self.carDeteView addSubview:self.noCarView];
        [self.noCarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    
}

+ (CGFloat)heightWithWidth:(CGFloat)width
{
    return width*0.335;
}

@end
