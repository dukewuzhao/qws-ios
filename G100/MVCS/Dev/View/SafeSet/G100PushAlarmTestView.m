//
//  G100PushAlarmTestView.m
//  G100
//
//  Created by yuhanle on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PushAlarmTestView.h"
#import "G100NewPromptBox.h"

#import "G100DeviceDomain.h"

#import "G100DevApi.h"
#import "G100TestConfirmViewController.h"

@interface G100PushAlarmTestView ()

@property (nonatomic, weak) UIView *baseView;
@property (nonatomic, weak) UIViewController *baseVC;

@property (nonatomic, assign) BOOL hasNextItem;//!< 是否还有下一项测试
@property (nonatomic, copy) NSString *testStartTime;//!<开始测试时间
@property (nonatomic, assign) BOOL hasStartTest;//!<标记是否开始测试

@property (nonatomic, assign) BOOL animation;//!< 是否开启动画

@property (nonatomic, strong) G100TestConfirmViewController *testConfirmVC;

@end

@implementation G100PushAlarmTestView

- (instancetype)init {
    if (self = [super init]) {
        _params = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setEntrance:(NSInteger)entrance {
    if (_entrance != entrance) {
        // 移除所有旧的页面
        [self removeAllSubviews];
    }
    
    _entrance = entrance;
    [self.params setObject:[NSNumber numberWithInteger:entrance] forKey:@"entrance"];
    [self saveTestInfo];
    
    // 判断是否还有下一项
    if (!_isTrainTest) {
        _hasNextItem = NO;
    }else if (entrance == 1 || entrance == 2) {
        _hasNextItem = YES;
    }
    else if (entrance == 3) {
        _hasNextItem = NO;
    }
    
    // 重新根据测试入口布局
    if ([self superview]) {
        [self tl_layoutWithEntrance:entrance];
    }
}

#pragma mark - Private Method
- (void)tl_layoutWithEntrance:(NSInteger)entrance {
    self.frame = self.baseView.bounds;
    
    __weak G100PushAlarmTestView *wself = self;
    self.testConfirmVC = [[G100TestConfirmViewController alloc] initWithNibName:@"G100TestConfirmViewController" bundle:nil];
    self.testConfirmVC.userid = self.userid;
    self.testConfirmVC.bikeid = self.bikeid;
    self.testConfirmVC.devid = self.devid;
    self.testConfirmVC.isTrainTest = self.isTrainTest;
    self.testConfirmVC.entrance = entrance;
    self.testConfirmVC.completion = ^(){
        wself.entrance += 1; //执行下一项测试
        [wself showInVc:wself.baseVC view:wself.baseView animation:YES];
    };
    
    if (_entrance == 1) {
        self.testConfirmVC.params = self.params;
        [self dismissWithVc:self.baseVC animation:YES];
        [self.baseVC.navigationController pushViewController:self.testConfirmVC animated:self.animation];
        
    }else if (_entrance == 2) {
        // 微信报警测试
        if (self.hasStartTest) {
            // 如果已经开始测试 则直接跳到测试结果页面
            self.testConfirmVC.params = wself.params;
            [wself dismissWithVc:wself.baseVC animation:YES];
            [wself.baseVC.navigationController pushViewController:self.testConfirmVC animated:self.animation];
        }else {
            __weak typeof(_testConfirmVC) weakTestConfirmVC = _testConfirmVC;
            G100NewPromptDefaultBox *box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
            ClickEventBlock callback = ^(NSInteger index){
                __strong typeof(weakTestConfirmVC) strongTestConfirmVC = weakTestConfirmVC;
                if (index == 0) {
                    // 测试报警
                    [[G100DevApi sharedInstance] testAlarmNotifyWithBikeid:wself.bikeid devid:wself.devid type:2 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        if (requestSuccess) {
                            // 请求成功 调至测试结果
                            wself.testStartTime = [[NSDateFormatter defaultDateFormatter] stringFromDate:[NSDate date]];
                            strongTestConfirmVC.params = wself.params;
                            [strongTestConfirmVC sendLocalNotification];
                            [box dismissWithVc:wself.baseVC animation:YES];
                            [wself dismissWithVc:wself.baseVC animation:YES];
                            [wself.baseVC.navigationController pushViewController:strongTestConfirmVC animated:wself.animation];
                            
                        }else
                            [wself.baseVC showHint:response.errDesc];
                    }];
                }else if (index == 1) {
                    // 放弃测试 首先判断是否是连续测试
                    if (wself.isTrainTest) {
                        [box dismissWithVc:wself.baseVC animation:YES];
                        [wself setEntrance:3];
                    }else {
                        // 否则直接退出测试模式
                        [box dismissWithVc:wself.baseVC animation:YES];
                        [wself dismissWithVc:wself.baseVC animation:YES];
                    }
                }
            };
            
            NSString *content = !_isTrainTest ? @"点击“测试报警”，\n将向您帐号绑定的微信帐号推送\n一次测试报警" : @"点击“发送报警”，\n向您帐号绑定的微信帐号推送报警";
            [box showPromptBoxWithTitle:@"提示" content:content confirmButtonTitle:!_isTrainTest ? @"测试报警" : @"发送报警" cancelButtonTitle:!_isTrainTest ? @"放弃测试" : @"跳过 微信报警 测试" event:callback onViewController:self.baseVC onBaseView:self];
        }
        
    }else if (_entrance == 3) {
        // 电话报警测试
        if (self.hasStartTest) {
            // 如果已经开始测试 则直接跳到测试结果页面
            self.testConfirmVC.params = wself.params;
            [wself dismissWithVc:wself.baseVC animation:YES];
            [wself.baseVC.navigationController pushViewController:self.testConfirmVC animated:self.animation];
        }else {
            if (!_isTrainTest) {
                __weak typeof(_testConfirmVC) weakTestConfirmVC = _testConfirmVC;
                G100NewPromptDefaultBox *box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
                NSString *content = [NSString stringWithFormat:@"点击“测试报警”，\n%@手机将收到\n%@打来的电话报警", [NSString shieldImportantInfo:self.phoneNum], @"琪琪"];
                
                ClickEventBlock callback = ^(NSInteger index){
                    __strong typeof(weakTestConfirmVC) strongTestConfirmVC = weakTestConfirmVC;
                    if (index == 0) {
                        // 测试报警
                        [[G100DevApi sharedInstance] testAlarmNotifyWithBikeid:wself.bikeid devid:wself.devid type:3 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            if (requestSuccess) {
                                // 请求成功 调至测试结果
                                wself.testStartTime = [[NSDateFormatter defaultDateFormatter] stringFromDate:[NSDate date]];
                                strongTestConfirmVC.params = wself.params;
                                [strongTestConfirmVC sendLocalNotification];
                                [box dismissWithVc:wself.baseVC animation:YES];
                                [wself dismissWithVc:wself.baseVC animation:YES];
                                [wself.baseVC.navigationController pushViewController:strongTestConfirmVC animated:wself.animation];
                            }else
                                [wself.baseVC showHint:response.errDesc];
                        }];
                    }else if (index == 1) {
                        // 放弃测试 已经是最后一项 直接退出
                        [box dismissWithVc:wself.baseVC animation:YES];
                        [wself dismissWithVc:wself.baseVC animation:YES];
                    }
                };
                [box showPromptBoxWithTitle:@"提示" content:content confirmButtonTitle:@"测试报警" cancelButtonTitle:@"放弃测试" event:callback onViewController:self.baseVC onBaseView:self];
            }else {
                __weak typeof(_testConfirmVC) weakTestConfirmVC = _testConfirmVC;
                G100NewPromptSimpleBox *box = [G100NewPromptSimpleBox promptAlertViewWithSimpleStyle];
                NSString *content = [NSString stringWithFormat:@"点击“发送报警”，\n%@手机将收到\n%@打来的电话报警", [NSString shieldImportantInfo:self.phoneNum], @"琪琪"];
                
                ClickEventBlock callback = ^(NSInteger index){
                    __strong typeof(weakTestConfirmVC) strongTestConfirmVC = weakTestConfirmVC;
                    if (index == 0) {
                        // 测试报警
                        [[G100DevApi sharedInstance] testAlarmNotifyWithBikeid:wself.bikeid devid:wself.devid type:3 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            if (requestSuccess) {
                                // 请求成功 调至测试结果
                                wself.testStartTime = [[NSDateFormatter defaultDateFormatter] stringFromDate:[NSDate date]];
                                strongTestConfirmVC.params = wself.params;
                                [strongTestConfirmVC sendLocalNotification];
                                [box dismissWithVc:wself.baseVC animation:YES];
                                [wself dismissWithVc:wself.baseVC animation:YES];
                                [wself.baseVC.navigationController pushViewController:strongTestConfirmVC animated:wself.animation];
                            }else
                                [wself.baseVC showHint:response.errDesc];
                        }];
                    }else if (index == 1) {
                        // 放弃测试 已经是最后一项 直接退出
                        [box dismissWithVc:wself.baseVC animation:YES];
                        [wself dismissWithVc:wself.baseVC animation:YES];
                    }
                };
                [box showPromptBoxWithTitle:@"提示" Content:content confirmButtonTitle:@"发送报警" event:callback onViewController:self.baseVC onBaseView:self];
            }
            
        }
        
    }
}

#pragma mark - getter/setter
- (BOOL)hasStartTest {
    return self.testStartTime.length;
}
- (void)setParams:(NSMutableDictionary *)params {
    if (params[@"userid"])
        self.userid = params[@"userid"];
    if (params[@"bikeid"])
        self.bikeid = params[@"bikeid"];
    if (params[@"devid"])
        self.devid = params[@"devid"];
    if (params[@"phoneNum"])
        self.phoneNum = params[@"phoneNum"];
    if (params[@"entrance"])
        self.entrance = [params[@"entrance"] integerValue];
    if (params[@"isTranceTest"])
        self.isTrainTest = [params[@"isTranceTest"] boolValue];
    if (params[@"testStartTime"])
        self.testStartTime = params[@"testStartTime"];
}

- (void)setUserid:(NSString *)userid {
    _userid = userid;
    if (_userid)
        [self.params setObject:userid forKey:@"userid"];
    [self saveTestInfo];
}
- (void)setBikeid:(NSString *)bikeid {
    _bikeid = bikeid;
    if (_bikeid)
        [self.params setObject:bikeid forKey:@"bikeid"];
    [self saveTestInfo];
}
- (void)setDevid:(NSString *)devid {
    _devid = devid;
    if (_devid)
        [self.params setObject:devid forKey:@"devid"];
    [self saveTestInfo];
}
- (void)setIsTrainTest:(BOOL)isTrainTest {
    _isTrainTest = isTrainTest;
    [self.params setObject:[NSNumber numberWithBool:isTrainTest] forKey:@"isTrainTest"];
    [self saveTestInfo];
}
- (void)setPhoneNum:(NSString *)phoneNum {
    _phoneNum = phoneNum;
    if (_phoneNum)
        [self.params setObject:phoneNum forKey:@"phoneNum"];
    [self saveTestInfo];
}
- (void)setTestStartTime:(NSString *)testStartTime {
    _testStartTime = testStartTime;
    if (_testStartTime)
        [self.params setObject:testStartTime forKey:@"testStartTime"];
    [self saveTestInfo];
}

- (void)saveTestInfo {
    if (_userid && _bikeid && _devid && self.params) {
        [[G100InfoHelper shareInstance] updatePushTestResultWithUserid:_userid
                                                                bikeid:_bikeid
                                                                devid:_devid
                                                                params:self.params.copy];
    }
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    self.baseVC = vc;
    self.baseView = view;
    self.animation = animation;
    
    if (![self superview]) {
        [view addSubview:self];
    }
    
    [self tl_layoutWithEntrance:self.entrance];
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:vc animation:animation];
    
    // 结束测试
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

@end
