//
//  G100PopBoxBaseView.h
//  G100
//
//  Created by 温世波 on 15/12/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BaseVC.h"

@interface G100PopBoxBaseView : UIView

@property (weak, nonatomic) UIViewController * popVc;

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation;

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation;

@end
