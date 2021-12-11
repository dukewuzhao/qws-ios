//
//  RequestVCView.m
//  G100
//
//  Created by Tilink on 15/3/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100UserApi.h"
#import "RequestVCView.h"
#import "G100PromptBox.h"
#import "PictureCaptcha.h"
#define TWarningError @"您输入的验证码有误，请重新输入"

@interface RequestVCView () {
    dispatch_queue_t queue;
    dispatch_source_t _timer;
    
    CGFloat _kbDistance;
}

@property (copy, nonatomic) NSString * testword;
@property (strong, nonatomic) G100VerifyCodePromptBox *verifyBox;
@property (strong, nonatomic) G100VerificationPopingView *verPopingView;
@property (weak, nonatomic) IBOutlet UILabel *voiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *voiveButton;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceButtonConstraint;

@end

@implementation RequestVCView

-(void)dealloc {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.sureButton setExclusiveTouch:YES];
    [self.cancelButton setExclusiveTouch:YES];
    
    [self.sureButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_sure_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_cancel_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.waningLabel.hidden = YES;
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField == self.testField) {
        self.testword = toBeString;
        if (toBeString.length > 4) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.waningLabel.hidden = YES;
    self.testword = textField.text;
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.waningLabel.hidden = YES;
    
    return YES;
}

-(void)setupView {
    self.backgroundColor = MyAlphaColor;
    
    self.frame = KEY_WINDOW.bounds;
    self.testField.delegate = self;
    self.mainView.layer.cornerRadius = 6.0f;
        
    self.sendAgain.layer.borderColor = [UIColor grayColor].CGColor;
    self.sendAgain.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.sendAgain.layer.borderWidth = 0.6f;
    self.sendAgain.layer.cornerRadius = 6.0f;
    
    self.phoneNumLabel.text = [NSString shieldImportantInfo:self.phoneNumber];
    self.testField.delegate = self;
    
    self.waningLabel.hidden = YES;
    // 添加手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    [self addGestureRecognizer:tap];
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    if (![self superview]) {
        _kbDistance = [IQKeyHelper keyboardDistanceFromTextField];
        [IQKeyHelper setKeyboardDistanceFromTextField:100];
        
        [self startTime];
        [view addSubview:self];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:vc animation:animation];
    
    if ([self superview]) {
        [IQKeyHelper setKeyboardDistanceFromTextField:_kbDistance];
        
        [self removeFromSuperview];
    }
}

#pragma mark - 点击空白取消
-(void)tapView:(UITapGestureRecognizer *)tap {
    if (IQKeyHelper.keyboardIsVisible) {
        [self endEditing:YES];
        return;
    }
}

#pragma mark - 重新发送
-(void)requestVCAgain {
    self.waningLabel.hidden = YES;
    // 此时短信应当已发送
    if (kNetworkNotReachability) {
        [APPDELEGATE.window.rootViewController showHint:kError_Network_NotReachable];
        return;
    }
    if ([NSString checkPhoneNum:_phoneNumber]) {
        [APPDELEGATE.window.rootViewController showHint:[NSString checkPhoneNum:_phoneNumber]];
        return;
    }
    
    __weak RequestVCView * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [self startTime];
        }else {
            if (response) {
                if ([response needPicvcVerified]) {
                    if (response.errCode != SERV_RESP_VERIFY_PICVC) {
                        [wself.popVc showHint:response.errDesc];
                    }
                    
            [wself endTime];
            [wself dismissWithVc:wself.popVc animation:YES];
            wself.verPopingView.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
           // NSDictionary *pic = [NSDictionary dictionaryWithDictionary:response.data[@"picture_captcha"]];
            [wself.verPopingView showPopingViewWithUsageType:G100VerificationCodeUsageToChangePn clickEvent:^(NSInteger index) {
                if (index == 2) {
                    
                    if ([wself.verPopingView.veriTextfield.text trim].length == 0) {
                        return;
                    }
                    [wself.verPopingView.veriTextfield resignFirstResponder];
                    [wself.popVc showHudInView:wself.popVc.view hint:@"正在验证"];
                    NSDictionary *picCap = @{
                                             @"url" : EMPTY_IF_NIL(wself.verPopingView.pictureCap.url),
                                             @"id" : EMPTY_IF_NIL(wself.verPopingView.pictureCap.ID),
                                             @"input" : EMPTY_IF_NIL(wself.verPopingView.veriTextfield.text),
                                             @"session_id" : EMPTY_IF_NIL(wself.verPopingView.pictureCap.session_id),
                                             @"usage" : [NSNumber numberWithInteger:G100VerificationCodeUsageToChangePn]
                                             };
                    [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:wself.phoneNumber PictureCaptcha:picCap callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        [wself.popVc hideHud];
                        
                        if (requestSuccess) {
                            if ([wself.verPopingView superview]) {
                                [wself.verPopingView dismissWithVc:wself.popVc animation:YES];
                            }
                            // 图像验证码验证成功后的操作
                            [wself startTime];
                        }else {
                            [wself.popVc showHint:response.errDesc];
                            if ([wself.verPopingView superview]) {
                                [wself.verPopingView refreshVeriCode];
                            }
                        }
                    }];
                    
                }else if (index == 1)
                {
                    if ([wself.verPopingView superview]) {
                        [wself.verPopingView dismissWithVc:wself.popVc animation:YES];
                    }
                }
                
            } onViewController:wself.popVc onBaseView:wself.popVc.view];
            
            
        }else {
            [wself.popVc showHint:response.errDesc];
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
    [[G100UserApi sharedInstance] sv_requestSmsVerificationWithMobile:_phoneNumber PictureCaptcha:picCap callback:callback];
}

- (IBAction)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 200:
        {
            // 重新发送
            [self endTime];
           // [self requestVCAgain];
            
            if (_requestVCAgainEvent) {
                self.requestVCAgainEvent();
            }
        }
            break;
        case 210:
        {
            // 确定
            self.testword = self.testField.text;
            [self validate:_testword];
        }
            break;
        case 220:
        {
            // 取消
            [self endTime];
            [self dismissWithVc:self.popVc animation:YES];
        }
            break;
        case 230:
        {
            // 取消
            [self endTime];
            [self requestVoiveCode];
        }
            break;
        default:
            break;
    }
}

- (void)requestVoiveCode{
    
    if (kNetworkNotReachability) {
        [APPDELEGATE.window.rootViewController showHint:kError_Network_NotReachable];
        return;
    }
    if ([NSString checkPhoneNum:_phoneNumber]) {
        [APPDELEGATE.window.rootViewController showHint:[NSString checkPhoneNum:_phoneNumber]];
        return;
    }
    __weak RequestVCView * wself = self;
    [[G100UserApi sharedInstance] sv_requestVoiVerificationWithMobile:_phoneNumber PictureCaptcha:nil callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            wself.voiceLabel.text = @"电话拨打中，请留意接听";
            wself.voiceButtonConstraint.constant = 0;
            [wself startTime];
        }else {
            if (response) {
                [APPDELEGATE.window.rootViewController showHint:response.errDesc];
            }
        }
    }];
    
}

#pragma mark - 验证输入的验证码是否正确
-(void)validate:(NSString *)testword {
    if (testword.length == 4) {
        if (kNetworkNotReachability) {
            [APPDELEGATE.window.rootViewController showHint:kError_Network_NotReachable];
            return;
        }
        
        __weak RequestVCView * wself = self;
        __weak UIViewController * wvc = APPDELEGATE.window.rootViewController;
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                [wself endTime];
                if (wself.requestVCSureEvent) {
                    wself.requestVCSureEvent(testword);
                }
                
                [wself dismissWithVc:wself.popVc animation:YES];
            }else {
                if (response) {
                    [wvc showHint:response.errDesc];
                }
            }
        };
        [[G100UserApi sharedInstance] sv_checkVerificationCodeWithMobile:_phoneNumber vcode:_testword callback:callback];
    }else {
        self.waningLabel.hidden = NO;
    }
}

-(void)startTime {
    __weak RequestVCView * wself = self;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    __block int timeout = G100VCodeDuration; //倒计时时间
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                wself.timeRemain.text = @"";
                wself.timeRemain.hidden = YES;
                wself.sendAgain.enabled = YES;
                
                [wself.sendAgain setTitle:@"获取验证码" forState:UIControlStateNormal];
                wself.voiceLabel.text = @"收不到验证码？试试";
                wself.voiceButtonConstraint.constant = 62;
            });
        }else{
            //            int minutes = timeout / 60;
            NSString *strTime = [NSString stringWithFormat:@"%.d 秒", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSLog(@"____%@",strTime);
                wself.timeRemain.text = [NSString stringWithFormat:@"%@秒后", strTime];
                wself.timeRemain.hidden = YES;
                wself.sendAgain.enabled = NO;
                [wself.sendAgain setTitle:strTime forState:UIControlStateDisabled];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

-(void)endTime {
    if (_timer) {
        __weak RequestVCView * wself = self;
        dispatch_source_cancel(_timer);
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置界面的按钮显示 根据自己需求设置
            wself.timeRemain.text = @"";
            wself.sendAgain.enabled = YES;
        });
    }
}

#pragma mark - Lazzy Load
- (G100VerifyCodePromptBox *)verifyBox {
    if (!_verifyBox) {
        self.verifyBox = [G100VerifyCodePromptBox promptVerifyCodeBoxSureOrCancelAlertView];
        self.verifyBox.verificationCodeUsage = self.verificationCodeUsage;
    }
    return _verifyBox;
}

@end
