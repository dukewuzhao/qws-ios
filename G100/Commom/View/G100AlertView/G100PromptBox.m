 //
//  G100PromptBox.m
//  G100
//
//  Created by Tilink on 15/3/31.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PromptBox.h"
#import <YYText.h>

#define ImageAddedHeight WIDTH*(128/320.0)-128
#define ImageG500AddedHeight WIDTH*(250/320.0)-250


@interface G100PromptBox () {
    CGFloat _previousKeyboardDistance;
}

@end

@implementation G100PromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.frame;
    
    self.boxView.layer.masksToBounds = YES;
    self.boxView.layer.cornerRadius  = 6.0f;
    
    [self.iknowButton setExclusiveTouch:YES];
    [self.cancelButton setExclusiveTouch:YES];
    
    [self.iknowButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_sure_bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_cancel_bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

+(instancetype)promptBoxIKnowAlertView {
    G100PromptBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100PromptBox" owner:self options:nil]firstObject];
    box.promptBoxStyle = G100PromptBoxStyleIknow;
    return box;
}
+(instancetype)promptBoxTextfieldAlertView {
    G100PromptBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100PromptBox" owner:self options:nil] safe_objectAtIndex:1];
    box.promptBoxStyle = G100PromptBoxStyleTextField;
    return box;
}
+(instancetype)promptBoxSureOrCancelAlertView {
    G100PromptBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100PromptBox" owner:self options:nil]lastObject];
    box.promptBoxStyle = G100PromptBoxStyleSureOrCancel;
    return box;
}

+(instancetype)promptImageBoxSureOrCancelAlertView {
    G100PromptBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100ImagePromptBox" owner:self options:nil]firstObject];
    box.promptBoxStyle = G100PromptBoxStyleImageHint;
    return box;
}

// 确定取消按钮
-(void)showBoxWith:(NSString *)title prompt:(NSString *)prompt center:(BOOL)isCenter sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent {
    
    self.isTouchMarginCancel = YES;
    self.isContentCenter = isCenter;
    self.boxView.layer.masksToBounds = YES;
    self.boxView.layer.cornerRadius = 6.0f;
    self.boxTitleLabel.text = title;
    self.promptLabel.text = prompt;
    
    self.promptLabel.numberOfLines = 0;
    
    if (self.isContentCenter) {
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
    }else {
        self.promptLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    [self.promptLabel sizeToFit];
    
    CGSize fontSize = [self.promptLabel.text calculateSize:CGSizeMake(_promptLabel.frame.size.width, 200) font:_promptLabel.font];
    
    if (fontSize.height > 30) {
        self.alertViewHeightConstraint.constant = 130 + fontSize.height;
    }else {
        self.alertViewHeightConstraint.constant = 150 + fontSize.height;
    }
    
    self.sureEvent = sureEvent;
    self.cancelEvent = cancelEvent;
    
    [self show];
}

- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt imageName:(NSString*)name sureTitle:(NSString *)sureTitle sure:(SureEventBlock)sureEvent {
    if (name) {
        [self.boxImageView setImage:[UIImage imageNamed:name]];
    }
    
    if (!sureTitle) {
        sureTitle = @"我知道了";
    }

    self.boxTitleLabel.text = title;
    self.promptLabel.text = prompt;
    
    self.promptLabel.numberOfLines = 0;
    self.promptLabel.font = [UIFont systemFontOfSize:17];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.promptLabel sizeToFit];
    
    [self.iknowButton setTitle:sureTitle forState:UIControlStateNormal];
    self.sureEvent = sureEvent;
    
    CGSize fontSize = [self.promptLabel.text calculateSize:CGSizeMake(_promptLabel.frame.size.width, 200) font:_promptLabel.font];
    
    if (name) {
        CGFloat imageWidthAdd = 0;
        if ([name isEqualToString:@"ic_reboot_introduction_G500"]) {
            imageWidthAdd = 180 + ImageG500AddedHeight;
        }else{
            imageWidthAdd = ImageAddedHeight;
        }
        if (fontSize.height > 30) {
            self.promptLabel.textAlignment = NSTextAlignmentLeft;
            self.alertViewHeightConstraint.constant = 270 + fontSize.height + imageWidthAdd;
        }else {
            self.promptLabel.textAlignment = NSTextAlignmentCenter;
            self.alertViewHeightConstraint.constant = 290 + imageWidthAdd;
        }
    }else{
        if (fontSize.height > 30) {
            self.promptLabel.textAlignment = NSTextAlignmentLeft;
            self.alertViewHeightConstraint.constant = 150 + fontSize.height;
        }else {
            self.promptLabel.textAlignment = NSTextAlignmentCenter;
            self.alertViewHeightConstraint.constant = 170 + fontSize.height;
        }
    }
    
    if (self.isContentCenter)
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
    
    [self show];
}

// 一个按钮
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt sureTitle:(NSString *)sureTitle sure:(SureEventBlock)sureEvent {
    [self showBoxWith:title prompt:prompt imageName:nil sureTitle:sureTitle sure:sureEvent];
}
-(void)showBoxWith:(NSString *)title prompt:(NSString *)prompt sureTitle:(NSString *)sureTitle sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent {
    [self showBoxWith:title prompt:prompt sureTitle:sureTitle sure:sureEvent];
    self.cancelEvent = cancelEvent;
}
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTilte sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent {
    [self showBoxWith:title prompt:prompt sureTitle:sureTitle sure:sureEvent];
    self.cancelEvent = cancelEvent;
    [self.cancelButton setTitle:cancelTilte forState:UIControlStateNormal];
}

- (void)showBoxWith:(NSString *)title attriPrompt:(NSMutableAttributedString *)attriPrompt sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTilte sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent {
    if (!sureTitle) {
        sureTitle = @"我知道了";
    }
    
    self.boxTitleLabel.text = title;
    self.promptLabel.attributedText = attriPrompt;
    
    self.promptLabel.numberOfLines = 0;
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.promptLabel sizeToFit];
    
    [self.iknowButton setTitle:sureTitle forState:UIControlStateNormal];
    self.sureEvent = sureEvent;
    
    NSString * promptStr = [attriPrompt string];
    
    CGSize fontSize = [promptStr calculateSize:CGSizeMake(_promptLabel.frame.size.width, 200) font:_promptLabel.font];
    
    if (fontSize.height > 30) {
        self.promptLabel.textAlignment = NSTextAlignmentLeft;
        self.alertViewHeightConstraint.constant = 150 + fontSize.height;
    }else {
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
        self.alertViewHeightConstraint.constant = 170 + fontSize.height;
    }
    
    if (self.isContentCenter)
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
    
    [self show];
}


-(void)show {
    /*
    self.boxView.transform = CGAffineTransformMakeScale(0.3f, 0.3f);//将要显示的view按照正常比例显示出来
    [UIView animateWithDuration:0.3f animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
        self.boxView.transform=CGAffineTransformMakeScale(1.0f, 1.0f);//先让要显示的view最小直至消失
    } completion:nil];
     */
    
    UIView *baseView = nil;
    UIViewController *baseVC = nil;
    
    if (self.baseVC)
        baseVC = self.baseVC;
    else baseVC = CURRENTVIEWCONTROLLER;
    if (self.baseView)
        baseView = self.baseView;
    else baseView = CURRENTVIEWCONTROLLER.view;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self showInVc:baseVC view:baseView animation:YES];
    }else {
        double delayInSeconds = 0.5f;   // 加延时等待 防止通过推送启动应用时无法加载
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showInVc:baseVC view:baseView animation:YES];
        });
    }
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    if (![self superview]) {
        [super showInVc:vc view:view animation:animation];
        
        _previousKeyboardDistance = [IQKeyHelper keyboardDistanceFromTextField];
        [view addSubview:self];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.boxView.frame, point)) {
        return;
    }
    
    if (_isTouchMarginCancel) {
        // 消失
        [self dismissWithVc:self.popVc animation:YES];
    }
}

- (IBAction)iknowClick:(UIButton *)sender {
    if (self.promptBoxStyle == G100PromptBoxStyleTextField) {
        // 输入框的回调 需要在回调里销毁自己
        if (_sureEvent) {
            self.sureEvent(self.textField.text);
        }
    }else {
        if (_sureEvent) {
            self.sureEvent();
        }
        
        [self dismissWithVc:self.popVc animation:YES];
    }
}

- (IBAction)cancelClick:(UIButton *)sender {
    if (_cancelEvent) {
        self.cancelEvent();
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

-(void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    if ([self superview]) {
        [super dismissWithVc:vc animation:animation];
        
        [IQKeyHelper setKeyboardDistanceFromTextField:_previousKeyboardDistance];
        [self removeFromSuperview];
    }
}

@end

@interface G100VerifyCodePromptBox ()

@property (nonatomic, weak) IBOutlet UILabel *topHintLabel;

@property (nonatomic, copy) NSString *sessionid;
@property (nonatomic, copy) NSString *picvcName;

@end

@implementation G100VerifyCodePromptBox : G100PromptBox

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.frame;
    
    self.boxView.layer.masksToBounds = YES;
    self.boxView.layer.cornerRadius  = 6.0f;
    
    [self.iknowButton setExclusiveTouch:YES];
    [self.cancelButton setExclusiveTouch:YES];
    
    self.iknowButton.layer.masksToBounds = YES;
    self.iknowButton.layer.cornerRadius = 5.0f;
    
    self.cancelButton.layer.masksToBounds = YES;
    self.cancelButton.layer.cornerRadius = 5.0f;
    
    [self.cancelButton setBackgroundImage:CreateImageWithColor(RGBColor(253, 149, 38, 1.0)) forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:CreateImageWithColor(RGBColor(238, 140, 35, 1.0)) forState:UIControlStateHighlighted];
    
    [self.iknowButton setBackgroundImage:CreateImageWithColor(RGBColor(40, 176, 29, 1.0)) forState:UIControlStateNormal];
    [self.iknowButton setBackgroundImage:CreateImageWithColor(RGBColor(37, 163, 26, 1.0)) forState:UIControlStateHighlighted];
}

+ (instancetype)promptVerifyCodeBoxSureOrCancelAlertView {
    G100VerifyCodePromptBox * box = [[[NSBundle mainBundle]loadNibNamed:@"G100VerifyCodePromptBox" owner:self options:nil]firstObject];
    box.promptBoxStyle = G100PromptBoxStyleVerifyCode;
    return box;
}

- (void)showVerifyCodeBoxWithHint:(NSString *)hintLabel sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    self.sureEvent = sureEvent;
    self.cancelEvent = cancelEvent;
    
    self.topHintLabel.numberOfLines = 0;
    self.topHintLabel.text = @"请输入下方图形验证码";
    
    __weak G100VerifyCodePromptBox *wself = self;
    self.verifyCodeView.refreshVeriCodeBlock = ^(NSString * sessionid, NSString * picvcName){
        wself.sessionid = sessionid;
        wself.picvcName = picvcName;
    };
    
    [self.verifyCodeView setDisplayStyle:DisplayStyleWithBorder];
    [self.verifyCodeView setUsageType:self.verificationCodeUsage
                             picvcurl:self.picvcurl];
    
    [IQKeyHelper setKeyboardDistanceFromTextField:108];
    [self showInVc:viewController view:baseView animation:YES];
}

- (IBAction)iknowClick:(UIButton *)sender {
    if (self.promptBoxStyle == G100PromptBoxStyleVerifyCode) {
        // 先判断验证码输入框内容不能为空
        if ([self.verifyCodeView.verCodeTF.text trim].length == 0) {
            [self.popVc showHint:@"请输入验证码"];
            return;
        }
        if ([self.sessionid trim].length == 0) {
            [self.popVc showHint:@"获取验证码失败，请手动刷新重试"];
            return;
        }
        
        [self.verifyCodeView.verCodeTF resignFirstResponder];
        
        // 图形验证码校验的回调 需要在回调里销毁自己
        if (self.sureEvent) {
            NSString * newPicvc = [NSString stringWithFormat:@"%@|%@", self.picvcName, self.verifyCodeView.verCodeTF.text];
            self.sureEvent(newPicvc, self.sessionid);
        }
    }else {
        if (self.sureEvent) {
            self.sureEvent();
        }
        
        [self dismissWithVc:self.popVc animation:YES];
    }
}

@end
