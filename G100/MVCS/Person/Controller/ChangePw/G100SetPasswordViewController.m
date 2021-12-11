//
//  G100SetPasswordViewController.m
//  G100
//
//  Created by Tilink on 15/4/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100SetPasswordViewController.h"
#import "G100UserApi.h"
#import "G100Mediator+Login.h"

@interface G100SetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTF;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (copy, nonatomic) NSString * password;
@property (copy, nonatomic) NSString * passwordAgain;

@end

@implementation G100SetPasswordViewController

+ (instancetype)loadXibVc {
    return [[G100SetPasswordViewController alloc] initWithNibName:@"G100SetPasswordViewController" bundle:nil];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"重置密码"];
    
    self.substanceView.v_top = kNavigationBarHeight + 20;
    self.substanceView.v_height = self.contentView.v_height - 20;
    
    [self.sureBtn setExclusiveTouch:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _passwordTF) {
        self.password = _passwordTF.text;
        return YES;
    }
    if (textField == _passwordAgainTF) {
        self.passwordAgain = _passwordAgainTF.text;
        return YES;
    }
    
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField == _passwordTF) {
        _password = toBeString;
        if (toBeString.length > 16) {
            return NO;
        }
    }
    if (textField == _passwordAgainTF) {
        _passwordAgain = toBeString;
        if (toBeString.length > 16) {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_passwordTF isFirstResponder]) {
        [_passwordAgainTF becomeFirstResponder];
    }else if ([_passwordAgainTF isFirstResponder]) {
        [_passwordAgainTF resignFirstResponder];
        [self btnEvent:self.sureBtn];
    }
    
    return YES;
}

#pragma mark - 重置密码
- (IBAction)btnEvent:(UIButton *)sender {
    _password = _passwordTF.text;
    _passwordAgain = _passwordAgainTF.text;
    if ([NSString checkPassword:@"新密码" password:_password]) {
        [self showHint:[NSString checkPassword:@"新密码" password:_password]];
        return;
    }
    if ([NSString checkPassword:@"确认密码" password:_passwordAgain]) {
        [self showHint:[NSString checkPassword:@"确认密码" password:_passwordAgain]];
        return;
    }
    if (![_password isEqualToString:_passwordAgain]) {
        [self showHint:@"请检查两次密码是否一致"];
        return;
    }
    
    __weak G100SetPasswordViewController * wself = self;
    if (_password.length && _passwordAgain.length && [_passwordAgain isEqualToString:_password]) {
        if (!kNetworkNotReachability) {
            API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
                [wself hideHud];
                if (requestSucces) {
                    // 保存token
                    [[UserManager shareManager] setPassword:_password];
                    [[UserManager shareManager] setToken:[response.data objectForKey:@"token"]];
                    
                    [wself finished];
                }else {
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            };
            
            [wself showHudInView:wself.substanceView hint:@"请稍候"];
            [[G100UserApi sharedInstance] sv_resetUserPasswordWithMobile:_phoneNum
                                                               vcode:_testVC
                                                              newpwd:PWENCRYPT(_password)
                                                            callback:callback];
        }else {
            [self showHint:kError_Network_NotReachable];
        }
    }
}

-(void)finished {
    if (_findStyle == LoginSetPassword) {
        // 登录后  找回密码
        [self showHint:@"密码找回成功，请重新登录"];
        [[UserManager shareManager] logoff];
        
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
            [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
        });
    }else if (_findStyle == NOLoginSetPasswprd) {
        // 登录前  忘记密码
        [self showHint:@"密码找回成功，请重新登录"];
        [[UserManager shareManager] logoff];
        
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
}

@end
