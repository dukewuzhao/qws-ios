//
//  G100ForgetPwViewController.m
//  G100
//
//  Created by Tilink on 15/4/26.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100ForgetPwViewController.h"
#import "G100SetPasswordViewController.h"

#import "G100UserApi.h"
#import "PictureCaptcha.h"

@interface G100ForgetPwViewController () <UITextFieldDelegate> {
    dispatch_queue_t queue;
    dispatch_source_t _timer;
};

@property (strong, nonatomic) G100VerificationPopingView *verPopingView;
@property (assign, nonatomic) BOOL isWating;

@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UIView *voiceSendView;
@property (weak, nonatomic) IBOutlet UILabel *voiceCountdownLabel;

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *verityTF;

@property (weak, nonatomic) IBOutlet UIButton *getVerityBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *getVoiceVerityBtn;

@end

@implementation G100ForgetPwViewController

- (void)dealloc {
    DLog(@"找回密码页面已释放");
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField == _phoneTF) {
        if (toBeString.length > 11) {
            return NO;
        }
    } else if (textField == _verityTF) {
        if (toBeString.length > 4) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 点击事件
- (IBAction)getSmsVerityCode:(UIButton *)sender {
    NSString * phoneNum = [_phoneTF.text trim];
    
    if (![self checkPhone:phoneNum]) {
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak typeof(self) wself = self;
    [self queryThePhoneNumberisRegister:phoneNum showHud:NO callback:^(BOOL isOk){
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (requestSuccess) {
                // 短信验证码发送成功
                [wself waitForTestWord];
            } else if ([response needPicvcVerified]) {
                if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                    [wself showHint:response.errDesc];
                }
                
                [wself endTime];
                
                // 需要显示图形验证码
                wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
                [wself.verPopingView showPopingViewWithUsageType:G100VerificationCodeUsageToRegister clickEvent:^(NSInteger index) {
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
                                                 @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToRegister]
                                                 };
                        [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:phoneNum PictureCaptcha:picCap callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            [wself hideHud];
                            
                            if (requestSuccess) {
                                if ([wself.verPopingView superview]) {
                                    [wself.verPopingView dismissWithVc:wself animation:YES];
                                }
                                
                                // 图像验证码验证成功后的操作
                                [wself waitForTestWord];
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
        };
        
        NSDictionary *picCap = @{
                                 @"url" : @"",
                                 @"id" : @"",
                                 @"input" : @"",
                                 @"session_id" : @"",
                                 @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToRegister]
                                 };
        
        [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:phoneNum PictureCaptcha:picCap callback:callback];
    }];
}

- (IBAction)getVoiceVerityCode:(UIButton *)sender {
    NSString * phoneNum = [_phoneTF.text trim];
    
    if (![self checkPhone:phoneNum]) {
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak typeof(self) wself = self;
    [self queryThePhoneNumberisRegister:phoneNum showHud:NO callback:^(BOOL isOk){
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                [wself waitForTestWord];
                wself.voiceSendView.hidden = YES;
                wself.voiceCountdownLabel.hidden = NO;
                wself.voiceCountdownLabel.text = @"电话拨打中，请留意接听";
            } else {
                if (response) {
                    [self showHint:response.errDesc];
                }
            }
        };
        
        [[G100UserApi sharedInstance] sv_requestVoiVerificationWithMobile:phoneNum PictureCaptcha:@{} callback:callback];
    }];
}

- (IBAction)btnEvent:(UIButton *)sender {
    NSString *phoneNum = [_phoneTF.text trim];
    NSString *testword = [_verityTF.text trim];
    
    if (![self checkPhone:phoneNum]) {
        return;
    }
    
    if (![self checkVerityCode:testword]) {
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak G100ForgetPwViewController *wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (requestSucces) {
            // 验证成功 跳转到重置密码页面
            G100SetPasswordViewController *setPwVC = [G100SetPasswordViewController loadXibVc];
            setPwVC.testVC = testword;
            setPwVC.phoneNum = phoneNum;
            setPwVC.findStyle = (SetPasswordStyle)wself.findStyle;
            [wself.navigationController pushViewController:setPwVC animated:YES];
        }else {
            [wself hideHud];
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_checkVerificationCodeWithMobile:phoneNum vcode:testword callback:callback];
}

#pragma mark - 判断手机号是否注册
- (void)queryThePhoneNumberisRegister:(NSString *)phoneNum showHud:(BOOL)showHud callback:(void (^)(BOOL isSuccess))scallback {
    __weak G100ForgetPwViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        [wself hideHud];
        if (response && response.errCode == 0) {
            [wself showHint:@"您输入的手机号码没有注册过"];
        }else if (response && response.errCode == 2) {
            if (scallback) {
                scallback(YES);
            }
        }else {
            [wself showHint:response.errDesc];
        }
    };
    
    [[G100UserApi sharedInstance] sv_checkPhoneNumberisRegisterWithMobile:phoneNum callback:callback];
}

#pragma mark - Private Method
- (BOOL)checkPhone:(NSString *)phoneNum {
    if ([NSString checkPhoneNum:phoneNum]) {
        [self showHint:[NSString checkPhoneNum:phoneNum]];
        return NO;
    }
    
    if (_findStyle == NOLoginFindPasswprd) {
        
    }else if (_findStyle == LoginFindPassword) {
        // 应用内需要填写当前登录的手机号
        if ([phoneNum isEqualToString:[CurrentUser sharedInfo].phonenum]) {
            
        }else {
            [self showHint:@"请输入当前登录的手机号"];
            return NO;
        }
    }
    return YES;
}

- (BOOL)checkVerityCode:(NSString *)verityCode {
    if ([NSString checkVC:verityCode]) {
        [self showHint:[NSString checkVC:verityCode]];
        return NO;
    }
    
    return YES;
}
     
#pragma mark - 等待验证码
- (void)waitForTestWord {
    self.isWating = YES;
    
    __weak typeof(self) wself = self;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    __block int timeout = G100VCodeDuration;
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.isWating = NO;
                wself.waitLabel.hidden = YES;
                wself.getVerityBtn.enabled = YES;
                wself.voiceSendView.hidden = NO;
                wself.voiceCountdownLabel.hidden = YES;
                [wself.getVerityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                wself.voiceCountdownLabel.text = @"收不到验证码？";
            });
        }else{
            NSString *strTime = [NSString stringWithFormat:@"%.d 秒", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.waitLabel.hidden = NO;
                wself.getVerityBtn.enabled = NO;
                wself.waitLabel.text = strTime;
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)endTime {
    if (_timer) {
        __weak typeof(self) wself = self;
        dispatch_source_cancel(_timer);
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.isWating = NO;
            wself.waitLabel.hidden = YES;
            wself.getVerityBtn.enabled = YES;
            wself.voiceSendView.hidden = NO;
            wself.voiceCountdownLabel.hidden = YES;
            [wself.getVerityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        });
    }
}

- (G100VerificationPopingView *)verPopingView
{
    if (!_verPopingView) {
        _verPopingView = [G100VerificationPopingView popingViewWithVerificationView];
        _verPopingView.usageType = G100VerificationCodeUsageToRegister;
    }
    return _verPopingView;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"找回密码"];
    
    self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight + 20;
    
    [self.sureBtn setExclusiveTouch:YES];
    [self.getVerityBtn setExclusiveTouch:YES];
    [self.getVoiceVerityBtn setExclusiveTouch:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
