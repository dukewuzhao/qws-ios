//
//  G100FindCollectionViewCell.m
//  G100
//
//  Created by 温世波 on 16/1/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FindButton.h"

@implementation G100FindButton {
    BOOL _animating;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self startAnimation];
}

-(void)startAnimation {
    _animating = YES;
    
    [self.layer addAnimation:[G100FindButton opacityForever_Animation:random()%3+1] forKey:@"opacity"];
    [self.layer addAnimation:[G100FindButton scale:@(0.6) orgin:@(1.0) durTimes:random()%3 + 2 Rep:MAXFLOAT] forKey:@"transform.scale"];
    [self.backImageView.layer addAnimation:[G100FindButton duration:random()%10+10 degree:M_PI * 2.0 direction:random()%2 ? 1 : -1 repeatCount:MAXFLOAT] forKey:@"transform"];
}

-(void)stopAnimation {
    _animating = NO;
    [self.backImageView.layer removeAllAnimations];
}

+ (CABasicAnimation *)opacityForever_Animation:(float)time // 永久闪烁的动画
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.6];
    animation.autoreverses=YES;
    animation.duration=time;
    animation.repeatCount=FLT_MAX;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CABasicAnimation *)moveX:(float)time X:(NSNumber *)x // 横向移动
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.toValue=x;
    animation.duration=time;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CABasicAnimation *)moveY:(float)time Y:(NSNumber *)y // 纵向移动
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.toValue=y;
    animation.duration=time;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repeatTimes // 缩放
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=orginMultiple;
    animation.toValue=Multiple;
    animation.duration=time;
    animation.autoreverses=YES;
    animation.repeatCount=repeatTimes;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CAAnimationGroup *)groupAnimation:(NSArray *)animationAry durTimes:(float)time Rep:(float)repeatTimes // 组合动画
{
    CAAnimationGroup *animation=[CAAnimationGroup animation];
    animation.animations=animationAry;
    animation.duration=time;
    animation.repeatCount=repeatTimes;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CAKeyframeAnimation *)keyframeAniamtion:(CGMutablePathRef)path durTimes:(float)time Rep:(float)repeatTimes // 路径动画
{
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path=path;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses=NO;
    animation.duration=time;
    animation.repeatCount=repeatTimes;
    return animation;
}

+(CABasicAnimation *)movepoint:(CGPoint )point // 点移动
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation"];
    animation.toValue=[NSValue valueWithCGPoint:point];
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

+(CABasicAnimation *)duration:(float)dur degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount // 旋转
{
    CATransform3D rotationTransform  = CATransform3DMakeRotation(degree, 0, 0, direction);
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    animation.toValue= [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration= dur;
    animation.autoreverses= NO;
    animation.cumulative= YES;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.repeatCount= repeatCount;
    
    return animation;
}

@end
