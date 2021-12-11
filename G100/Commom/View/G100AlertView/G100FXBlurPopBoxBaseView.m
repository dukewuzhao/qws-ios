//
//  G100FXBlurPopBoxBaseView.m
//  G100
//
//  Created by 煜寒了 on 16/1/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FXBlurPopBoxBaseView.h"

@interface G100FXBlurPopBoxBaseView ()

@property (nonatomic, assign) BOOL previousInteractiveStatus;//!< 记录导航侧滑开关的状态

@end

@implementation G100FXBlurPopBoxBaseView

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    self.popVc = vc;
    
    if (vc.popViewCount == 0) { // 记录页面初始的侧滑开关状态
        self.previousInteractiveStatus = vc.navigationController.interactivePopGestureRecognizer.enabled;
    }
    
    if (!vc.popViewCount) {
        self.navigationBarAlpha = self.popVc.navigationController.navigationBar.alpha;
        self.isInteractivePopEnabled = self.popVc.navigationController.interactivePopGestureRecognizer.enabled;
        
        self.popVc.navigationController.navigationBar.alpha = 0.0;
        self.popVc.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if ([vc isKindOfClass:[G100BaseVC class]]) {
        G100BaseVC * tmpVc = (G100BaseVC *)vc;
        [tmpVc addPopViewCount];
        
        if (tmpVc.popViewCount) {   // 关闭侧滑
            tmpVc.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }else {
        [vc addPopViewCount];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    if ([vc isKindOfClass:[G100BaseVC class]]) {
        G100BaseVC * tmpVc = (G100BaseVC *)vc;
        [tmpVc reducePopViewCount];
        
        if (!tmpVc.popViewCount) {  // 恢复初始状态
            tmpVc.navigationController.interactivePopGestureRecognizer.enabled = self.previousInteractiveStatus;
        }
    }else {
        [vc reducePopViewCount];
    }
    
    if (!vc.popViewCount) {
        self.popVc.navigationController.navigationBar.alpha = self.navigationBarAlpha;
        self.popVc.navigationController.interactivePopGestureRecognizer.enabled = self.isInteractivePopEnabled;
        self.popVc.navigationController.interactivePopGestureRecognizer.enabled = self.previousInteractiveStatus;
    }
}

@end
