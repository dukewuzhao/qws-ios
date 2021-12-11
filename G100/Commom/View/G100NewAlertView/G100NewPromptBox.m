//
//  G100NewPromptBox.m
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100NewPromptBox.h"
#import "G100AlertConfirmClickView.h"
#import "G100AlertOtherClickView.h"
#import "G100AlertCancelClickView.h"

@implementation G100NewPromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.frame;
    self.boxView.layer.masksToBounds = YES;
    self.boxView.layer.cornerRadius  = 6.0f;
    
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    if (![self superview]) {
        [super showInVc:vc view:view animation:animation];
        
        [view addSubview:self];
    }
}

-(void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    if ([self superview]) {
        [super dismissWithVc:vc animation:animation];
        
        [self removeFromSuperview];
    }
}

@end


@implementation G100NewPromptDefaultBox : G100NewPromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak G100NewPromptDefaultBox * wself = self;
    self.confirmClickView.confirmClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.confirmClickView.tag);
        }
    };
    self.cancelClickView.cancelClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.cancelClickView.tag);
        }
    };
}

+ (instancetype)promptAlertViewWithDefaultStyle {
    G100NewPromptDefaultBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100NewPromptDefaultBox" owner:self options:nil]firstObject];
    return box;
}

- (void)showPromptBoxWithTitle:(NSString *)title content:(NSString *)content confirmButtonTitle:(NSString *)confirmTitle cancelButtonTitle:(NSString *)cancelTitle event:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    self.clickEvent = clickEvent;
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    
    [self.confirmClickView.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [self.cancelClickView.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    
    [self showInVc:viewController view:baseView animation:YES];
}

@end


@implementation G100NewPromptSimpleBox : G100NewPromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak G100NewPromptSimpleBox * wself = self;
    self.confirmClickView.confirmClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.confirmClickView.tag);
        }
    };
}

+ (instancetype)promptAlertViewWithSimpleStyle {
    G100NewPromptSimpleBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100NewPromptSimpleBox" owner:self options:nil]firstObject];
    return box;
}

- (void)showPromptBoxWithTitle:(NSString *)title Content:(NSString *)content confirmButtonTitle:(NSString *)confirmTitle event:(ClickEventBlock)event onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    self.clickEvent = event;
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    
    [self.confirmClickView.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [self showInVc:viewController view:baseView animation:YES];
}

@end


@implementation G100NewPromptDisplayBox : G100NewPromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentLabel.text = @"确认已关注\n“骑卫士”公众号";
    __weak G100NewPromptDisplayBox * wself = self;
    self.confirmClickView.confirmClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.confirmClickView.tag);
        }
    };
    self.otherClickView.otherClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.otherClickView.tag);
        }
    };
    self.cancelClickView.cancelClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.cancelClickView.tag);
        }
    };
}

+ (instancetype)promptAlertViewDisplayStyle {
    G100NewPromptDisplayBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100NewPromptDisplayBox" owner:self options:nil]firstObject];
    return box;
}

- (void)showPromptBoxWithConfirmButtonTitle:(NSString *)confirmTitle otherButtonTitle:(NSString *)otherTitle cancelButtonTitle:(NSString *)cancelTitle event:(ClickEventBlock)event onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    
    self.clickEvent = event;
    
    [self.confirmClickView.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [self.otherClickView.otherButton setTitle:otherTitle forState:UIControlStateNormal];
    [self.cancelClickView.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [self showInVc:viewController view:baseView animation:YES];
}

@end


@interface G100NewPromptPickBox ()

@end

@implementation G100NewPromptPickBox : G100NewPromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentLabel.text = @"您已开通报警通知\n可以立即测试一下";
    __weak G100NewPromptPickBox * wself = self;
    self.confirmClickView.confirmClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.confirmClickView.tag);
        }
    };
    self.cancelClickView.cancelClickBlock = ^(){
        if (wself.clickEvent) {
            wself.clickEvent(wself.cancelClickView.tag);
        }
    };
}

+ (instancetype)promptAlertViewPickStyle {
    G100NewPromptPickBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100NewPromptPickBox" owner:self options:nil]firstObject];
    return box;
}

- (void)showPromptBoxWithConfirmButtonTitle:(NSString *)confirmTitle cancelButtonTitle:(NSString *)cancelTitle event:(ClickEventBlock)event onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    
    self.clickEvent = event;
    
    [self.confirmClickView.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [self.cancelClickView.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [self showInVc:viewController view:baseView animation:YES];
}

- (IBAction)pickTestMode:(UIButton *)sender {
    sender.selected = !sender.selected;
}

@end

