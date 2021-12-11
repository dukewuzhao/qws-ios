//
//  BikeDetailHeaderView.h
//  G100
//
//  Created by yuhanle on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BikeDomain.h"

@class BikeDetailHeaderView;
@protocol BikeDetailHeaderViewDelegate <NSObject>

@optional
- (void)bikeDetailHeaderView:(BikeDetailHeaderView *)view qrcodeBtnClick:(UIButton *)button;

//返回按钮
@optional
- (void)bikeDetailHeaderView:(BikeDetailHeaderView *)view icon_backButtonClick:(UIButton *)button;

//点击背景视图
@optional
- (void)bikeDetailHeaderView:(BikeDetailHeaderView *)view backImageViewTapgesture:(UIImageView * )imageView;

@end

@interface BikeDetailHeaderView : UIView

@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@property (weak, nonatomic) id <BikeDetailHeaderViewDelegate> delegate;

+ (instancetype)loadViewFromNib;

- (void)setCurrentUserName:(NSString *)username;

@end
