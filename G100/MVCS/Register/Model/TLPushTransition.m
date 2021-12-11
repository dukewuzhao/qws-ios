//
//  TLPushTransition.m
//  G100
//
//  Created by William on 16/8/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "TLPushTransition.h"
#import "G100UserRegisterViewController.h"
#import "G100UserLoginViewController.h"

@interface TLPushTransition ()

@property (nonatomic,strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation TLPushTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.8f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //把toView加到containerView上
    G100UserRegisterViewController *fromVC = (G100UserRegisterViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    G100UserLoginViewController *toVC = (G100UserLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    fromView.frame = initialFrame;
    toView.frame = initialFrame;
    
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toView];
    [containerView insertSubview:fromView aboveSubview:toView];

    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:[self transitionDuration:transitionContext]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:YES];
    //  交换本视图控制器中2个view位置
    [containerView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    [UIView commitAnimations];
    
    [transitionContext completeTransition:YES];
}

@end
