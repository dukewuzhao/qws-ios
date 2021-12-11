//
//  G100FXBlurPopBoxBaseView.h
//  G100
//
//  Created by 煜寒了 on 16/1/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "FXBlurView.h"

@interface G100FXBlurPopBoxBaseView : FXBlurView

@property (assign, nonatomic) CGFloat navigationBarAlpha;
@property (assign, nonatomic) BOOL isInteractivePopEnabled;

@property (weak, nonatomic) UIViewController * popVc;

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation;

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation;

@end
