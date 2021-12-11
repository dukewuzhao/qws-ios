//
//  RealChangePhoneNumViewController.m
//  G100
//
//  Created by Tilink on 15/4/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "RealChangePhoneNumViewController.h"
#import "G100UserApi.h"
#import "G100PromptBox.h"
#import "G100Mediator+Login.h"
#import "PictureCaptcha.h"

@interface RealChangePhoneNumViewController () <UITextFieldDelegate> {
    dispatch_queue_t queue;
    dispatch_source_t _timer;
};

@property (copy, nonatomic) NSString * phoneNum;
@property (copy, nonatomic) NSString * testWord;

@property (strong, nonatomic) G100VerifyCodePromptBox *verifyBox;
@property (strong, nonatomic) G100VerificationPopingView *verPopingView;
@property (weak, nonatomic) IBOutlet UILabel *voiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceButtonWidconstraint;

@end

@implementation RealChangePhoneNumViewController

- (void)configView {
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.warningLabel.hidden = YES;
    
    // 首先隐藏倒计时，发送的时候在显示
    self.timeLabel.hidden = YES;
    self.phoneTF.layer.cornerRadius = 6.0f;
    self.testTF.layer.cornerRadius = 6.0f;
    
    UIImageView * userleft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    userleft.v_size = CGSizeMake(8, _phoneTF.v_height);
    [_phoneTF setLeftView:userleft];
    _phoneTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView * userleft1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    userleft1.v_size = CGSizeMake(8, _testTF.v_height);
    [_testTF setLeftView:userleft1];
    _testTF.leftViewMode = UITextFieldViewModeAlways;
    
    self.sendTestBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.sendTestBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.sendTestBtn.layer.borderWidth = 0.8f;
    self.sendTestBtn.layer.cornerRadius = 6.0f;
}

#pragma mark - tfDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.warningLabel.hidden = YES;
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField == _phoneTF) {
        self.phoneNum = toBeString;
        if (toBeString.length > 11) {
            return NO;
        }
    }
    if (textField == _testTF) {
        self.testWord = toBeString;
        if (toBeString.length > 4) {
            return NO;
        }
    }

    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.warningLabel.hidden = YES;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.warningLabel.hidden = YES;
    if (textField == _phoneTF) {
        self.phoneNum = _phoneTF.text;
    }
    if (textField == _testTF) {
        self.testWord = _testTF.text;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_phoneTF isFirstResponder]) {
        [_testTF becomeFirstResponder];
    }else if ([_testTF isFirstResponder]) {
        [_testTF resignFirstResponder];
        [self btnEvent:self.sureBtn];
    }
    return YES;
}

- (IBAction)requestVoiceCode:(UIButton *)sender {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    if ([NSString checkPhoneNum:_phoneNum]) {
        [self showHint:[NSString checkPhoneNum:_phoneNum]];
        return;
    }
    
    __weak RealChangePhoneNumViewController * wself = self;
    [self queryThePhoneNumberisRegister:_phoneNum showHud:YES callback:^(BOOL isOk) {
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (requestSuccess) {
                [wself sendTestwordSuccess];
                wself.voiceLabel.text = @"电话拨打中，请留意接听";
                wself.voiceButtonWidconstraint.constant = 0;
            }else {
                if (response) {
                    [self showHint:response.errDesc];
                }
            }
        };
        
        [[G100UserApi sharedInstance] sv_requestVoiVerificationWithMobile:_phoneNum PictureCaptcha:nil callback:callback];
    }];
}


- (IBAction)sendTestEvent:(UIButton *)sender {
    self.phoneNum = _phoneTF.text;
    if ([NSString checkPhoneNum:@"新手机号" phone:_phoneNum]) {
        [self showHint:[NSString checkPhoneNum:@"新手机号" phone:_phoneNum]];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak RealChangePhoneNumViewController * wself = self;
    [self queryThePhoneNumberisRegister:_phoneNum showHud:YES callback:^(BOOL isOk){
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
            if (requestSucces) {
                if ([wself.verifyBox superview]) {
                    [wself.verifyBox dismissWithVc:wself animation:YES];
                }
                [self sendTestwordSuccess];
            }else {
                if (response) {
                    if ([response needPicvcVerified]) {
                        if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                            [wself showHint:response.errDesc];
                        }
                        
                        [wself.view endEditing:YES];
                        [wself endTime];
                        
                        wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
                       // NSDictionary *pic = [NSDictionary dictionaryWithDictionary:response.data[@"picture_captcha"]];
                        [wself.verPopingView showPopingViewWithUsageType:G100VerificationCodeUsageToChangePn clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                
                                if ([wself.verPopingView.veriTextfield.text trim].length == 0) {
                                    [wself showHint:@"请输入验证码"];
                                    return;
                                }
                                [wself.verPopingView.veriTextfield resignFirstResponder];
                                [wself showHudInView:wself.view hint:@"正在验证"];
                                NSDictionary *picCap = @{
                                                         @"url" : EMPTY_IF_NIL(wself.verPopingView.pictureCap.url),
                                                         @"id" : EMPTY_IF_NIL(wself.verPopingView.pictureCap.ID),
                                                         @"input" : EMPTY_IF_NIL(wself.verPopingView.veriTextfield.text),
                                                         @"session_id" : EMPTY_IF_NIL(wself.verPopingView.pictureCap.session_id),
                                                         @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToChangePn]
                                                         };
                                [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phoneNum PictureCaptcha:picCap callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                    [wself hideHud];
                                    
                                    if (requestSuccess) {
                                        if ([wself.verPopingView superview]) {
                                            [wself.verPopingView dismissWithVc:wself animation:YES];
                                        }
                                        // 图像验证码验证成功后的操作
                                        [wself sendTestwordSuccess];
                                    }else {
                                        [wself showHint:response.errDesc];
                                        if ([wself.verPopingView superview]) {
                                            [wself.verPopingView refreshVeriCode];
                                        }
                                    }
                                }];
                                
                            }else if (index == 1)
                            {
                                if ([wself.verPopingView superview]) {
                                    [wself.verPopingView dismissWithVc:wself animation:YES];
                                }
                            }
                            
                        } onViewController:self onBaseView:self.view];
                        
                        
                    }else {
                        [wself showHint:response.errDesc];
                    }
                }
                
                [wself endTime];
            }
        };
        
        NSDictionary *picCap = @{
                                 @"url" : @"",
                                 @"id" : @"",
                                 @"input" : @"",
                                 @"session_id" : @"",
                                 @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToChangePn]
                                 };
        [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phoneNum PictureCaptcha:picCap callback:callback];
    }];
}

#pragma mark - 判断手机号是否注册
- (void)queryThePhoneNumberisRegister:(NSString *)phoneNum showHud:(BOOL)showHud callback:(void (^)(BOOL isSuccess))scallback {
    __weak RealChangePhoneNumViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (requestSucces) {
            if (scallback) {
                scallback(YES);
            }
        }else {
            [wself hideHud];
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    [[G100UserApi sharedInstance] sv_checkPhoneNumberisRegisterWithMobile:phoneNum callback:callback];
}

#pragma mark - 验证码发送成功
- (void)sendTestwordSuccess {
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    //self.timeLabel.hidden = NO;
//    [self.sendTestBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self startTime];
}
- (void)startTime {
    __block int timeout = G100VCodeDuration; //倒计时时间
    __weak RealChangePhoneNumViewController * wself = self;
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                wself.timeLabel.hidden = YES;
                wself.sendTestBtn.enabled = YES;
                [wself.sendTestBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                [wself.sendTestBtn setTitleColor:[UIColor colorWithHexString:@"09A021"] forState:UIControlStateNormal];
                wself.voiceLabel.text = @"收不到验证码？试试";
                wself.voiceButtonWidconstraint.constant = 70;
                
            });
        }else {
            //            int minutes = timeout / 60;
            NSString *strTime = [NSString stringWithFormat:@"%.d 秒", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                wself.timeLabel.text = [NSString stringWithFormat:@"%@秒后", strTime];
                wself.timeLabel.hidden = YES;
                wself.sendTestBtn.enabled = NO;
                [wself.sendTestBtn setTitle:strTime forState:UIControlStateDisabled];
                [wself.sendTestBtn setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)endTime {
    if (_timer) {
        dispatch_source_cancel(_timer);
        __weak RealChangePhoneNumViewController * wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置界面的按钮显示 根据自己需求设置
            wself.timeLabel.text = @"";
            wself.sendTestBtn.enabled = YES;
            [wself.sendTestBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        });
    }
}

- (IBAction)btnEvent:(UIButton *)sender {
    if (sender.tag == 101) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        _phoneNum = _phoneTF.text;
        _testWord = _testTF.text;
        
        if ([NSString checkPhoneNum:@"新手机号" phone:_phoneNum]) {
            [self showHint:[NSString checkPhoneNum:@"新手机号" phone:_phoneNum]];
            return;
        }
        if ([NSString checkVC:_testWord]) {
            self.warningLabel.hidden = NO;
            [self showHint:[NSString checkVC:_testWord]];
            return;
        }
        if (kNetworkNotReachability) {
            [self showHint:kError_Network_NotReachable];
            return;
        }
        
        __weak RealChangePhoneNumViewController * wself = self;
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
            if (requestSucces) {
                // 验证成功
                [wself realChangePhoneNumber];
            }else {
                [wself hideHud];
                if (response) {
                    [wself showHint:response.errDesc];
                }
            }
            
        };
        [self showHudInView:self.substanceView hint:@"正在更换"];
        [[G100UserApi sharedInstance] sv_checkVerificationCodeWithMobile:_phoneNum vcode:_testWord callback:callback];
    }
}

#pragma mark - 更换手机号
- (void)realChangePhoneNumber {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak RealChangePhoneNumViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            // 保存用户名
            [UserManager shareManager].name = wself.phoneNum;
            [[UserManager shareManager] setToken:[response.data objectForKey:@"token"]];
            
            // 更新密码
            [self showHint:@"您已经更换手机，请重新验证登录"];
            [[UserManager shareManager] logoff];
            
            double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[UserManager shareManager] logoff];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }];
            });
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_modifyMobileNumberWithOldvc:self.oldTestword newpn:self.phoneNum newvc:self.testWord callback:callback];
}

#pragma mark - Lazzy Load
- (G100VerifyCodePromptBox *)verifyBox {
    if (!_verifyBox) {
        self.verifyBox = [G100VerifyCodePromptBox promptVerifyCodeBoxSureOrCancelAlertView];
        self.verifyBox.verificationCodeUsage = G100VerificationCodeUsageToChangePn;
    }
    return _verifyBox;
}

-(G100VerificationPopingView *)verPopingView {
    if (!_verPopingView) {
        _verPopingView = [G100VerificationPopingView popingViewWithVerificationView];
        _verPopingView.usageType = G100VerificationCodeUsageToRegister;
    }
    return _verPopingView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.sureBtn setExclusiveTouch:YES];
    [self.cancelBtn setExclusiveTouch:YES];
    
    [self.sureBtn setBackgroundImage:[[UIImage imageNamed:@"ic_location_sure_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundImage:[[UIImage imageNamed:@"ic_location_cancel_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"更换手机"];
    self.view.backgroundColor = MyBackColor;
    
    [self configView];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self endTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
