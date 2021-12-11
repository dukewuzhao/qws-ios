//
//  ChangePhoneNumViewController.m
//  G100
//
//  Created by Tilink on 15/4/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ChangePhoneNumViewController.h"
#import "RealChangePhoneNumViewController.h"
#import "G100UserApi.h"
#import "RequestVCView.h"
#import "G100PromptBox.h"
#import "PictureCaptcha.h"

@interface ChangePhoneNumViewController ()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneIconConstraintTop;

@property (strong, nonatomic) RequestVCView * waitView;
@property (strong, nonatomic) G100VerifyCodePromptBox *verifyBox;
@property (strong, nonatomic) G100VerificationPopingView *verPopingView;

@property (copy, nonatomic) NSString *phonenum;

@end

@implementation ChangePhoneNumViewController

+ (instancetype)loadNibViewController:(NSString *)userid {
    ChangePhoneNumViewController *viewController = [[ChangePhoneNumViewController alloc] initWithNibName:NSStringFromClass([self class])
                                                                                                  bundle:nil];
    viewController.userid = userid;
    return viewController;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.changeBtn setExclusiveTouch:YES];
    [self.changeBtn setBackgroundImage:[[UIImage imageNamed:@"ic_service_commit_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)
                                                                                                        resizingMode:UIImageResizingModeStretch]
                              forState:UIControlStateNormal];
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"手机"];
    
    self.view.backgroundColor = MyBackColor;
    self.phoneIconConstraintTop.constant = kNavigationBarHeight + 24;
    
    G100UserDomain *userinfo = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:self.userid];
    self.phonenum = userinfo.phone_num;
    self.phoneLabel.text = [NSString stringWithFormat:@"您的手机号：%@", [NSString shieldImportantInfo:self.phonenum]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (IBAction)changeEvent:(UIButton *)sender {
    // 此时短信应当已发送
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    // 判断是否合法手机号
    NSString * phoneNumber = self.phonenum;
    if (![phoneNumber isValidateMobile]) {
        [self showWarningHint:@"手机号码格式错误"];
        return;
    }
    
    __weak ChangePhoneNumViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            if ([wself.verifyBox superview]) {
                [wself.verifyBox dismissWithVc:wself animation:YES];
            }
        }else {
            if (response) {
                if ([response needPicvcVerified]) {
                    if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                        [wself showHint:response.errDesc];
                    }
                    [wself.waitView dismissWithVc:wself animation:YES];
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
                            [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phonenum PictureCaptcha:picCap callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                [wself hideHud];
                                
                                if (requestSuccess) {
                                    if ([wself.verPopingView superview]) {
                                        [wself.verPopingView dismissWithVc:wself animation:YES];
                                    }
                                    [wself showPopWait];

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
            
            [wself.waitView endTime];
        }
    };
    
    [self showPopWait];
    NSDictionary *picCap = @{
                             @"url" : @"",
                             @"id" : @"",
                             @"input" : @"",
                             @"session_id" : @"",
                             @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToChangePn]
                             };
    [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:phoneNumber PictureCaptcha:picCap callback:callback];
}

-(void)showPopWait {
    RequestVCView * reView = [[[NSBundle mainBundle]loadNibNamed:@"RequestVCView" owner:self options:nil]lastObject];
    reView.phoneNumber = self.phonenum;
    
    __weak ChangePhoneNumViewController * wself = self;
    reView.requestVCSureEvent = ^(NSString * testWord){
        // 此时验证码已经是正确的
        wself.waitView = nil;
        [wself gotTestword:testWord];
    };
    reView.requestVCAgainEvent = ^(){
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                if ([wself.verifyBox superview]) {
                    [wself.verifyBox dismissWithVc:wself animation:YES];
                }
                
                [wself.waitView startTime];
            }else {
                if (response) {
                    if ([response needPicvcVerified]) {
                        if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                            [wself showHint:response.errDesc];
                        }
                        [wself.waitView dismissWithVc:wself animation:YES];
                        wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
                        //NSDictionary *pic = [NSDictionary dictionaryWithDictionary:response.data[@"picture_captcha"]];
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
                                [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phonenum PictureCaptcha:picCap callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                    [wself hideHud];
                                    
                                    if (requestSuccess) {
                                        if ([wself.verPopingView superview]) {
                                            [wself.verPopingView dismissWithVc:wself animation:YES];
                                        }
                                        [wself showPopWait];
                                        
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
                
                [wself.waitView endTime];
            }
        };
        NSDictionary *picCap = @{
                                 @"url" : @"",
                                 @"id" : @"",
                                 @"input" : @"",
                                 @"session_id" : @"",
                                 @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToChangePn]
                                 };
        [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phonenum PictureCaptcha:picCap callback:callback];
    };
    [reView setupView];
    
    [reView showInVc:self view:self.view animation:YES];
    
    self.waitView = reView;
}

-(void)gotTestword:(NSString *)testword {
    RealChangePhoneNumViewController * realChange = [[RealChangePhoneNumViewController alloc] initWithNibName:@"RealChangePhoneNumViewController" bundle:nil];
    realChange.oldPhone = self.phonenum;
    realChange.oldTestword = testword;
    
    [self.navigationController pushViewController:realChange animated:YES];
}

#pragma mark - Lazzy Load
- (G100VerifyCodePromptBox *)verifyBox {
    if (!_verifyBox) {
        self.verifyBox = [G100VerifyCodePromptBox promptVerifyCodeBoxSureOrCancelAlertView];
        self.verifyBox.verificationCodeUsage = G100VerificationCodeUsageToChangePn;
    }
    return _verifyBox;
}

-(G100VerificationPopingView *)verPopingView
{
    if (!_verPopingView) {
        _verPopingView = [G100VerificationPopingView popingViewWithVerificationView];
        _verPopingView.usageType = G100VerificationCodeUsageToChangePn;
    }
    return _verPopingView;
}
@end
