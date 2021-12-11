//
//  G100UserLoginViewController.m
//  G100
//
//  Created by sunjingjing on 16/7/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserLoginViewController.h"
#import "G100ForgetPwViewController.h"
#import "G100DeviceDomainExpand.h"
#import "G100UserApi.h"
#import "G100ThirdAuthManager.h"
#import "G100Mediator+UserInfo.h"
#import "G100Mediator+Register.h"
#import "G100UserRegisterViewController.h"
#import "UIImage+Effection.h"
#import "CDDDataHelper.h"
#import <UIImageView+WebCache.h>
//#import <UMAnalytics/MobClick.h>
#import "PictureCaptcha.h"
#import "G100LocationUploader.h"
#import "G100WebViewController.h"
#import "G100ReactivePopingView+GrabLoginView.h"
#import <WXApi.h>
#define DefaultTopH 35.0 * WIDTH / 69.0f
#define DefaultHeight 100.0f

@interface G100UserLoginViewController ()<UITextFieldDelegate>
{
    CGFloat _kbDistance;
    BOOL needVerificate;
    BOOL isLoginInfoCompleted;
}

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIImageView *bIconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bIconHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

@property (nonatomic,assign) CGFloat lastOffSet;//存放上次的contentoffset.y值，用来计算往上还是往下拖拽

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *loginPassWordTF;
@property (weak, nonatomic) IBOutlet UIButton *displayPW;
@property (weak, nonatomic) IBOutlet UIButton *forgetPW;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *userRegisterButton;
@property (weak, nonatomic) IBOutlet UIView *agreeView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreeHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *wxButton;
@property (weak, nonatomic) IBOutlet UIButton *sinaButton;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;

@property (copy, nonatomic) NSString * username;
@property (copy, nonatomic) NSString * password;

// 三方登录信息
@property (copy, nonatomic) NSString * partner;
@property (copy, nonatomic) NSString * partneraccount;
@property (copy, nonatomic) NSString * partneraccounttoken;
@property (copy, nonatomic) NSString * partneruseruid;

@property (copy, nonatomic) NSString * screen_name;
@property (assign, nonatomic) UserLoginType loginType;
@property (assign, nonatomic) BOOL isTaped;
@property (assign, nonatomic) BOOL loginMore;
@property (copy, nonatomic) NSString *loginMoreName;

@property (strong, nonatomic) G100VerificationPopingView *verPopingView;
@property (strong, nonatomic) PictureCaptcha *currentCaptcha;
@property (strong, nonatomic) UIScrollView *topView;
@property (strong, nonatomic) NSString *privacyV;

@end

@implementation G100UserLoginViewController

-(void)dealloc {
    DLog(@"登录页释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGNAppLoginOrLogoutNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)setupView
{
    self.navigationBarView.backgroundColor = [UIColor clearColor];
    [self setNavigationTitle:@"登录"];
    self.loginButton.layer.cornerRadius =22.0f/3;
    self.userRegisterButton.layer.cornerRadius = 22.0f/3;
    self.userRegisterButton.layer.borderWidth =1.5f;
    self.userRegisterButton.layer.borderColor = [UIColor colorWithHexString:@"2db500"].CGColor;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 6.0f;
    self.bIconHeightConstraint.constant = 0;
    self.scrollViewTopConstraint.constant = DefaultTopH - DefaultHeight;
    self.topView = (UIScrollView *)self.substanceView;
    self.topView.contentInset = UIEdgeInsetsMake(DefaultHeight, 0, 0, 0);
    self.topView.delegate = self;
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self configThirdLoginUI];
    // iOS 11 UI 显示bug 修复
    if ([self.topView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.topView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [_phoneNumTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [_phoneNumTF setText:[G100InfoHelper shareInstance].username];
    if (_phoneNumTF.text.length) {
        [self checkPrivacyVersionIsLogin:NO];
    }
    G100UserDomain *userDomain = [[CDDDataHelper cdd_sharedInstace] cdd_findUserinfoDataWithPhone_num:_phoneNumTF.text];
    if (!userDomain) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                              placeholderImage:[UIImage imageNamed:@"ic_default_male"]];
        self.bIconImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
    }else {
        __weak G100UserLoginViewController * wself = self;
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:userDomain.icon] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    wself.bIconImageView.image = [image fx_defaultGaussianBlurImage];
                }else {
                    if ([userDomain.gender isEqualToString:@"1"]) {
                        wself.bIconImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
                    }else {
                        wself.bIconImageView.image = [[UIImage imageNamed:@"ic_default_female"] fx_defaultGaussianBlurImage];
                    }
                }
            });
        }];
        
        if ([userDomain.gender isEqualToString:@"1"]) {
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                  placeholderImage:[UIImage imageNamed:@"ic_default_male"]];
        }else {
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                  placeholderImage:[UIImage imageNamed:@"ic_default_female"]];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginOrLogoutNotification:)
                                                 name:kGNAppLoginOrLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewControllerBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)configThirdLoginUI{
    if (![WXApi isWXAppInstalled]) {
        self.sinaButton.hidden = YES;
        [self.wxButton setImage:[UIImage imageNamed:@"ic_user_loginsina"] forState:UIControlStateNormal];
        self.wxButton.tag = 1002;
        self.sinaButton.tag = 1001;
    }else{
        self.sinaButton.hidden = NO;
        [self.wxButton setImage:[UIImage imageNamed:@"ic_user_loginwx"] forState:UIControlStateNormal];
        self.wxButton.tag = 1001;
        self.sinaButton.tag = 1002;
    }
}

- (G100VerificationPopingView *)verPopingView
{
    if (!_verPopingView) {
        _verPopingView = [G100VerificationPopingView popingViewWithVerificationView];
        _verPopingView.usageType = G100VerificationCodeUsageToLogin;
    }
    return _verPopingView;
}
- (IBAction)tapProtocal:(id)sender {
    G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
    agreement.filename = @"regist_agreement.html";
    agreement.webTitle = @"用户使用协议";
    //self.agreeButton.selected = YES;
    [self.navigationController pushViewController:agreement animated:YES];
}

- (IBAction)tapPrivacy:(id)sender {
    G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
    agreement.httpUrl = @"https://www.qiweishi.com/privacy_policy.html";
    agreement.webTitle = @"隐私政策";
    //self.agreeButton.selected = YES;
    [self.navigationController pushViewController:agreement animated:YES];
}
- (IBAction)tapAgree:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark - 顶部缩放核心代码
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.phoneNumTF.isFirstResponder) {
        [self.phoneNumTF resignFirstResponder];
    }else if (self.loginPassWordTF.isFirstResponder)
    {
        [self.loginPassWordTF resignFirstResponder];
    }
    CGFloat offset = scrollView.contentOffset.y;//取出offset的y值
    CGFloat delta = offset - _lastOffSet;//与上次存放的值相减
    if (delta > 0)//差值大于0，则是往上滑，因为contentOffset.y值是增加的
    {
        //当往上滑动时，发现ImageView的高度大于0，则要按照滑动的速率也就是delta值减去ImageView的高度，直到小于0停止
        if (self.bIconHeightConstraint.constant > 0) {
            self.bIconHeightConstraint.constant -= delta;
        }else
        {
            self.bIconHeightConstraint.constant = 0;//ImageView高度已经小于0，重置为0,因为滑动快的话，高度会变负数
        }
    }else if(delta < 0)//差值小于0，往下滑
    {
        //当我们设置了tableView的顶部EdgeInset，正常情况下，tableView的contentOffset一开始是为负数的，我们这里一开始就是-244，也就是Imageview的高度加上红色View的高度
        //当第一行cell滚动到红色View底部时，offset为-44，大家可以停下来想想看是不是，然后当继续往下滑动时，offset更加小了
        //这时Imageview就要出现了
        if (offset < -DefaultHeight) {
            //ImageView出现了，开始设置其高度
            //而ImageView的高度应该与self.view顶部到红色View的顶部的间距相等
            //大家想想看是不是
            //于是我直接用contentOffset减去（因为是负数）红色View的高度，然后不就等于这间距了么，于是功能就实现了
            self.bIconHeightConstraint.constant = ABS(scrollView.contentOffset.y + DefaultHeight);
        }
    }
    
    _lastOffSet = offset;
}

- (void)loginOrLogoutNotification:(NSNotification *)notification {
    BOOL result = [notification.object boolValue];
    
    if (!result) {
        self.loginMore = NO;
        if ([self.loginPassWordTF.text isEqualToString:self.loginMoreName]) {
            self.loginMoreName = nil;
        }
    }
}

#pragma mark - Private Method
- (IBAction)userTouchuEvents:(UIButton *)sender {
    switch (sender.tag) {
        case 101:
            sender.selected = !sender.selected;
            self.loginPassWordTF.secureTextEntry = !sender.selected;
            if (sender.selected) {
                self.isTaped = YES;
            }
            if (self.loginPassWordTF.isFirstResponder) {
                [self.loginPassWordTF resignFirstResponder];
                self.loginPassWordTF.font = [UIFont systemFontOfSize:17];
            }
            break;
        case 102:
            // 找回密码
            [self forgetPassword];
            break;
        case 103:
            [self login];
            break;
        case 104:
            [self userRegister];
            break;
        default:
            break;
    }
}

- (void)forgetPassword
{
    G100ForgetPwViewController * forget = [[G100ForgetPwViewController alloc]initWithNibName:@"G100ForgetPwViewController" bundle:nil];
    forget.findStyle = NOLoginFindPasswprd;
    [self.navigationController pushViewController:forget animated:YES];
}

-(void)checkPrivacyVersionIsLogin:(BOOL)islogin {
     dispatch_async(dispatch_get_main_queue(), ^{
         AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
         __weak typeof(self) wSelf = self;
         [sessionManager GET:@"https://www.qiweishi.com/data/qws_version.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             wSelf.privacyV = [responseObject objectForKey:@"version"];
             if (islogin) {
                 [[G100InfoHelper shareInstance] updatePrivacyWithUserid:wSelf.username version:wSelf.privacyV];
             }else{
                 NSString *oldV = [[G100InfoHelper shareInstance] getPrivacyVersionWithUserid:_phoneNumTF.text];
                 if (![wSelf.privacyV isEqualToString:oldV]) {
                     wSelf.agreeHeightConstraint.constant = 32;
                     wSelf.agreeView.hidden = NO;
                 }else{
                     wSelf.agreeHeightConstraint.constant = 0;
                     wSelf.agreeView.hidden = YES;
                 }
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             DLog(@"请求失败--%@",error);
         }];
     });
}

- (void)login
{
    if (self.loginPassWordTF.isFirstResponder) {
        [self.loginPassWordTF resignFirstResponder];
    }else if(self.phoneNumTF.isFirstResponder)
    {
        [self.phoneNumTF resignFirstResponder];
    }
    if (!_agreeButton.selected) {
        [self showHint:@"请先同意用户使用协议和隐私政策"];
        return;
    }
    self.loginType = UserLoginTypePhoneNum;
    self.username = self.phoneNumTF.text;
    self.password = self.loginPassWordTF.text;
    
    if ([NSString isEmpty:_username]) {
        [self showWarningHint:@"用户名不能为空"];
        return;
    }
    if ([NSString isEmpty:_password]) {
        [self showWarningHint:@"密码不能为空"];
        return;
    }
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    [self checkPrivacyVersionIsLogin:YES];
    // login    此处先清空三方登录信息
    self.partner = nil;
    self.partneraccount = nil;
    self.partneraccounttoken = nil;
    __weak G100UserLoginViewController * wself = self;
    if (![self.loginMoreName isEqualToString:self.username]) {
        self.loginMore = NO;
    }else{
        self.loginMore = YES;
    }
    if (self.loginMore) {
        [self autoLoginWithName:_phoneNumTF.text password:_loginPassWordTF.text isThird:NO];
        return;
    }
    if (needVerificate == YES) {
        [self.verPopingView showPopingViewWithUsageType:G100VerificationCodeUsageToLogin clickEvent:^(NSInteger index) {
                if (index == 2) {
                    if ([wself.verPopingView.veriTextfield.text trim].length == 0) {
                        [wself showHint:@"请输入验证码"];
                        return;
                    }
                    [wself.verPopingView.veriTextfield resignFirstResponder];
                    [wself showHudInView:wself.view hint:@"正在验证"];
                    [[G100UserApi sharedInstance] sv_loginUserWithLoginName:_phoneNumTF.text andPassword:PWENCRYPT(_loginPassWordTF.text) partner:nil partneraccount:nil partneraccounttoken:nil partneruseruid:nil logintrigger:0 picurl:wself.verPopingView.pictureCap.url picid:wself.verPopingView.pictureCap.ID inputbar:wself.verPopingView.veriTextfield.text sessionid:wself.verPopingView.sessionid usage:G100VerificationCodeUsageToLogin callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        if (requestSuccess) {
                            if ([wself.verPopingView superview]) {
                                [wself.verPopingView dismissWithVc:wself animation:YES];
                            }
                            needVerificate = NO;
                            // 图像验证码验证成功后的操作
                            NSDictionary *bizDict = response.data;
                            [wself loginSuccess:bizDict];
                            //[MobClick event:@"login"];
                        }else {
                            [wself hideHud];
                            [wself showHint:response.errDesc];
                            if (response.errCode == SERV_RESP_VERIFY_PICVC || response.errCode == SERV_RESP_ERROR_VERIFY_PICVC) {
                                if ([wself.verPopingView superview]) {
                                    [wself.verPopingView refreshVeriCode];
                                }
                            }else{
                                if ([wself.verPopingView superview]) {
                                    [wself.verPopingView dismissWithVc:wself animation:YES];
                                }
                            }
                        }
                    }];
                }else if (index ==1)
                {
                    if ([wself.verPopingView superview]) {
                        [wself.verPopingView dismissWithVc:wself animation:YES];
                    }
                }
                
            } onViewController:self onBaseView:self.view];
    }else{
        [self autoLoginWithName:_phoneNumTF.text password:_loginPassWordTF.text isThird:NO];
    }
}

- (void)userRegister
{
    UIViewController * viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForRegister:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 登录操作
-(void)autoLoginWithName:(NSString *)name password:(NSString *)password isThird:(BOOL)isThird {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100UserLoginViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger status, ApiResponse *response, BOOL success){
        if (response.success) {
            NSDictionary *bizDict = response.data;
            [wself loginSuccess:bizDict];
            //[MobClick event:@"login"];
            needVerificate = NO;
            _loginMore = NO;
        }else {
            [wself hideHud];
            [wself showHint:response.errDesc];
            if (response) {
                if ([response needPicvcVerified]) { //验证码图片url
                        needVerificate = YES;
                        wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
                    }
                }else{
                    needVerificate = NO;
                }
                if (response.errCode == SERV_RESP_ERROR_LOGIN_MORE) {
                    _loginMore = YES;
                    _loginMoreName = name;
                }
            }
    };
    
    [self showHudInView:self.view hint:@"正在登录"];
    [[G100UserApi sharedInstance] sv_loginUserWithLoginName:name andPassword:PWENCRYPT(password) partner:EMPTY_IF_NIL(_partner) partneraccount:EMPTY_IF_NIL(_partneraccount) partneraccounttoken:EMPTY_IF_NIL(_partneraccounttoken) partneruseruid:EMPTY_IF_NIL(_partneruseruid) logintrigger:0 picurl:nil picid:nil inputbar:nil sessionid:nil usage:0 callback:callback];
}

#pragma mark - 登录成功
- (void)loginSuccess:(id)responseObj {
    
    [UserManager shareManager].loginType = self.loginType;
    [[UserManager shareManager] loginWithUsername:_username password:_password userInfo:responseObj];
    [[G100LocationUploader uploader] lmu_updateLocation];
    
    __weak G100UserLoginViewController *wself = self;
    NSString *buserid = responseObj[@"user_info"][@"user_id"];
    [[UserManager shareManager] updateUserInfoWithUserid:buserid complete:nil];
    [[UserManager shareManager] updateBikeListWithUserid:buserid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(YES) userInfo:nil];
        
        if (wself.navigationController && [wself.navigationController.viewControllers count] >= 2) {
            [wself.navigationController popViewControllerAnimated:YES];
        }else {
            [wself dismissViewControllerAnimated:YES completion:^{
                if (wself.loginResult) {
                    wself.loginResult([[G100InfoHelper shareInstance] buserid], YES);
                }
            }];
        }
    }];
}

- (IBAction)thirdLoginEvents:(UIButton *)sender {
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    switch (sender.tag) {
        case 1001:
            self.partner = @"wx";
            self.loginType = UserLoginTypeWeixin;
            [self loginByWX];
            break;
        case 1002:
            self.partner = @"sina";
            self.loginType = UserLoginTypeSina;
            [self loginBySina];
            break;
        case 1003:
            self.partner = @"qq";
            self.loginType = UserLoginTypeQQ;         
            [self loginByQQ];
            break;
        default:
            break;
    }
}

#pragma mark - 第三方登录
- (void)loginByWX
{
    __weak G100UserLoginViewController *wself = self;
    [G100ThirdAuthManager getThirdWechatAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        }else {
            [wself authSuccessWith:thirdAccount];
        }
    }];
}

- (void)loginBySina
{
    __weak G100UserLoginViewController *wself = self;
    [G100ThirdAuthManager getThirdSinaAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        }else {
            [wself authSuccessWith:thirdAccount];
        }
    }];
}

- (void)loginByQQ
{
    __weak G100UserLoginViewController *wself = self;
    [G100ThirdAuthManager getThirdQQAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        }else {
            [wself authSuccessWith:thirdAccount];
        }
    }];
}

#pragma mark - 授权成功
- (void)authSuccessWith:(UMSocialUserInfoResponse *)snsAccount {
    self.partneraccount = snsAccount.openid.length ? snsAccount.openid :snsAccount.uid;
    self.screen_name = snsAccount.name;
    self.partneruseruid = snsAccount.uid;
    
    [UserManager shareManager].thirdUserid = snsAccount.openid.length ? snsAccount.openid :snsAccount.uid;   // 保存用户的uid
    
    // 制作用户的临时密码 临时密码格式：360[渠道][用户id]QWS[YYYYMMDD] + md5
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * pw = [formatter stringFromDate:[NSDate date]];
    
    self.partneraccounttoken = [[NSString stringWithFormat:@"360%@%@QWS%@", self.partner, self.partneraccount, pw] stringFromMD5];
    
    // 判断是否存在第三方登录信息
    __weak G100UserLoginViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // 调登录接口
            [wself autoLoginWithName:[response.data objectForKey:@"phone_num"] password:nil isThird:YES];
        }else {
            // 不存在  去注册
            if (response) {
                if (response.errCode == 56) {
                    [wself showHint:@"请检查系统时间是否正确"];
                }else if (response.errCode == 57){
                    G100UserRegisterViewController *registerVC = (G100UserRegisterViewController*)[[G100Mediator sharedInstance] G100Mediator_viewControllerForRegister:nil];
                    registerVC.isThird = YES;
                    registerVC.loginType = wself.loginType;
                    registerVC.partner = wself.partner;
                    registerVC.screen_name = wself.screen_name;
                    registerVC.partneraccount = wself.partneraccount;
                    registerVC.partneraccounttoken = wself.partneraccounttoken;
                    registerVC.partneruseruid = wself.partneruseruid;
                    [wself.navigationController pushViewController:registerVC animated:YES];
                }
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_checkThirdAccountWithpPartner:_partner
                                                    partneraccount:_partneraccount
                                               partneraccounttoken:_partneraccounttoken
                                                    partneruseruid:_partneruseruid
                                                          callback:callback];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
    if (textField == _loginPassWordTF) {
        if (toBeString.length > 16) {
            return NO;
        }
        
    }
    if (textField.secureTextEntry && self.isTaped) {
        textField.text = toBeString;
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_phoneNumTF isFirstResponder]) {
        [_loginPassWordTF becomeFirstResponder];
    }else if ([_loginPassWordTF isFirstResponder]) {
        if (_loginPassWordTF.text.length < 6) {
            return NO;
        }
        [_loginPassWordTF resignFirstResponder];
        [self login];
    }
    
    return YES;
}

- (void)textFieldDidChanged:(UITextField *)textField {
    if (textField == self.phoneNumTF) {
        G100UserDomain *userDomain = [[CDDDataHelper cdd_sharedInstace] cdd_findUserinfoDataWithPhone_num:self.phoneNumTF.text];
        if (!userDomain) {
            
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                  placeholderImage:[UIImage imageNamed:@"ic_default_male"]];
            self.bIconImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
            self.agreeHeightConstraint.constant = 32;
            self.agreeView.hidden = NO;
            return;
        }
        [self checkPrivacyVersionIsLogin:NO];
        if ([userDomain.icon length]) {
            __weak G100UserLoginViewController * wself = self;
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:userDomain.icon] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        wself.bIconImageView.image = [image fx_defaultGaussianBlurImage];
                    }else {
                        if ([userDomain.gender isEqualToString:@"1"]) {
                            wself.bIconImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
                        }else {
                            wself.bIconImageView.image = [[UIImage imageNamed:@"ic_default_female"] fx_defaultGaussianBlurImage];
                        }
                    }
                });
            }];
            
            if ([userDomain.gender isEqualToString:@"1"]) {
                [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                      placeholderImage:[UIImage imageNamed:@"ic_default_female"]];
            }else {
                [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                      placeholderImage:[UIImage imageNamed:@"ic_default_male"]];
            }
        }else {
            if ([userDomain.gender isEqualToString:@"1"]) {
                [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                      placeholderImage:[UIImage imageNamed:@"ic_default_male"]];
                self.bIconImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
            }else {
                [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userDomain.icon]
                                      placeholderImage:[UIImage imageNamed:@"ic_default_female"]];
                self.bIconImageView.image = [[UIImage imageNamed:@"ic_default_female"] fx_defaultGaussianBlurImage];
            }
        }
    }
}

- (void)viewControllerBecomeActive{
    [self configThirdLoginUI];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // 到了登录页面 异地登录状态重置为NO
    [UserManager shareManager].remoteLogin = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // 防止跳转到登录页面以后 仍然会显示重新登陆提示框
    G100ReactivePopingView *box = [G100ReactivePopingView grabLoginView];
    [box dismissWithVc:box.popVc animation:YES];
    
    self.topView.contentSize = CGSizeMake(self.view.bounds.size.width, self.topView.bounds.size.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    //[IQKeyHelper setKeyboardDistanceFromTextField:_kbDistance];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
