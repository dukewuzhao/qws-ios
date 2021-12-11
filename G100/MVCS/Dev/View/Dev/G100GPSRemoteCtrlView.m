//
//  G100GPSRemoteCtrlView.m
//  G100
//
//  Created by yuhanle on 16/8/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100GPSRemoteCtrlView.h"
#import "G100CardRemoteCtrlViewController.h"
#import "G100CardRemoteCtrlView.h"

@interface G100GPSRemoteCtrlView ()

/** 底层半透明视图*/
@property (nonatomic, strong) UIView *backView;
/** 远程控制卡片容器视图*/
@property (nonatomic, strong) UIView *containerView;
/** 容器视图的中点位置*/
@property (nonatomic, strong) MASConstraint *masContainerViewCenterX;

@end

@implementation G100GPSRemoteCtrlView

- (G100CardRemoteCtrlViewController *)cardRemoteCtrlVC {
    if (!_cardRemoteCtrlVC) {
        _cardRemoteCtrlVC = [[G100CardRemoteCtrlViewController alloc] init];
    }
    return _cardRemoteCtrlVC;
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    self.cardRemoteCtrlVC.userid = self.userid;
    self.cardRemoteCtrlVC.bikeid = self.bikeid;
    self.cardRemoteCtrlVC.devid = self.devid;
    
    self.cardRemoteCtrlVC.bikeDomain = self.cardModel.bike;
    
    if (![self superview]) {
        self.frame = view.bounds;
        
        self.backView = [[UIView alloc] initWithFrame:view.bounds];
        self.backView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.6];
        self.backView.alpha = 0.0;
        [self addSubview:self.backView];
        
        // 添加远程控制卡片
        self.containerView = [[UIView alloc] init];
        [self.backView addSubview:self.containerView];
        
        CGFloat cardH = [G100CardRemoteCtrlView heightForItem:self.cardModel width:WIDTH - 40];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
            make.height.equalTo(cardH);
            self.masContainerViewCenterX = make.centerY.equalTo(self.frame.size.height + cardH);
        }];
        
        [self.popVc addChildViewController:self.cardRemoteCtrlVC];
        [self.containerView addSubview:self.cardRemoteCtrlVC.view];
        
        // 卡片添加阴影效果
        self.containerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.containerView.layer.shadowOffset = CGSizeMake(2, 2);
        self.containerView.layer.shadowOpacity = 0.8;
        self.containerView.layer.shadowRadius = 2;
        
        [self.cardRemoteCtrlVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        [self.cardRemoteCtrlVC setCardModel:self.cardModel];
        
        self.tintColor = [UIColor blackColor];
        self.blurRadius = 0.0;
        
        [view addSubview:self];
        
        [self.masContainerViewCenterX uninstall];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.masContainerViewCenterX = make.centerY.equalTo(self);
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 1.0;
            self.blurRadius = 10.0;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:vc animation:animation];
    
    if ([self superview]) {
        CGFloat cardH = [G100CardRemoteCtrlView heightForItem:self.cardModel width:WIDTH - 40];
        [self.masContainerViewCenterX uninstall];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.masContainerViewCenterX = make.centerY.equalTo(self.frame.size.height + cardH);
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 0.0;
            self.blurRadius = 0.0;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.cardRemoteCtrlVC.view removeFromSuperview];
            [self.cardRemoteCtrlVC removeFromParentViewController];
            self.cardRemoteCtrlVC = nil;
            [self removeFromSuperview];
        }];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    if (CGRectContainsPoint(self.containerView.frame, touchPoint)) {
        return;
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

@end
