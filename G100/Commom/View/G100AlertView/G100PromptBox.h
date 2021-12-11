//
//  G100PromptBox.h
//  G100
//
//  Created by Tilink on 15/3/31.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"
#import "G100UserApi.h"
#import "G100VerificationCodeView.h"

typedef void(^SureEventBlock)();
typedef void(^CancelEventBlock)();

typedef enum : NSUInteger {
    G100PromptBoxStyleIknow = 0,
    G100PromptBoxStyleSureOrCancel,
    G100PromptBoxStyleTextField,
    G100PromptBoxStyleImageHint,
    G100PromptBoxStyleVerifyCode
} G100PromptBoxStyle;

@class YYLabel;
@interface G100PromptBox : G100PopBoxBaseView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UILabel *boxTitleLabel;
@property (weak, nonatomic) IBOutlet YYLabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *iknowButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageAspectConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *G500ImageAspectConstraint;

- (IBAction)iknowClick:(UIButton *)sender;
- (IBAction)cancelClick:(UIButton *)sender;

@property (copy, nonatomic) SureEventBlock sureEvent;
@property (copy, nonatomic) CancelEventBlock cancelEvent;
@property (assign, nonatomic) G100PromptBoxStyle promptBoxStyle;

@property (weak, nonatomic) UIViewController *baseVC; //!< 加载的vc
@property (weak, nonatomic) UIView *baseView; //!< 加载的view

/**
 *  是否触摸空白处消失
 */
@property (assign, nonatomic) BOOL isTouchMarginCancel;
/**
 *  内容是否居中显示
 */
@property (assign, nonatomic) BOOL isContentCenter;

/**
 *  Simple 我知道了 弹出框
 *
 *  @return 弹出框
 */
+ (instancetype)promptBoxIKnowAlertView;
/**
 *  附带确认取消双功能&一个输入框的弹出框
 *
 *  @return 弹出框
 */
+ (instancetype)promptBoxTextfieldAlertView;
/**
 *  附带确认取消双功能的弹出框
 *
 *  @return 弹出框
 */
+ (instancetype)promptBoxSureOrCancelAlertView;
/**
 *  附带确认取消双功能&图片提示的弹出框
 *
 *  @return 弹出框
 */
+ (instancetype)promptImageBoxSureOrCancelAlertView;

/**
 *  附带确认取消双功能&图片提示的弹出框
 *
 *  @param title     提示框标题
 *  @param prompt    提示框内容
 *  @param name      提示框图片名称|url
 *  @param sureTitle 提示框确认按钮标题
 *  @param sureEvent 确认操作回调
 */
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt imageName:(NSString*)name sureTitle:(NSString *)sureTitle sure:(SureEventBlock)sureEvent;
/**
 *  附带确认取消双功能的弹出框 （可自定义是否居中）
 *
 *  @param title       提示框标题
 *  @param prompt      提示框内容
 *  @param isCenter    内容是否居中
 *  @param sureEvent   确认操作回调
 *  @param cancelEvent 取消操作回调
 */
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt center:(BOOL)isCenter sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent;
/**
 *  附带确认取消双功能的弹出框 （最简单的自定义）
 *
 *  @param title     提示框标题
 *  @param prompt    提示框内容
 *  @param sureTitle 提示框确认按钮标题
 *  @param sureEvent 确认操作回调
 */
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt sureTitle:(NSString *)sureTitle sure:(SureEventBlock)sureEvent;
/**
 *  附带确认取消双功能的弹出框 （可自定义确认按钮title）
 *
 *  @param title       提示框标题
 *  @param prompt      提示框内容
 *  @param sureTitle   提示框确认按钮标题
 *  @param sureEvent   确认操作回调
 *  @param cancelEvent 取消操作回调
 */
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt sureTitle:(NSString *)sureTitle sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent;
/**
 *  附带确认取消双功能的弹出框 （全部都可自定义）
 *
 *  @param title       提示框标题
 *  @param prompt      提示框内容
 *  @param sureTitle   提示框确认按钮标题
 *  @param cancelTilte 提示框取消按钮标题
 *  @param sureEvent   确认操作回调
 *  @param cancelEvent 取消操作回调
 */
- (void)showBoxWith:(NSString *)title prompt:(NSString *)prompt sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTilte sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent;

/**
 *  内容为富文本的弹出框
 *
 *  @param title       提示框标题
 *  @param attriPrompt 提示框内容（富文本）
 *  @param sureTitle   提示框确认按钮标题
 *  @param cancelTilte 提示框取消按钮标题
 *  @param sureEvent   确认操作回调
 *  @param cancelEvent 取消操作回调
 */
- (void)showBoxWith:(NSString *)title attriPrompt:(NSMutableAttributedString *)attriPrompt sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTilte sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent;

@end

@interface G100VerifyCodePromptBox : G100PromptBox

@property (nonatomic, copy) NSString *picvcurl; //!< 图形验证码的url
@property (assign, nonatomic) G100VerificationCodeUsage verificationCodeUsage;
@property (nonatomic, weak) IBOutlet G100VerificationCodeView *verifyCodeView;

/**
 *  附带确认取消双功能&验证码校验的弹出框
 *
 *  @return 弹出框
 */
+ (instancetype)promptVerifyCodeBoxSureOrCancelAlertView;

/**
 *  附带确认取消双功能的弹出框 （验证图形验证码）
 *
 *  @param hintLabel        顶部的提示语
 *  @param sureEvent        确认操作回调
 *  @param cancelEvent      取消操作回调
 *  @param viewController   所在VC
 *  @param baseView         superView
 */
- (void)showVerifyCodeBoxWithHint:(NSString *)hintLabel sure:(SureEventBlock)sureEvent cancel:(CancelEventBlock)cancelEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end
