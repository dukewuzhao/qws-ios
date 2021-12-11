//
//  G100PopBoxBaseView.m
//  G100
//
//  Created by 温世波 on 15/12/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

@interface G100PopBoxBaseView ()

@property (nonatomic, assign) BOOL previousInteractiveStatus;//!< 记录导航侧滑开关的状态

@end

@implementation G100PopBoxBaseView

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    if ([vc isKindOfClass:[G100BaseVC class]]) {
        G100BaseVC * tmpVc = (G100BaseVC *)vc;
        if (tmpVc.popViewCount == 0) { // 记录页面初始的侧滑开关状态
            self.previousInteractiveStatus = tmpVc.navigationController.interactivePopGestureRecognizer.enabled;
        }
        
        [tmpVc addPopViewCount];
        
        if (tmpVc.popViewCount) {   // 关闭侧滑
            tmpVc.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    self.popVc = vc;
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    if ([vc isKindOfClass:[G100BaseVC class]]) {
        G100BaseVC * tmpVc = (G100BaseVC *)vc;
        [tmpVc reducePopViewCount];
        
        if (!tmpVc.popViewCount) {  // 恢复初始状态
            tmpVc.navigationController.interactivePopGestureRecognizer.enabled = self.previousInteractiveStatus;
        }
    }
}

@end
