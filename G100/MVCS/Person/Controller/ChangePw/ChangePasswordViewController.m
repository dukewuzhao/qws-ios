//
//  ChangePasswordViewController.m
//  G100
//
//  Created by Tilink on 15/4/3.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "G100ForgetPwViewController.h"
#import "G100UserApi.h"
#import "G100Mediator+Login.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTF;
@property (weak, nonatomic) IBOutlet UIButton *findPasswordBtn;

@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (copy, nonatomic) NSString * oldPw;
@property (copy, nonatomic) NSString * pw;
@property (copy, nonatomic) NSString * pwAgain;

@end

@implementation ChangePasswordViewController

-(void)dealloc {
    DLog(@"修改密码页面已释放");
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.sureBtn setExclusiveTouch:YES];
    [self.sureBtn setBackgroundImage:[[UIImage imageNamed:@"ic_location_sure_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    
    [self.cancelBtn setExclusiveTouch:YES];
    [self.cancelBtn setBackgroundImage:[[UIImage imageNamed:@"ic_location_cancel_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

#pragma mark - setupView
-(void)configView {
    self.oldPasswordTF.layer.cornerRadius = 6.0f;
    self.passwordTF.layer.cornerRadius = 6.0f;
    self.passwordAgainTF.layer.cornerRadius = 6.0f;
    
    UIImageView * userleft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    userleft.v_size = CGSizeMake(8, _oldPasswordTF.v_height);
    [_oldPasswordTF setLeftView:userleft];
    _oldPasswordTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView * userleft1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    userleft1.v_size = CGSizeMake(8, _oldPasswordTF.v_height);
    [_passwordAgainTF setLeftView:userleft1];
    _passwordAgainTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView * userleft2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    userleft2.v_size = CGSizeMake(8, _oldPasswordTF.v_height);
    [_passwordTF setLeftView:userleft2];
    _passwordTF.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""]) {
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > 16) {
        return NO;
    }
    if (textField == self.oldPasswordTF) {
        self.oldPw = toBeString;
    }
    if (textField == self.passwordTF) {
        self.pw = toBeString;
    }
    if (textField == self.passwordAgainTF) {
        self.pwAgain = toBeString;
    }
    
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.oldPasswordTF) {
        self.oldPw = textField.text;
    }
    if (textField == self.passwordTF) {
        self.pw = textField.text;
    }
    if (textField == self.passwordAgainTF) {
        self.pwAgain = textField.text;
    }
    
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.oldPasswordTF) {
        self.oldPw = textField.text;
    }
    if (textField == self.passwordTF) {
        self.pw = textField.text;
    }
    if (textField == self.passwordAgainTF) {
        self.pwAgain = textField.text;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_oldPasswordTF isFirstResponder]) {
        [_passwordTF becomeFirstResponder];
    }else if ([_passwordTF isFirstResponder]) {
        [_passwordAgainTF becomeFirstResponder];
    }else if ([_passwordAgainTF isFirstResponder]) {
        [_passwordAgainTF resignFirstResponder];
        [self btnEvent:self.sureBtn];
    }
    
    return YES;
}

#pragma mark - Private Method
- (IBAction)findPasswordEvent:(UIButton *)sender {
    G100ForgetPwViewController * forget = [[G100ForgetPwViewController alloc]initWithNibName:@"G100ForgetPwViewController" bundle:nil];
    forget.findStyle = LoginFindPassword;
    
    [self.navigationController pushViewController:forget animated:YES];
}

- (IBAction)btnEvent:(UIButton *)sender {
    if (sender.tag == 101) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        _oldPw = _oldPasswordTF.text;
        _pw = _passwordTF.text;
        _pwAgain = _passwordAgainTF.text;
        
        if ([NSString checkPassword:@"原密码" password:_oldPw]) {
            [self showWarningHint:[NSString checkPassword:@"原密码" password:_oldPw]];
            return;
        }
        if ([NSString checkPassword:@"新密码" password:_pw]) {
            [self showWarningHint:[NSString checkPassword:@"新密码" password:_pw]];
            return;
        }
        if ([NSString checkPassword:@"确认密码" password:_pwAgain]) {
            [self showWarningHint:[NSString checkPassword:@"确认密码" password:_pwAgain]];
            return;
        }
        if ([_oldPw isEqualToString:_pw]) {
            [self showWarningHint:@"新密码不能与原密码一致"];
            return;
        }
        
        if (![_pw isEqualToString:_pwAgain]) {
            [self showWarningHint:@"两次密码输入不一致"];
            return;
        }
        
        if (kNetworkNotReachability) {
            [self showHint:kError_Network_NotReachable];
            return;
        }
        
        [self realChangePassword];
    }
}

-(void)realChangePassword {
    __weak ChangePasswordViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 更新密码
            [self showHint:@"您已经修改密码，请重新验证登录"];
            [[UserManager shareManager] logoff];
            double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               // [AppDelegate setRootViewController:APPDELEGATE.loginNavc fromController:self isLogin:NO];
                [[UserManager shareManager] logoff];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }];
            });
        }else {
            if (response) {
                if (response.errCode == 29) {
                    [wself showWarningHint:@"原密码错误"];
                }else {
                    [wself showHint:response.errDesc];
                }
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_modifyUserPasswordWithCurrpwd:PWENCRYPT(self.oldPw) newpwd:PWENCRYPT(self.pw) callback:callback];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavigationTitle:@"修改密码"];
    self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight + 20;
    [self configView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
