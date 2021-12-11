//
//  G100PopingView.h
//  G100
//
//  Created by William on 16/8/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100PromptBox.h"
#import "G100PopBoxBaseView.h"

@class G100ImageTextPopingView;
@class G100OptionsPopingView;
@class G100ReactivePopingView;
@class G100ConfirmView;
@class G100TextEnterPopingView;
@class G100HomeSetPopingView;
typedef void (^ClickEventBlock)(NSInteger index);
typedef void (^ClickRichTextlBlock) (NSInteger index);
typedef void (^ClickSureBlock)();

typedef NS_ENUM(NSInteger, ClickNoticeType) {
    ClickEventBlockCancel,
    ClickEventBlockDefine
};

typedef NS_ENUM(NSInteger, ConfirmClickType) {
    ConfirmClickTypeSingle,
    ConfirmClickTypeDouble
};

typedef enum : NSUInteger {
    PopContentAlignmentLeft = 0,
    PopContentAlignmentCenter = 1,
    PopContentAlignmentRight = 2,
} PopContentAlignment;

@interface G100PopingView : G100PopBoxBaseView

@property (strong, nonatomic) IBOutlet UIView *popingView;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *confirmView;

@property (copy, nonatomic) ClickEventBlock clickEvent;
@property (assign, nonatomic) ClickNoticeType noticeType;
@property (assign, nonatomic) ConfirmClickType confirmClickType;
@property (assign, nonatomic) BOOL controlHidden;
@property (assign, nonatomic) BOOL backgorundTouchEnable;
@property (strong, nonatomic) G100ConfirmView * confirmClickView;

@property (strong, nonatomic) NSString * otherButtonTitle;
@property (strong, nonatomic) NSString * confirmButtonTitle;

@property (assign, nonatomic) PopContentAlignment contentAlignment;

@end



/** 图文类弹框 */
@interface G100ImageTextPopingView : G100PopingView

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

+ (instancetype)popingViewWithImageTextView;

- (void)showPopingViewWithTitle:(NSString *)title image:(UIImage *)image content:(NSString *)content noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end

/** 设置家弹框 */
@interface G100HomeSetPopingView : G100PopingView
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *topContent;
@property (weak, nonatomic) IBOutlet UILabel *bottomContent;
@property (weak, nonatomic) IBOutlet UIButton *sureTitle;
@property (copy, nonatomic) ClickSureBlock sureBlock;
+ (instancetype)popingViewWithHomeSetView;

- (void)showPopingViewWithImage:(UIImage *)image topContent:(NSString *)topContent bottomContent:(NSString *)bottomContent confirmTitle:(NSString *)confirmTitle otherTitle:(NSString *)otherTitle clickEvent:(ClickSureBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end

typedef NS_ENUM(NSInteger, OptionsMode) {
    OptionsModeSingle,
    OptionsModeMultiple
};

/** 选项类弹框 */
@interface G100OptionsPopingView : G100PopingView

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray * selectedArray;

@property (assign, nonatomic) OptionsMode optionsMode;

+ (instancetype)popingViewWithOptionsView;

- (void)showPopingViewWithTitle:(NSString *)title options:(NSArray *)options noticeType:(ClickNoticeType)noticeType optionsMode:(OptionsMode)optionsMode otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end



/** 用户响应式弹框 */
@interface G100ReactivePopingView : G100PopingView

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;

+ (instancetype)popingViewWithReactiveView;
+ (instancetype)popingViewWithHintReactiveView;

- (void)showPopingViewWithTitle:(NSString *)title content:(NSString *)content noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

/** 富文本弹框 */
@property (strong, nonatomic) YYLabel *promptLabel;
@property (nonatomic, strong) UIFont  *fontOfContent;
@property (nonatomic, strong) UIFont  *fontOfRichTextContent;
@property (nonatomic, strong) UIColor *colorOfRichText;

/**
 设置弹框底部的按钮颜色 hexString

 @param cofirmColor 确认按钮颜色
 @param otherColor 其他按钮颜色
 */
- (void)configConfirmViewTitleColorWithConfirmColor:(NSString *)cofirmColor otherColor:(NSString *)otherColor;

/**
 显示含有一个富文本弹框

 @param title 标题
 @param content 文本
 @param richText 富文本内容(需在文本中包含)
 @param noticeType 弹框类型
 @param otherTitle 其他按钮
 @param confirmTitle 确认按钮
 @param clickEvent 点击确认和其他按钮触发事件
 @param ClickRichTextlBlock 点击富文本触发事件
 @param viewController 需要承接的VC
 @param baseView 需要承接的view
 */
- (void)showRichTextPopingViewWithTitle:(NSString *)title content:(NSString *)content  richText:(NSString *)richText noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent ClickRichTextlBlock:(ClickRichTextlBlock)ClickRichTextlBlock onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

/**
 显示含有多个富文本的弹框

 @param title 标题
 @param content 文本
 @param richTextArr 富文本数组(根据顺序填入)
 @param noticeType 弹框类型
 @param otherTitle 其他按钮
 @param confirmTitle 确认按钮
 @param clickEvent 点击确认和其他按钮触发事件
 @param ClickRichTextlBlock 点击富文本触发事件(回调回的index 与传入的富文本数组顺序相对应)
 @param viewController 需要承接的VC
 @param baseView 需要承接的view
 */
- (void)showMultiRichTextPopingViewWithTitle:(NSString *)title content:(NSString *)content richTextArr:(NSArray *)richTextArr noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent ClickRichTextlBlock:(ClickRichTextlBlock)ClickRichTextlBlock onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;
@end



/** 验证码弹框 */
typedef void (^RefreshVeriCodeBlock)(NSString * sessionid, NSString * picvcName);

@class PictureCaptcha;
@interface G100VerificationPopingView : G100PopingView

@property (strong, nonatomic) IBOutlet UITextField *veriTextfield;
@property (strong, nonatomic) IBOutlet UIImageView *veriImageView;
@property (strong, nonatomic) NSString *picvcurl;

@property (nonatomic, copy) NSString *sessionid;
@property (nonatomic, copy) NSString *picvcName;
@property (copy, nonatomic) NSString *picID;

@property (strong, nonatomic) IBOutlet UIButton *refreshBtn;

@property (assign, nonatomic) G100VerificationCodeUsage usageType;

@property (copy, nonatomic) RefreshVeriCodeBlock refreshVeriCodeBlock;

@property (strong, nonatomic)  PictureCaptcha *pictureCap;

+ (instancetype)popingViewWithVerificationView;

- (void)showPopingViewWithUsageType:(G100VerificationCodeUsage)usageType clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

- (void)refreshVeriCode;

@end



/** EnterText弹框 */
@interface G100TextEnterPopingView : G100PopingView<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *enterTextfield;
@property (weak, nonatomic) IBOutlet UIScrollView *baseScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popBottomConstraint;

@property (assign, nonatomic) NSInteger max_count; //!< 最多允许输入的字符个数
@property (assign, nonatomic) NSString *max_hint; //!< 超过最大字符的提示

+ (instancetype)popingViewWithTextEnterView;

- (void)showPopingViewWithclickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;
@end

typedef enum : NSUInteger {
    G100StatusPopingViewLevelOk = 1,
    G100StatusPopingViewLevelWarn,
    G100StatusPopingViewLevelError
} G100StatusPopingViewLevel;

/** 文案左侧带有提示图片*/
@interface G100StatusPopingView : G100PopingView

+ (instancetype)popingViewWithStatusView;

@property (strong, nonatomic) IBOutlet UIImageView *hintImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

/// 显示状态弹框等级
@property (assign, nonatomic) G100StatusPopingViewLevel statueLevel;

/**
 显示状态弹框

 @param message 状态消息
 @param confirmTitle 确认按钮
 @param clickEvent 确认事件
 @param viewController 显示的控制器
 @param baseView 显示的父视图
 */
- (void)showPopingViewWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end

