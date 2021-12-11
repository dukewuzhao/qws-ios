//
//  G100TestConfirmViewController.m
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100TestConfirmViewController.h"
#import "G100CountDownView.h"
#import "G100AlertConfirmClickView.h"
#import "G100AlertCancelClickView.h"
#import "G100DevApi.h"
#import "G100WebViewController.h"
#import "G100UrlManager.h"
#define TEST_WAITING_TIME 30.0

@interface G100TestConfirmViewController () <CountDownEndDelegate> {
    BOOL hasfinishedCountDown;  // 计时结束标志
    BOOL canStartTest;  // 是否可以开始测试 (在App报警时使用)
}

@property (strong, nonatomic) IBOutlet UIView *countDownBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *sampleImageView;
@property (strong, nonatomic) G100CountDownView * countDownView;

@property (strong, nonatomic) IBOutlet UILabel *tipsLabel;

@property (strong, nonatomic) IBOutlet G100AlertConfirmClickView *receivedClickView;
@property (strong, nonatomic) IBOutlet G100AlertCancelClickView *unreceivedClickView;
@property (strong, nonatomic) IBOutlet G100AlertCancelClickView *endTestClickView;

@property (nonatomic, assign) BOOL hasNextItem;//!< 是否还有下一项测试
@property (nonatomic, copy) NSString *testStartTime;//!<开始测试时间

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation G100TestConfirmViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNStartNotificationTest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNAppTestRecievedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    DLog(@"报警测试确定页面销毁");
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!_params) {
        _params = [[NSMutableDictionary alloc] init];
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        if (!_params) {
            _params = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        if (!_params) {
            _params = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.substanceViewtoBottomConstraint.constant = kBottomPadding;
    
    self.navigationBarView.leftBarButton.hidden = YES;
    self.countDownBackgroundView.hidden = YES;
    
    canStartTest = YES;
    switch (self.entrance) {
        case 1:
        {
            [self setNavigationTitle:@"App报警通知测试"];
            self.tipsLabel.text = @"请将App切至后台，并稍等片刻，收到报警消息推送后，点击推送返回App。";
            
            self.receivedClickView.hidden = YES;
            self.unreceivedClickView.hidden = YES;
            self.sampleImageView.hidden = YES;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startNotificationTest) name:kGNStartNotificationTest object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecievedRemoteTestPush) name:kGNAppTestRecievedNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(appDidEnterBackgroundNotif:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(appWillEnterForeground:)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
            
            [self.countDownBackgroundView addSubview:self.countDownView];
            [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
            break;
        case 2:
        {
            [self setNavigationTitle:@"微信报警通知测试"];
            self.tipsLabel.text = @"请稍等片刻，然后确认是否已收到（微信）的报警通知？";
            
            self.sampleImageView.hidden = YES;
        }
            
            break;
        case 3:
        {
            [self setNavigationTitle:@"电话报警通知测试"];
            self.tipsLabel.text = @"请稍等片刻，然后确认是否已收到骑卫士安全提醒电话？";
            
            self.sampleImageView.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    if (self.testStartTime.length == 0) { // 不在测试过程中
        /**
        if (self.entrance != 1) { //微信和电话测试初始发送本地通知
            [self sendLocalNotification];
        }*/
    }else{ // 在测试过程中
        NSDate * startTimeDate =[[NSDateFormatter defaultDateFormatter] dateFromString:self.testStartTime];
        NSTimeInterval past_time = [[NSDate date] timeIntervalSinceDate:startTimeDate];
        if (self.entrance == 1) {
            canStartTest = NO;
            if (past_time >= TEST_WAITING_TIME) { // 超过等待时间
                [self.countDownView setTotalSecondTime:TEST_WAITING_TIME left_time:0];
                hasfinishedCountDown = YES;
                
                self.receivedClickView.hidden = NO;
                self.unreceivedClickView.hidden = NO;
            }else{ // 还未超过等待时间
                
                self.receivedClickView.hidden = NO;
                self.unreceivedClickView.hidden = NO;
                [self.countDownView setTotalSecondTime:TEST_WAITING_TIME left_time:TEST_WAITING_TIME - past_time];
                [self.countDownView startTimer];
            }
            self.countDownBackgroundView.hidden = NO;
        }
    }
    
    [self setupView];
    
    // 点击回调处理
    __weak G100TestConfirmViewController * wself = self;
    self.receivedClickView.confirmClickBlock = ^(){ // 已收到
        [wself cancelLocalNotification];
        if (wself.hasNextItem) {
            if (wself.completion) {
                wself.completion();
            }
        }
        [wself.navigationController popViewControllerAnimated:YES];
    };
    self.unreceivedClickView.cancelClickBlock = ^(){ // 未收到
        [wself cancelLocalNotification];
        //跳转帮助页面
        G100WebViewController *webVC = [G100WebViewController loadNibWebViewController];
        webVC.whenWebCloseTodoEventBlock = ^(void (^result)()){
            if (result) {
                result();
            }
            [wself resetView];
        };
        G100UrlManager *manager = [G100UrlManager sharedInstance];
        webVC.userid = wself.userid;
        if (wself.entrance == 1) {
            webVC.httpUrl = [manager getAppAlarmHelpUrl];
        }else if (wself.entrance == 2) {
            webVC.httpUrl = [manager getWeChatAlarmHelpUrl];
        }else if (wself.entrance == 3) {
            webVC.httpUrl = [manager getPhoneAlarmHelpUrl];
        }
        [wself.navigationController pushViewController:webVC animated:YES];
    };
    self.endTestClickView.cancelClickBlock = ^(){ // 结束测试
        [wself cancelLocalNotification];
        if (wself.hasNextItem) {
            if (wself.completion) {
                wself.completion();
            }
        }
        [wself.navigationController popViewControllerAnimated:YES];
    };
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.countDownView pauseTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 禁用侧滑
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (G100CountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[G100CountDownView alloc]init];
        _countDownView.delegate = self;
        [_countDownView setTotalSecondTime:TEST_WAITING_TIME];
    }
    return _countDownView;
}

#pragma mark - CountDownEndDelegate
- (void)didEndCountDownOfView:(G100CountDownView *)countDownView {
    hasfinishedCountDown = YES;
    [self setupView];
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}
- (void)didPauseCountDownOfView:(G100CountDownView *)countDownView {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}
- (void)didStopCountDownOfView:(G100CountDownView *)countDownView {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

#pragma mark - Private Method
- (void)resetView { // 重新测试
    if (self.entrance == 1) {
        hasfinishedCountDown = NO;
        self.tipsLabel.text = @"请将App切至后台，并稍等片刻，收到报警消息推送后，点击推送返回App。";
        [self.countDownView setTotalSecondTime:TEST_WAITING_TIME];
        self.receivedClickView.hidden = YES;
        self.unreceivedClickView.hidden = YES;
        self.countDownBackgroundView.hidden = YES;
        [self setupView];
        canStartTest = YES;
        
    }else{
        self.tipsLabel.text = @"请稍候...";
        
        __weak G100TestConfirmViewController *wself = self;
        if (self.entrance == 2) {
            
            [[G100DevApi sharedInstance] testAlarmNotifyWithBikeid:wself.bikeid devid:self.devid type:2 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    wself.testStartTime = [[NSDateFormatter defaultDateFormatter] stringFromDate:[NSDate date]];
                    wself.tipsLabel.text = @"报警通知已重新发送\n您是否确认已收到（微信）的报警通知？";
                    [wself sendLocalNotification];
                }else
                    [wself showHint:response.errDesc];
            }];
        }else if (self.entrance == 3) {
            
            [[G100DevApi sharedInstance] testAlarmNotifyWithBikeid:wself.bikeid devid:self.devid type:3 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    wself.testStartTime = [[NSDateFormatter defaultDateFormatter] stringFromDate:[NSDate date]];
                    wself.tipsLabel.text = @"报警通知已重新发送\n您是否确认已收到（电话）的报警通知？";
                    [wself sendLocalNotification];
                }else
                    [wself showHint:response.errDesc];
            }];
        }
    }
}

- (BOOL)isHasNextItem {
    // 判断是否还有下一项
    if (!_isTrainTest) {
        return NO;
    }else if (_entrance == 1 || _entrance == 2) {
        return YES;
    }else{
        return NO;
    }
}

- (void)setupView {
    [self.receivedClickView.confirmButton setTitle:@"已收到" forState:UIControlStateNormal];
    [self.unreceivedClickView.cancelButton setTitle:@"未收到" forState:UIControlStateNormal];
    NSString * btnTitle;
    if (self.hasNextItem) {
        if (self.entrance == 1) {
            btnTitle = @"跳过App报警测试";
        }else if (self.entrance == 2) {
            btnTitle = @"跳过微信报警测试";
        }
    }else{
        btnTitle = @"结束测试";
    }
    [self.endTestClickView.cancelButton setTitle:btnTitle forState:UIControlStateNormal];
    
    if (_entrance == 1) {
        if (hasfinishedCountDown) {
            [self.unreceivedClickView.cancelButton setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            self.unreceivedClickView.cancelButton.layer.borderUIColor = MyOrangeColor;
            self.unreceivedClickView.cancelButton.enabled = YES;
            
        }else{
            [self.unreceivedClickView.cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.unreceivedClickView.cancelButton.layer.borderUIColor = [UIColor lightGrayColor];
            self.unreceivedClickView.cancelButton.enabled = NO;
        }
    }
}

#pragma mark - 收到测试推送消息
- (void)didRecievedRemoteTestPush {
    [self.countDownView pauseTimer];
    [self cancelLocalNotification];
}

- (void)startNotificationTest {
    if (canStartTest) {
        //发送测试指令
        __weak G100TestConfirmViewController *wself = self;
        [[G100DevApi sharedInstance] testAlarmNotifyWithBikeid:wself.bikeid devid:self.devid type:1 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (requestSuccess) {
                self.countDownBackgroundView.hidden = NO;
                [wself.countDownView startTimer];
                wself.tipsLabel.text = @"您是否确认已收到（App推送）的报警通知？";
                wself.receivedClickView.hidden = NO;
                wself.unreceivedClickView.hidden = NO;
                
                wself.testStartTime = [[NSDateFormatter defaultDateFormatter] stringFromDate:[NSDate date]];
                NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
                //便利这个数组 根据 key 拿到我们想要的 UILocalNotification
                NSMutableArray * notiIdArr = [NSMutableArray array];
                for (UILocalNotification * loc in array) {
                    [notiIdArr addObject:[loc.userInfo objectForKey:@"id"]];
                }
                if (![notiIdArr containsObject:kGNAppTestTimeUpNotification]) {
                    [wself sendLocalNotification];
                }
                canStartTest = NO;
            }else{
                [wself showHint:response.errDesc];
            }
        }];

    }
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif {
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        [self endBackgroundTask];
    }];
}

- (void)appWillEnterForeground:(NSNotification*)notif {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

- (void)endBackgroundTask {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    G100TestConfirmViewController *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        
        G100TestConfirmViewController *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.countDownView.m_timer invalidate];// 停止定时器
            
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            // 销毁后台任务标识符
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}

// 模拟的一个 Long-Running Task 方法
- (void)timerMethod:(NSTimer *)paramSender {
    // backgroundTimeRemaining 属性包含了程序留给的我们的时间
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        
    [self.countDownView.m_timer invalidate]; // 停止定时器
}

#pragma mark - 发送本地通知
- (void)sendLocalNotification {
    UILocalNotification * notification = [[UILocalNotification alloc]init];
    NSDate *now=[NSDate new];
    notification.fireDate=[now dateByAddingTimeInterval:TEST_WAITING_TIME+30];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    NSString * notiType;
    if (self.entrance == 1) {
        notification.alertBody=@"App测试通知已发出，您可进入App继续完成测试。";
        notiType = kGNAppTestTimeUpNotification;
    }else if (self.entrance == 2) {
        notification.alertBody=@"微信测试通知已发出，您可进入App继续完成测试。";
        notiType = kGNWechatTestTimeUpNotification;
    }else if (self.entrance == 3) {
        notification.alertBody=@"电话测试通知已发出，您可进入App继续完成测试。";
        notiType = kGNPhoneTestTimeUpNotification;
    }
    
    notification.alertAction = @"进入App";
    
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:notiType,@"id", nil];
    notification.userInfo = infoDic;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - 取消本地通知
- (void)cancelLocalNotification {
    [self clearTestInfo];// 删除本地测试信息
    
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //便利这个数组 根据 key 拿到我们想要的 UILocalNotification
    if (self.entrance == 1) {
        for (UILocalNotification * loc in array) {
            if ([[loc.userInfo objectForKey:@"id"]isEqualToString:kGNAppTestTimeUpNotification]) {
                //取消 本地推送
                [[UIApplication sharedApplication]cancelLocalNotification:loc];
            }
        }
    }else if (self.entrance == 2) {
        for (UILocalNotification * loc in array) {
            if ([[loc.userInfo objectForKey:@"id"]isEqualToString:kGNWechatTestTimeUpNotification]) {
                //取消 本地推送
                [[UIApplication sharedApplication]cancelLocalNotification:loc];
            }
        }
    }else if (self.entrance == 3) {
        for (UILocalNotification * loc in array) {
            if ([[loc.userInfo objectForKey:@"id"]isEqualToString:kGNPhoneTestTimeUpNotification]) {
                //取消 本地推送
                [[UIApplication sharedApplication]cancelLocalNotification:loc];
            }
        }
    }
}

#pragma mark - setter/getter
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
- (void)setEntrance:(NSInteger)entrance {
    _entrance = entrance;
    [self.params setObject:[NSNumber numberWithInteger:entrance] forKey:@"entrance"];
    [self saveTestInfo];
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

#pragma mark - 测试过程持久化
- (void)saveTestInfo {
    if (_userid && _bikeid && _devid && self.params) {
        [[G100InfoHelper shareInstance] updatePushTestResultWithUserid:_userid
                                                                bikeid:_bikeid
                                                                devid:_devid
                                                                params:self.params.copy];
    }
}

- (void)clearTestInfo {
    if (_userid && _bikeid && _devid) {
        [[G100InfoHelper shareInstance] updatePushTestResultWithUserid:_userid
                                                                bikeid:_bikeid
                                                                devid:_devid
                                                                params:nil];
    }
}

@end
