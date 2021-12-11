//
//  G100TopTipsView.h
//  G100
//
//  Created by 温世波 on 15/10/29.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100TopTipsView : UIView

/** 提示性文字 */
@property (copy, nonatomic) NSString * tips;
/** 文案颜色 */
@property (strong, nonatomic) UIColor * tipsColor;
/** 背景颜色 */
@property (strong, nonatomic) UIColor * tipsBackgroundColor;
/** 是否可点击 */
@property (assign, nonatomic) BOOL clickEnable;
/** 开启点击后的点击事件 */
@property (copy, nonatomic) void (^clickEnableBlock) ();
/** 文案距离父视图边界值 */
@property (assign, nonatomic) UIEdgeInsets edgeInsetsMargin;

/** 快速初始化 */
-(instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color tips:(NSString *)tips;

/**
 *  呈现
 *
 *  @param animation 是否开启动画
 */
-(void)showInView:(UIView *)view animation:(BOOL)animation;
/**
 *  呈现deley后消失
 *
 *  @param view          呈现的view
 *  @param animation     是否开启动画
 *  @param delay         延迟消失时间
 *  @param finishedBlock 消失后的操作
 */
-(void)showInView:(UIView *)view animation:(BOOL)animation afterHide:(NSTimeInterval)delay finishedBlock:(void (^)())finishedBlock;
/**
 *  隐藏
 *
 *  @param animation 是否开启动画
 */
-(void)dismissWithAnimation:(BOOL)animation;

@end
