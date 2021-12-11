
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "G100ToastView.h"

@interface UIViewController (HUD)

@property (nonatomic, assign) ToastShowType type;

- (void)showProgressHudInView:(UIView *)view hint:(NSString *)hint;

- (void)showHudInView:(UIView *)view hint:(NSString *)hint;

- (void)showHudInView:(UIView *)view hint:(NSString *)hint detailHint:(NSString *)detailHint;

- (void)showHudInView:(UIView *)view hint:(NSString *)hint completionBlock:(MBProgressHUDCompletionBlock)completion;

- (void)showHudInView:(UIView *)view hint:(NSString *)hint detailHint:(NSString *)detailHint completionBlock:(MBProgressHUDCompletionBlock)completion;

- (void)hideHud;

- (void)showHint:(NSString *)hint;

- (void)showWarningHint:(NSString *)hint;

- (void)showHint:(NSString *)hint inView:(UIView *)view;

- (void)showWarningHint:(NSString *)hint inView:(UIView *)view;

- (void)showHudInView:(UIView *)view hint:(NSString *)hint afterHide:(CGFloat)delay;

+ (UIViewController *)viewController:(UIView *)view;

- (void)setProgress:(float)progress;

/**
 *  控制器的最顶端的父控制器
 *
 *  @return 父控制器
 */
- (UIViewController *)topParentViewController;

@end
