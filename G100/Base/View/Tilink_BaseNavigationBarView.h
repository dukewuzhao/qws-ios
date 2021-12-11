//
//  Tilink_BaseNavigationBarView.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tilink_BaseNavigationBarView : UIView

- (UIButton *)leftBarButton;

- (UIButton *)rightBarButton;

- (UILabel *)navigationBarTitleLabel;

/**
 *  设置导航栏的标题
 *
 *  @param string 视图标题
 */
- (void)setNavigationTitleLabelText:(NSString *)string;

/**
 *  设置导航栏的背景色
 *
 *  @param color 背景色
 */
- (void)setNavigationBackGroundColor:(UIColor *)color;

/**
 *  设置导航栏右侧的按钮
 *
 *  @param button 导航栏右侧
 */
- (void)setRightBarButton:(UIButton *)button;

/**
 *  设置导航栏标题的透明度
 *
 *  @param alpha 透明度 alpha 0.0 ~ 1.0
 */
- (void)setNavigationTitleLabelAlpha:(CGFloat)alpha;

/**
 *  自定义导航栏标题的宽度
 *
 *  @param width 宽度
 */
- (void)setNavigationTitleLabelWidth:(CGFloat)width;

@end
