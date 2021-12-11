//
//  CEClickEffectView.h
//  ClickEffect
//
//  Created by Reese on 13-6-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol G100TapAnimationDelegate <NSObject>

@optional
/**
 *  点击动画完成，去执行下一步动画的回调
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTouchedToBeginAnimate:(UIView *)touchedView touchPoint:(CGPoint)point;

/**
 *  取消点击后的回调
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTouchedCancelWithView:(UIView *)touchedView;

/**
 *  手指离开时的回调
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTouchedEndWithView:(UIView *)touchedView touchPoint:(CGPoint)point;

/**
 *  点击扩散动画完成后的回调
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTouchedAnimateEndWithView:(UIView *)touchedView;


/**
 *  点击扩散动画完成一半后的回调
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTouchedToPushWithView:(UIView *)touchedView touchPoint:(CGPoint)point;;

@end

@interface G100ClickEffectView : UIView

@property(nonatomic,weak) id<G100TapAnimationDelegate> delegate;

/**
 *  未YES时不允许再次点击
 */
@property (nonatomic, assign) BOOL effect_enabled;

/**
 *  动画是否正在执行
 */
@property (assign, nonatomic) BOOL effect_isAnimating;

/**
 *  点击开始扩散动画
 */
- (void)startAnimate;

@end
