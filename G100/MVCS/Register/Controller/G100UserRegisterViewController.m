//
//  G100UserRegisterViewController.m
//  G100
//
//  Created by sunjingjing on 16/7/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserRegisterViewController.h"
#import "G100UserInfoViewController.h"
#import "G100Mediator+UserInfo.h"
#import "G100WebViewController.h"
#import "G100Mediator+Login.h"
#import "TLPushTransition.h"
#import "PictureCaptcha.h"
#import "G100LocationUploader.h"
//#import <UMAnalytics/MobClick.h>

@interface G100UserRegisterViewController ()<UITextFieldDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>
{
    dispatch_queue_t queue;
    dispatch_source_t _timer;
};

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *veryBarTF;
@property (weak, nonatomic) IBOutlet UITextField *loginPW;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *displayPW;
@property (weak, nonatomic) IBOutlet UIButton *verBarButton;
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UILabel *veryLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreeLabel;
@property (weak, nonatomic) IBOutlet UIButton *protocolLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UILabel *voiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *voiceTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceTimeWidConstraint;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceBuWidConstranit;

@property (copy, nonatomic) NSString * phoneNum;
@property (copy, nonatomic) NSString * testword;
@property (copy, nonatomic) NSString * password;

@property (assign, nonatomic) BOOL phoneIsExist;
@property (assign, nonatomic) BOOL isWating;
@property (assign, nonatomic) BOOL isLookAgreement;
@property (assign, nonatomic) BOOL isTaped;
@property (assign, nonatomic) BOOL isRegistered;
@property (strong, nonatomic) G100VerificationPopingView *verPopingView;

@property (strong, nonatomic) UIScrollView *topView;

@end

@implementation G100UserRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - 私有触发方法
- (IBAction)getVeryBar:(id)sender {
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    self.phoneNum = _phoneNumTF.text;
    // 先判断手机号是否合法
    if ([NSString checkPhoneNum:_phoneNum]) {
        [self showHint:[NSString checkPhoneNum:_phoneNum]];
        return;
    }
    
    [self.view endEditing:YES];
    
    __weak G100UserRegisterViewController * wself = self;
    if (_isThird) {
        // 如果是第三方   先判断手机号是否绑定过
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                [wself sendYanzhengMa:wself.phoneNum showHUD:NO];
            }else {
                [wself hideHud];
                if (response) {
                    if (response.errDesc) {
                        [wself showHint:response.errDesc];

                    }else
                    {
                        [wself showHint:@"该手机号已存在!"];
                    }
                }
            }
        };
        [[G100UserApi sharedInstance] sv_checkPhoneNumIsBindtWithpPartner:_partner pn:_phoneNum callback:callback];
    }else {
        [self sendYanzhengMa:_phoneNum showHUD:YES];
    }
}

#pragma mark - 判断手机号是否注册
-(void)queryThePhoneNumberisRegister:(NSString *)phoneNum showHud:(BOOL)showHud callback:(void (^)(BOOL isSuccess))scallback {
    __weak G100UserRegisterViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (requestSucces) {
            if (scallback) {
                scallback(YES);
            }
        }else {
            [wself hideHud];
            if (response) {
                if (response.errCode == 2) {
                    // 号码已注册
                    if (wself.isThird) {
                        wself.isRegistered = YES;
                        if (scallback) {
                            scallback(YES);
                        }
                    }else
                    {
                      [wself showHint:response.errDesc];
                    }
                    
                }else {
                    [wself showHint:response.errDesc];
                }
                
            }
        }
    };
    [[G100UserApi sharedInstance] sv_checkPhoneNumberisRegisterWithMobile:phoneNum callback:callback];
}

-(void)sendYanzhengMa:(NSString *)phoneNum showHUD:(BOOL)showHUD {
    __weak G100UserRegisterViewController * wself = self;
    [self queryThePhoneNumberisRegister:_phoneNum showHud:showHUD callback:^(BOOL isOk){
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                [wself waitForTestWord];
            }else {
                if (response) {
                    if ([response needPicvcVerified]) {
                        if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                            [wself showHint:response.errDesc];
                        }
                        
                        [wself endTime];
                        wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
                        //NSDictionary *pic = [NSDictionary dictionaryWithDictionary:response.data[@"picture_captcha"]];
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
                                [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phoneNum PictureCaptcha:picCap callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
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
                }
                
                [wself endTime];
            }
        };
        NSDictionary *picCap = @{
                                  @"url" : @"",
                                  @"id" : @"",
                                  @"input" : @"",
                                  @"session_id" : @"",
                                  @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToRegister]
                                  };
        [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:self.phoneNum PictureCaptcha:picCap callback:callback];
    }];
}

#pragma mark - 请求语音验证码

- (IBAction)requestVoiceVerify:(id)sender {
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    self.phoneNum = _phoneNumTF.text;
    // 先判断手机号是否合法
    if ([NSString checkPhoneNum:_phoneNum]) {
        [self showHint:[NSString checkPhoneNum:_phoneNum]];
        return;
    }
    
    __weak G100UserRegisterViewController * wself = self;
    [self queryThePhoneNumberisRegister:_phoneNum showHud:YES callback:^(BOOL isOk){
        if (isOk) {
            API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    wself.voiceBuWidConstranit.constant = 0;
                    wself.voiceLabel.text = @"电话拨打中，请留意接听";
                    [wself waitForTestWord];
                }else {
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            };
            
            [[G100UserApi sharedInstance] sv_requestVoiVerificationWithMobile:self.phoneNum PictureCaptcha:nil callback:callback];
        }
    }];
}

#pragma mark - 等待验证码
-(void)waitForTestWord {
    self.isWating = YES;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    __weak G100UserRegisterViewController * wself = self;
    __block int timeout = G100VCodeDuration; //倒计时时间
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                wself.isWating = NO;
                wself.verBarButton.enabled = YES;
                wself.waitLabel.hidden = YES;
                [wself.verBarButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                wself.voiceBuWidConstranit.constant = 70;
                wself.voiceLabel.text = @"收不到验证码？试试";
            });
        }else{
            NSString *strTime = [NSString stringWithFormat:@"%.d 秒", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                wself.verBarButton.enabled = NO;
                wself.waitLabel.hidden = NO;
                wself.waitLabel.text = strTime;
                [wself.verBarButton setTitle:strTime forState:UIControlStateDisabled];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

-(void)endTime {
    if (_timer) {
        __weak G100UserRegisterViewController * wself = self;
        dispatch_source_cancel(_timer);
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置界面的按钮显示 根据自己需求设置
            wself.isWating = NO;
            wself.verBarButton.enabled = YES;
            [wself.verBarButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            wself.voiceBuWidConstranit.constant = 70;
            wself.voiceLabel.text = @"收不到验证码？试试";
        });
    }
}

- (IBAction)tapUserProtocol:(id)sender {
    
    G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
    agreement.filename = @"regist_agreement.html";
    agreement.webTitle = @"用户使用协议";
    //self.agreeButton.selected = YES;
    [self.navigationController pushViewController:agreement animated:YES];
    
}
- (IBAction)tapToPrivicy:(id)sender {
    G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
    agreement.httpUrl = @"https://www.qiweishi.com/privacy_policy.html";
    agreement.webTitle = @"隐私政策";
    //self.agreeButton.selected = YES;
    [self.navigationController pushViewController:agreement animated:YES];
}

- (IBAction)registerUser:(id)sender {
    _phoneNum = _phoneNumTF.text;
    _testword = _veryBarTF.text;
    _password = _loginPW.text;
    
    if ([NSString checkPhoneNum:_phoneNum]) {
        [self showHint:[NSString checkPhoneNum:_phoneNum]];
        return;
    }
    if ([NSString checkVC:_testword]) {
        [self showHint:[NSString checkVC:_testword]];
        return;
    }
    if (!_loginPW.hidden && !self.isThird) {    // 三方登录注册的时候 不需要输入密码
        if ([NSString checkPassword:_password]) {
            [self showHint:[NSString checkPassword:_password]];
            return;
        }
    }
    
    if (!_agreeButton.selected) {
        [self showHint:@"请先认真阅读用户使用协议和隐私政策"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100UserRegisterViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (requestSucces) {
            // 验证成功
            [wself registersed];
            [self checkPrivacyVersion];

        }else {
            [wself hideHud];
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    if (!_isThird) {
        [self showHudInView:self.substanceView hint:@"注册帐号中"];
    }else {
        [self showHudInView:self.substanceView hint:@"绑定中"];
    }
    [[G100UserApi sharedInstance] sv_checkVerificationCodeWithMobile:_phoneNum vcode:_testword callback:callback];
}

-(void)checkPrivacyVersion{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    __weak typeof(self) wSelf = self;
    [sessionManager GET:@"https://www.qiweishi.com/data/qws_version.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *newV = [responseObject objectForKey:@"version"];
        if (newV.length){
            [[G100InfoHelper shareInstance] updatePrivacyWithUserid:wSelf.phoneNum version:newV];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"请求失败--%@",error);
    }];
}
- (IBAction)hadUserToLogin:(id)sender {
    UIViewController * viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForLogin:nil];
    [viewController setValue:self.loginResult forKey:@"loginResult"];
    viewController.transitioningDelegate = self;
    NSMutableArray * viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeAllObjects];
    [viewControllers addObject:viewController];
    self.navigationController.delegate = self;
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        
        TLPushTransition * flip = [TLPushTransition new];
        return flip;
    }
    return nil;
}

- (IBAction)changePWShow:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.isTaped = YES;
    }
    self.loginPW.secureTextEntry = !sender.selected;
    if (self.loginPW.isFirstResponder) {
        [self.loginPW resignFirstResponder];
        self.loginPW.font = [UIFont systemFontOfSize:17];
    }
}

- (IBAction)agreeButton:(UIButton *)sender {
    
    sender.selected = !sender.selected;
}

- (void)setupView
{
    if (self.isThird) {
        [self setNavigationTitle:@"手机绑定"];
        self.loginHeightConstraint.constant = 0;
        self.bgHeightConstraint.constant = 127;
        [self.registerButton setTitle:@"完成绑定" forState:UIControlStateNormal];
    }else
    {
        [self setNavigationTitle:@"注册新帐号"];
    }
    [self setNavigationBarViewColor:[UIColor blackColor]];
    self.verBarButton.layer.cornerRadius = 22.0f/3;
    self.waitLabel.layer.cornerRadius = 22.0f/3;
    self.waitLabel.clipsToBounds = YES;
    self.registerButton.layer.cornerRadius = 22.0f/3;
    self.loginPW.adjustsFontSizeToFitWidth = YES;
    self.topView = (UIScrollView *)self.substanceView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField == _phoneNumTF) {
        if (toBeString.length > 11) {
            return NO;
        }
    }
    if (textField == _veryBarTF) {
        if (toBeString.length > 4) {
            return NO;
        }
    }
    if (textField == _loginPW) {
        if (toBeString.length > 16) {
            return NO;
        }
        
    }
    
    if(textField.secureTextEntry && self.isTaped) {
        
        textField.text = toBeString;
        return NO;
    }

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_phoneNumTF isFirstResponder]) {
        [_veryBarTF becomeFirstResponder];
    }else if ([_veryBarTF isFirstResponder]) {
        
            [_loginPW becomeFirstResponder];

    }else if ([_loginPW isFirstResponder]) {
        [_loginPW resignFirstResponder];
        [self registerUser:_registerButton];
    }
    
    return YES;
}



-(void)registersed {
    if (kNetworkNotReachability) {
        [self hideHud];
        [self showHint:@"网络无连接"];
        return;
    }
    
    // 注册用户
    __weak G100UserRegisterViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        [wself hideHud];
        if (requestSucces) {
            // 注册成功
            [wself autoLoginWithName:wself.phoneNum password:wself.password];

        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
   
    if (_isThird) { //判断是否是第三方帐号注册
       
        [[G100UserApi sharedInstance] sv_registerUserWithMobile:_phoneNum password:PWENCRYPT(_password) vcode:_testword partner:_partner partneraccount:_partneraccount partneraccounttoken:_partneraccounttoken partneruseruid:_partneruseruid callback:callback];
    }else {
         [[G100UserApi sharedInstance] sv_registerUserWithMobile:_phoneNum password:PWENCRYPT(_password) vcode:_testword partner:nil partneraccount:nil partneraccounttoken:nil partneruseruid:nil callback:callback];

    }
}

-(void)autoLoginWithName:(NSString *)name password:(NSString *)password {
    
    __weak G100UserRegisterViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger status, ApiResponse *response, BOOL success){
        if (response.success) {
            NSDictionary *bizDict = response.data;
            [wself loginSuccess:bizDict];
            //[MobClick event:@"login"];
        }else {
            if (response) {
                // 不是三方登录可能会遇到要求输入验证码的情况 单独处理
                if (!_isThird) {
                    if ([response needPicvcVerified]) {
                        if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                            [wself showHint:response.errDesc];
                        }
                        wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
                        [wself.verPopingView showPopingViewWithUsageType:G100VerificationCodeUsageToLogin clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                
                                if ([wself.verPopingView.veriTextfield.text trim].length == 0) {
                                    [wself showHint:@"请输入验证码"];
                                    return;
                                }
                                [wself.verPopingView.veriTextfield resignFirstResponder];
                                [wself showHudInView:wself.view hint:@"正在验证"];
                                [[G100UserApi sharedInstance] sv_loginUserWithLoginName:name andPassword:PWENCRYPT(password) partner:nil partneraccount:nil partneraccounttoken:nil partneruseruid:nil logintrigger:0 picurl:wself.verPopingView.pictureCap.url picid:wself.verPopingView.pictureCap.ID inputbar:wself.verPopingView.veriTextfield.text sessionid:wself.verPopingView.pictureCap.session_id usage:0 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                                                                [wself hideHud];
                                                                                
                                                                                if (requestSuccess) {
                                                                                    if ([wself.verPopingView superview]) {
                                                                                        [wself.verPopingView dismissWithVc:wself animation:YES];
                                                                                    }
                                                                                    
                                                                                    // 图像验证码验证成功后的操作
                                                                                    NSDictionary *bizDict = response.data;
                                                                                    [wself loginSuccess:bizDict];
                                                                                    //[MobClick event:@"login"];
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
            
            }
        }
    };
    
    if (_isThird) { // 判断是否是第三方帐号登录
        
        [[G100UserApi sharedInstance] sv_loginUserWithLoginName:name andPassword:PWENCRYPT(password) partner:EMPTY_IF_NIL(_partner) partneraccount:EMPTY_IF_NIL(_partneraccount) partneraccounttoken:EMPTY_IF_NIL(_partneraccounttoken) partneruseruid:EMPTY_IF_NIL(_partneruseruid) logintrigger:0 picurl:nil picid:nil inputbar:nil sessionid:nil usage:0 callback:callback];
    }else {
        
        [[G100UserApi sharedInstance] sv_loginUserWithLoginName:name andPassword:PWENCRYPT(password) partner:nil partneraccount:nil partneraccounttoken:nil partneruseruid:nil logintrigger:0 picurl:nil picid:nil inputbar:nil sessionid:nil usage:0 callback:callback];
    }
}

- (void)loginSuccess:(id)responseObj {
    [UserManager shareManager].loginType = self.loginType;
    [[UserManager shareManager] loginWithUsername:_phoneNum password:_password userInfo:responseObj];
    [[UserManager shareManager] updateUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid] complete:nil];
    // 填写个人资料
    NSString * userid = [[responseObj objectForKey:@"user_info"] objectForKey:@"user_id"];
    if (!self.isRegistered) {
        [self fillUserInfoWithUserid:userid];
    }else
    {
        __weak G100UserRegisterViewController * wself = self;
        [[UserManager shareManager] updateBikeListWithUserid:userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            [wself.navigationController dismissViewControllerAnimated:YES completion:^{
                if (wself.loginResult) {
                    wself.loginResult([[G100InfoHelper shareInstance] buserid], YES);
                }
            }];
        }];
    }
    // 上传定位信息
    [[G100LocationUploader uploader] lmu_updateLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(YES) userInfo:nil];
}

-(void)fillUserInfoWithUserid:(NSString *)userid {
    [G100InfoHelper shareInstance].username = _phoneNum;
    
    G100UserInfoViewController *full = (G100UserInfoViewController *)[[G100Mediator sharedInstance] G100Mediator_viewControllerForUserInfo];
    full.userid = userid;
    full.screen_name = [NSString stringWithFormat:@"骑卫士%@", userid];
    full.loginResult = self.loginResult;
    
    [self.navigationController pushViewController:full animated:YES];
}

#pragma mark - Life Cycle
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [UserManager shareManager].remoteLogin = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self setExclusiveTouchForButtons:self.view];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
  
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    if (_isLookAgreement) {
        
    }else {
        [self endTime];
    }
}

-(void)setExclusiveTouchForButtons:(UIView *)myView
{
    for (UIView * view in [myView subviews]) {
        if([view isKindOfClass:[UIButton class]])
            [((UIButton *)view) setExclusiveTouch:YES];
        else if ([view isKindOfClass:[UIView class]]){
            [self setExclusiveTouchForButtons:view];
        }
    }
}


-(G100VerificationPopingView *)verPopingView
{
    if (!_verPopingView) {
        _verPopingView = [G100VerificationPopingView popingViewWithVerificationView];
        _verPopingView.usageType = G100VerificationCodeUsageToRegister;
    }
    return _verPopingView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
