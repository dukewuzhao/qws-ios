
#import "UIViewController+HUD.h"
#import <objc/runtime.h>

static const void *HttpRequestHUDKey = &HttpRequestHUDKey;
static const void *HttpRequestHintHudKey = &HttpRequestHintHudKey;

static const void *ToastShowTypeKey = &ToastShowTypeKey;
static const void *ToastShowHintKey = &ToastShowHintKey;

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/*
- (MBProgressHUD *)hintHud{
    return objc_getAssociatedObject(self, HttpRequestHintHudKey);
}

- (void)setHintHud:(MBProgressHUD *)hintHud{
    objc_setAssociatedObject(self, HttpRequestHintHudKey, hintHud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
*/

- (void)setType:(ToastShowType)type {
    objc_setAssociatedObject(self, ToastShowTypeKey, @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ToastShowType)type {
    NSNumber * typeValue = objc_getAssociatedObject(self, ToastShowTypeKey);
    return typeValue.integerValue;
}

- (G100ToastView *)toast {
    return objc_getAssociatedObject(self, ToastShowHintKey);
}

- (void)setToast:(G100ToastView *)toast {
    objc_setAssociatedObject(self, ToastShowHintKey, toast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint detailHint:(NSString *)detailHint {
    [self showHudInView:view hint:hint detailHint:detailHint completionBlock:nil];
}

- (void)showProgressHudInView:(UIView *)view hint:(NSString *)hint {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.color = [UIColor colorWithRed:62.0f / 255.0f green:58.0f / 255.0f blue:57.0f / 255.0f alpha:0.75f];
    HUD.labelText = hint;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)setProgress:(float)progress {
    [self HUD].progress = progress;
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    [self showHudInView:view hint:hint detailHint:nil];
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint completionBlock:(MBProgressHUDCompletionBlock)completion {
    [self showHudInView:view hint:hint detailHint:nil completionBlock:completion];
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint detailHint:(NSString *)detailHint completionBlock:(MBProgressHUDCompletionBlock)completion {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.completionBlock = completion;
    HUD.color = [UIColor colorWithRed:62.0f / 255.0f green:58.0f / 255.0f blue:57.0f / 255.0f alpha:0.75f];
    HUD.labelText = hint;
    HUD.detailsLabelText = detailHint;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint afterHide:(CGFloat)delay {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.color = [UIColor colorWithRed:62.0f / 255.0f green:58.0f / 255.0f blue:57.0f / 255.0f alpha:0.75f];
    HUD.labelText = hint;
    [view addSubview:HUD];
    [HUD hide:YES afterDelay:delay];
    
    [self setHUD:HUD];
}

- (void)showWarningHint:(NSString *)hint {
    [self showWarningHint:hint inView:self.view];
}

- (void)showHint:(NSString *)hint {
    [self showHint:hint inView:self.view];
}

- (void)showHint:(NSString *)hint inView:(UIView *)view {
    if (!hint) {
        return;
    }
    if (hint.length == 0) {
        return;
    }
    if ([self toast]) {
        //[self hideHintHud];
        [self hideToast];
    }
    
    //显示提示信息
    G100ToastView * toast = [G100ToastView showToastAddedTo:view];
    toast.userInteractionEnabled = NO;
    toast.labelText = hint;
    toast.type = ToastShowTypeNotification;
    
    CGFloat yOffset = toast.yOffset;
    BOOL isKeyboardVisible = [IQKeyHelper keyboardIsVisible];
    if (isKeyboardVisible) {
        yOffset = yOffset + [IQKeyHelper keyboardSize].height;
    }
    
    toast.yOffset = yOffset;
    
    [toast hideDelay];
    
    [self setToast:toast];
    
    /*
     MBProgressHUD *hintHud = [MBProgressHUD showHUDAddedTo:view animated:YES];
     hintHud.color = [UIColor colorWithRed:62.0f / 255.0f green:58.0f / 255.0f blue:57.0f / 255.0f alpha:0.75f];
     hintHud.userInteractionEnabled = NO;
     // Configure for text only and offset down
     hintHud.mode = MBProgressHUDModeText;
     hintHud.labelText = hint;
     hintHud.margin = 8.f;
     hintHud.cornerRadius = 3.f;
     
     CGFloat yOffset = view.frame.size.height / 2.0 - 80;
     BOOL isKeyboardVisible = [IQKeyHelper keyboardIsVisible];
     if (isKeyboardVisible) {
     yOffset = view.frame.size.height / 2.0 - [IQKeyHelper keyboardSize].height - 80;
     }
     
     hintHud.yOffset = yOffset;
     hintHud.removeFromSuperViewOnHide = YES;
     [hintHud hide:YES afterDelay:3];
     
     [self setHintHud:hintHud];
     */
}

- (void)showWarningHint:(NSString *)hint inView:(UIView *)view {
    if (!hint) {
        return;
    }
    if (hint.length == 0) {
        return;
    }
    if ([self toast]) {
        [self hideToast];
    }
    
    G100ToastView * toast = [G100ToastView showToastAddedTo:view];
    toast.userInteractionEnabled = NO;
    toast.labelText = hint;
    toast.type = ToastShowTypeWarning;
    
    CGFloat yOffset = toast.yOffset;
    BOOL isKeyboardVisible = [IQKeyHelper keyboardIsVisible];
    if (isKeyboardVisible) {
        yOffset = yOffset + [IQKeyHelper keyboardSize].height;
    }
    
    toast.yOffset = yOffset;
    
    [toast hideDelay];
    
    [self setToast:toast];
}

- (void)hideHud {
    [[self HUD] hide:YES];
}

- (void)hideToast {
    [[self toast] hideNow];
}

/*
- (void)hideHintHud {
    [[self hintHud] hide:YES];
}
*/

+ (UIViewController *)viewController:(UIView *)view {
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = view;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    // If the view controller isn't found, return nil.
    return nil;
}

- (UIViewController *)topParentViewController {
    UIViewController *viewController = self;
    while ([viewController parentViewController]) {
        if ([[viewController parentViewController] isKindOfClass:[UINavigationController class]]) {
            break;
        }
        
        viewController = viewController.parentViewController;
    }
    return viewController;
}

@end
