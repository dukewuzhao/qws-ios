//
//  G100CustomSwitch.h
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100CustomSwitch;
@protocol G100CustomSwitchDelegate <NSObject>

@optional
/**
 *  开关被点击
 *
 *  @param mwsSwitch 开关实例
 */
- (void)didTapmwsSwitch:(G100CustomSwitch *)mwsSwitch;
/**
 *  开关动画结束
 *
 *  @param mwsSwitch 开关实例
 */
- (void)animationDidStopFormwsSwitch:(G100CustomSwitch *)mwsSwitch;
/**
 *  开关状态发生辩护
 *
 *  @param mwsSwitch 开关实例
 *  @param status    当前状态 参考 mws_status
 */
- (void)valueDidChanged:(G100CustomSwitch *)mwsSwitch status:(int)status;

@end

@interface G100CustomSwitch : UIView

/**
 *  左侧的点颜色
 */
@property (nonatomic, strong) UIColor *leftColor;
/**
 *  右侧的点颜色
 */
@property (nonatomic, strong) UIColor *rightColor;
/**
 *  轨道颜色
 */
@property (nonatomic, strong) UIColor *sliderColor;
/**
 *  动画时间
 */
@property (nonatomic, assign) CGFloat animationDuration;

/**
 *  开关的状态 0 左 1 右
 */
@property (nonatomic, assign) int mws_status;
/**
 *  开关是否可用
 */
@property (nonatomic, assign) BOOL mws_enable;
/**
 *  响应开关状态变化的代理
 */
@property (nonatomic, weak) id <G100CustomSwitchDelegate> delegate;

@end
