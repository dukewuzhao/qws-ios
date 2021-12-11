//
//  CABasicAnimation+Additions.h
//  G100
//
//  Created by yuhanle on 16/4/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CABasicAnimation (Additions)

/**
 *  抖动动画
 *
 *  @param duration 间隔时间
 *  @param count    重复次数
 *  @param from     开始点
 *  @param to       结束点
 *
 *  @return 动画实例
 */
+ (CABasicAnimation *)shakeAnimationWithDuration:(CGFloat)duration count:(NSInteger)count from:(CGPoint)from to:(CGPoint)to;

+ (CABasicAnimation *)opacityForeverAnimation:(float)time;

+ (CABasicAnimation *)moveX:(float)time X:(NSNumber *)x;

+ (CABasicAnimation *)moveY:(float)time Y:(NSNumber *)y;

+(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repeatTimes;

+ (CAAnimationGroup *)groupAnimation:(NSArray *)animationAry durTimes:(float)time Rep:(float)repeatTimes;

+ (CAKeyframeAnimation *)keyframeAniamtion:(CGMutablePathRef)path durTimes:(float)time Rep:(float)repeatTimes;

+ (CABasicAnimation *)movepoint:(CGPoint )point;

+ (CABasicAnimation *)duration:(float)dur degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount;

@end
