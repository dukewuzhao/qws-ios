//
//  NotificationHelper.m
//  G100
//
//  Created by Tilink on 15/9/16.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "NotificationHelper.h"
#import <UserNotifications/UserNotifications.h>
#import "JPUSHService.h"

#import "G100PushMsgAddvalDomain.h"

#import "SoundManager.h"
#import "BindApplicationView.h"
#import "G100PopView.h"
#import "G100ReactivePopingView+GrabLoginView.h"

#import "G100DevLogsViewController.h"
#import "G100DevGPSViewController.h"
#import "G100MyOrderViewController.h"
#import "G100HomeSetViewController.h"
#import "G100MsgDomain.h"
#import "DatabaseOperation.h"

#import "G100WebViewController.h"
#import "G100Mediator+Login.h"
#import "G100Mediator+GPS.h"
#import "UpdateNotificationHelper.h"

NSString * const NHRemoteNotiCategoryIdentifierSeriousAlarm = @"qws_serious_alarm";
NSString * const NHRemoteNotiActionIdentifierSeriousAlarmIgnore = @"qws_ignore";
NSString * const NHRemoteNotiActionIdentifierSeriousAlarmCheckDetail = @"qws_check_detail";

@interface NotificationHelper () <JPUSHRegisterDelegate>

/** 程序是否完全激活 指的是广告结束 完全进入首页以后*/
@property (nonatomic, assign) BOOL appHasActived;
/** 程序实例*/
@property (nonatomic, strong) UIApplication *app;
/** 推送信息*/
@property (nonatomic, strong) NSDictionary *userinfo;
/** 程序实例 for 离线消息*/
@property (nonatomic, strong) UIApplication *app2;
/** 推送信息 for 离线消息*/
@property (nonatomic, strong) NSNotification *noti;
/** 离线未处理的消息*/
@property (strong, nonatomic) NSMutableArray *offlineMsgArray;

@end

@implementation NotificationHelper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidSetupNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFServiceErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNDIDShowMainView object:nil];
}

+ (instancetype)shareInstance {
    static NotificationHelper * instance;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        instance = [[self alloc] init];
        instance.appHasActived = NO;
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // 监听消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkDidSetup:)
                                                     name:kJPFNetworkDidSetupNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkDidClose:)
                                                     name:kJPFNetworkDidCloseNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkDidLogin:)
                                                     name:kJPFNetworkDidLoginNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkDidRegister:)
                                                     name:kJPFNetworkDidRegisterNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkServiceError:)
                                                     name:kJPFServiceErrorNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkDidReceiveMessage:)
                                                     name:kJPFNetworkDidReceiveMessageNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tl_mainViewDidShow:)
                                                     name:kGNDIDShowMainView
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - 监听处理
- (void)networkDidSetup:(NSNotification *)notification {
    DLog(@"极光推送-建立连接！！！");
}
- (void)networkDidClose:(NSNotification *)notification {
    DLog(@"极光推送-关闭连接！！！");
}
- (void)networkDidLogin:(NSNotification *)notification {
    DLog(@"极光推送-登陆成功！！！");
    if ([JPUSHService registrationID] && [JPUSHService registrationID].length) {
        [G100InfoHelper shareInstance].bchannelid = [JPUSHService registrationID];
        DLog(@"[JPUSHService registrationID] : get RegistrationID:%@", [JPUSHService registrationID]);  //获取registrationID
    }
    NSString * regid = [[notification userInfo] valueForKey:@"RegistrationID"];
    if (regid && regid.length) {
        [G100InfoHelper shareInstance].bchannelid = regid;
        DLog(@"[notification userInfo] : get RegistrationID:%@", regid);  //获取registrationID
    }
}
- (void)networkDidRegister:(NSNotification *)notification {
    DLog(@"极光推送-注册成功！！！");
    if ([JPUSHService registrationID] && [JPUSHService registrationID].length) {
        [G100InfoHelper shareInstance].bchannelid = [JPUSHService registrationID];
        DLog(@"[JPUSHService registrationID] : get RegistrationID:%@", [JPUSHService registrationID]);  //获取registrationID
    }
    NSString * regid = [[notification userInfo] valueForKey:@"RegistrationID"];
    if (regid && regid.length) {
        [G100InfoHelper shareInstance].bchannelid = regid;
        DLog(@"[notification userInfo] : get RegistrationID:%@", regid);  //获取registrationID
    }
}
- (void)networkServiceError:(NSNotification *)notification {
    DLog(@"极光推送-发生错误！！！");
}
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *dict = [[notification userInfo] objectForKey:@"extras"];
    G100PushMsgDomain *offlineMsg = [[G100PushMsgDomain alloc] initWithDictionary:dict];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[NotificationHelper shareInstance] application:[UIApplication sharedApplication] didReceiveJPushOfflineMessage:notification];
    }else if (offlineMsg) {
        [self.offlineMsgArray addObject:notification];
    }
}

- (void)tl_mainViewDidShow:(NSNotification *)notification {
    _appHasActived = YES;
    
    if (_app && _userinfo) {
        [self application:self.app didReceiveJPushRemoteNotification:self.userinfo];
        self.app = nil;
        self.userinfo = nil;
    }
    
    if (_app2 && _noti) {
        [self application:self.app2 didReceiveJPushOfflineMessage:self.noti];
        self.app2 = nil;
        self.noti = nil;
    }
    
    [self nh_handleOfflineNotis:[UIApplication sharedApplication]];
}

#pragma mark - Lazy load
- (NSMutableArray *)offlineMsgArray {
    if (!_offlineMsgArray) {
        self.offlineMsgArray = [[NSMutableArray alloc] init];
    }
    return _offlineMsgArray;
}

#pragma mark - 推送设置
- (BOOL)notificationServicesEnabled {
    BOOL isEnabled = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            isEnabled = NO;
        } else {
            isEnabled = YES;
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert) {
            isEnabled = YES;
        } else{
            isEnabled = NO;
        }
    }
    
    return isEnabled;
}

+ (BOOL)openSystemNotificationSettingPage {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        return YES;
    }else {
        return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

+ (BOOL)canOpenSystemNotificationSettingPage {
    return YES;
}

#pragma mark - 本地通知相关
- (void)removeAllLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)removeLocalNotificationByKey:(NSString *)notificationKey {
    // 取出全部本地通知
    NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    // 设置要移除的通知id
    NSString *notificationId = notificationKey;
    // 遍历进行移除
    for (UILocalNotification *localNotification in notifications) {
        // 将每个通知的id取出来进行对比
        if ([[localNotification.userInfo objectForKey:@"id"] isEqualToString:notificationId]) {
            // 移除某一个通知
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

#pragma mark - 注册本地通知
- (void)registerLocalNotification:(UIApplication *)application {
    //关键：加上版本的控制
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    //接受按钮
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"checkDetailAction";
    acceptAction.title = @"查看详情";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    //拒绝按钮
    UIMutableUserNotificationAction *rejectAction = [[UIMutableUserNotificationAction alloc] init];
    rejectAction.identifier = @"rejectAction";
    rejectAction.title = @"拒绝";
    rejectAction.activationMode = UIUserNotificationActivationModeBackground;
    rejectAction.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    rejectAction.destructive = YES;
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = @"alert";
    NSArray *actions = @[acceptAction, rejectAction];
    [categorys setActions:actions forContext:UIUserNotificationActionContextMinimal];
    
    // The following line must only run under iOS 8. This runtime check prevents
    // it from running if it doesn't exist (such as running under iOS 7 or earlier).
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithObjects:categorys, nil]];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
#endif
}

#pragma mark - 注册远程推送
- (void)registerRemoteNotification:(UIApplication *)application launchingWithOptions:(NSDictionary *)launchOptions {
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //可以添加自定义categories
        NSMutableSet *categories = [NSMutableSet set];
        UNNotificationAction *actionIgore = [UNNotificationAction actionWithIdentifier:NHRemoteNotiActionIdentifierSeriousAlarmIgnore title:@"忽略" options:UNNotificationActionOptionAuthenticationRequired | UNNotificationActionOptionDestructive];
        UNNotificationAction *actionCheck = [UNNotificationAction actionWithIdentifier:NHRemoteNotiActionIdentifierSeriousAlarmCheckDetail title:@"查看详情" options:UNNotificationActionOptionAuthenticationRequired | UNNotificationActionOptionForeground];
        
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:NHRemoteNotiCategoryIdentifierSeriousAlarm actions:@[ actionIgore, actionCheck ] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        [categories addObject:category];
        
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        entity.categories = categories;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
        
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[ category ]]];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        NSMutableSet *categories = [NSMutableSet set];
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = NHRemoteNotiCategoryIdentifierSeriousAlarm;
        
        UIMutableUserNotificationAction *actionIgore = [[UIMutableUserNotificationAction alloc] init];
        actionIgore.identifier = NHRemoteNotiActionIdentifierSeriousAlarmIgnore;
        actionIgore.title = @"忽略";
        actionIgore.activationMode = UIUserNotificationActivationModeBackground;
        actionIgore.authenticationRequired = YES;
        
        UIMutableUserNotificationAction *actionCheck = [[UIMutableUserNotificationAction alloc] init];
        actionCheck.identifier = NHRemoteNotiActionIdentifierSeriousAlarmCheckDetail;
        actionCheck.title = @"查看详情";
        actionCheck.activationMode = UIUserNotificationActivationModeForeground;
        actionCheck.authenticationRequired = YES;
        
        //YES显示为红色，NO显示为蓝色
        actionIgore.destructive = YES;
        actionCheck.destructive = NO;
        
        NSArray *actions = @[ actionIgore, actionCheck ];
        [category setActions:actions forContext:UIUserNotificationActionContextMinimal];
        [categories addObject:category];
        
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                              categories:categories];
    }else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }

    // Required
    [JPUSHService setupWithOption:launchOptions
                           appKey:JPushKey
                          channel:ISOutSide ? @"AppStore" : @"Test"
                 apsForProduction:ISProduct];
}

- (void)application:(UIApplication *)application didRegisterForJPushRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"---极光推送注册错误---%@", error);
}

#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            //激活状态下不做跳转
            [self application:[UIApplication sharedApplication] didReceiveJPushRemoteNotification:userInfo];
        }
    }
    //需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionAlert);
}
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.content.categoryIdentifier isEqualToString:NHRemoteNotiCategoryIdentifierSeriousAlarm]) {
        if ([response.actionIdentifier isEqualToString:NHRemoteNotiActionIdentifierSeriousAlarmIgnore]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }else if ([response.actionIdentifier isEqualToString:NHRemoteNotiActionIdentifierSeriousAlarmCheckDetail]) {
            [JPUSHService handleRemoteNotification:userInfo];
            [self application:[UIApplication sharedApplication] didReceiveJPushRemoteNotification:userInfo];
        }else {
            [JPUSHService handleRemoteNotification:userInfo];
            [self application:[UIApplication sharedApplication] didReceiveJPushRemoteNotification:userInfo];
        }
    }else {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
            [self application:[UIApplication sharedApplication] didReceiveJPushRemoteNotification:userInfo];
        }else if ([response.notification.request.trigger isKindOfClass:[UNLocationNotificationTrigger class]]) {
            NSString *identifier = response.notification.request.identifier;
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                //激活状态下不做跳转 -> 测试超过等待时间提示
                if ([identifier isEqualToString:kGNAppTestTimeUpNotification]) {
                    
                }else if ([identifier isEqualToString:kGNWechatTestTimeUpNotification]) {
                    
                }else if ([identifier isEqualToString:kGNPhoneTestTimeUpNotification]) {
                    
                }
            }
            [self nh_quickDecreaseBadge];
        }else {
            [JPUSHService handleRemoteNotification:userInfo];
            [self application:[UIApplication sharedApplication] didReceiveJPushRemoteNotification:userInfo];
        }
    }
    // 系统要求执行这个方法
    completionHandler();
}

#pragma mark - 远程推送消息处理
- (void)application:(UIApplication *)application didReceiveJPushRemoteNotification:(NSDictionary *)userInfo {
    if (!self.appHasActived) {
        self.app = application;
        self.userinfo = userInfo;
        return;
    }
    
    [self nh_quickDecreaseBadge];
    DLog(@"远程推送消息：userinfo = %@", userInfo);
    
    if (!IsLogin()) {
        return;
    }
    
    //保存最新一条推送时间
    [[G100InfoHelper shareInstance] updateLastestNotificationTime:[NSDate date]];
    //设置推送长时间未收到提醒次数
    [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"noti_overtime_warning" leftTimes:1];
    
    __weak UIViewController *wself = CURRENTVIEWCONTROLLER;
    //跳转消息中心页面
    G100MsgDomain * msg = [[G100MsgDomain alloc] initWithDictionary:userInfo];
    if (msg.msgtype == 1 || msg.msgtype == 2) {
        NSString *msgUserid = [NSString stringWithFormat:@"%@", @(msg.userid)];
        // 激活状态下不做跳转
        if (application.applicationState != UIApplicationStateActive) {
            [[DatabaseOperation operation] hasReadMsgWithMsg:msg success:^(BOOL success) {
                if (success) {
                    DLog(@"信息读取成功");
                    [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:msgUserid hasRead:OfflineMsgReadStatusRead];
                }else {
                    DLog(@"信息读取失败");
                }
            }];
            
            // 如果是网页就打开webView
            if ([msg.mcurl hasPrefix:@"http"]) {
                G100WebViewController * msgWeb = [[G100WebViewController alloc] initWithNibName:@"G100WebViewController" bundle:nil];
                msgWeb.userid = msgUserid;
                msgWeb.bikeid = msg.bikeid;
                msgWeb.devid = msg.deviceid;
                msgWeb.isAllowInpourJS = YES;
                msgWeb.httpUrl = msg.mcurl;
                [wself.navigationController pushViewController:msgWeb animated:YES];
            }else if ([msg.mcurl hasPrefix:@"qwsapp://"]) {
                // 自定义协议跳转
                [G100Router openURL:msg.mcurl];
            }else {
                G100WebViewController * msgWeb = [G100WebViewController loadNibWebViewController];
                msgWeb.userid = msgUserid;
                msgWeb.bikeid = msg.bikeid;
                msgWeb.devid = msg.deviceid;
                msgWeb.msg_title = msg.mctitle;
                msgWeb.msg_desc = msg.mcdesc;
                msgWeb.filename = @"msg_template.html";
                [wself.navigationController pushViewController:msgWeb animated:YES];
            }
            return;
        }
    }
    
    // 处理接收到的数据
    G100PushMsgDomain * pushDomain = [[G100PushMsgDomain alloc] initWithDictionary:userInfo];
    // 如果收到的消息userid是0 则存为当前用户的id
    if (pushDomain.userid == 0) {
        pushDomain.userid = [[[G100InfoHelper shareInstance] buserid] integerValue];
    }
    // 判断是否是当前用户
    if (pushDomain.userid != [[[G100InfoHelper shareInstance] buserid] integerValue]) {
        return;
    }
    
    NSInteger err = pushDomain.errCode;
    NSString *msgUserid = [NSString stringWithFormat:@"%@", @(pushDomain.userid)];
    NSString *msgBikeid = pushDomain.bikeid;
    NSString *msgDevid  = pushDomain.deviceid;
    if (!pushDomain.deviceid.length) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:msgUserid bikeid:msgBikeid];
        msgDevid = [NSString stringWithFormat:@"%@", @(bikeDomain.mainDevice.device_id)];
    }
    
    // 测试推送消息
    if (err == NOTI_MSG_CODE_TEST_PUSH) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNPresentBigPopBoxView object:self userInfo:userInfo];
        return;
    }
    
    /** 电动车授权 */
    if (err == NOTI_MSG_CODE_DEV_AUTH_TO || err == NOTI_MSG_CODE_DEV_AUTH_FROM) {
        if (application.applicationState == UIApplicationStateActive) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(1007);
        }
        
        if (err == NOTI_MSG_CODE_DEV_AUTH_TO) {
            // 申请绑定 已读
            if (msg.msgtype == 1 || msg.msgtype == 2) {
                [[DatabaseOperation operation] hasReadMsgWithMsg:msg success:^(BOOL success) {
                    if (success) {
                        DLog(@"信息读取成功");
                        [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:msgUserid hasRead:OfflineMsgReadStatusRead];
                    }else {
                        DLog(@"信息读取失败");
                    }
                }];
            }
            
            BindApplicationView * appview = [[[NSBundle mainBundle]loadNibNamed:@"BindApplicationView" owner:self options:nil]lastObject];
            [appview showBindApplicationViewWithVc:wself view:wself.view user:pushDomain buttonClick:nil animated:YES];
        }else {
            if (err == NOTI_MSG_CODE_DEV_AUTH_FROM) {
                //
                NSInteger addval = [pushDomain.addval integerValue];
                if (addval == 1) {
                    // 批准 绑定成功
                    // 绑定成功后 存储一个key值 在用户回到主页的时候 给一个弹窗告诉用户去绑定微信 开通微信报警提醒
                    [[G100InfoHelper shareInstance] updateNewDevBindSuccessWithUserid:msgUserid
                                                                               bikeid:msgBikeid
                                                                                devid:msgDevid
                                                                               params:@{}];
                    
                    // 绑定成功后 回到首页
                    if ([CURRENTVIEWCONTROLLER isKindOfClass:NSClassFromString(@"G100BindDevViewController")]) {
                        [APPDELEGATE.mainNavc popToRootViewControllerAnimated:YES];
                    }
                }else if (addval == 2) {
                    // 拒绝
                    
                }else if (addval == 3) {
                    // 超时
                    
                }else {
                    
                }
            }
            
            G100MAlertIKnow(pushDomain.custtitle, pushDomain.custdesc, YES, nil);
            [[UserManager shareManager] updateBikeListWithUserid:msgUserid updateType:BikeListAddType complete:nil];
        }
        
        return;
    }
    
    /** 绑定成功 失败 */
    if (err == NOTI_MSG_CODE_BIND_SUCCESS || err == NOTI_MSG_CODE_BIND_FAIL) {
        if (err == NOTI_MSG_CODE_BIND_SUCCESS) {
            [[UserManager shareManager] updateBikeListWithUserid:msgUserid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                // 绑定成功后 回到首页
                if ([CURRENTVIEWCONTROLLER isKindOfClass:NSClassFromString(@"G100BindDevViewController")]) {
                    [APPDELEGATE.mainNavc popToRootViewControllerAnimated:YES];
                }
            }];
        }else {
            if (application.applicationState == UIApplicationStateActive) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlaySystemSound(1007);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNDevBindFailed object:nil];
            G100MAlertIKnow(@"绑定失败", pushDomain.custdesc, YES, nil);
            [[UserManager shareManager] updateBikeListWithUserid:msgUserid complete:nil];
        }
        
        return;
    }
    
    /** 主用户解绑车辆 || 主用户删除副用户 */
    if (err == NOTI_MSG_CODE_UNBIND_MAIN || err == NOTI_MSG_CODE_VICE_USER_DELETED) {
        if (application.applicationState == UIApplicationStateActive) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(1007);
        }
        
        if ([CURRENTVIEWCONTROLLER isKindOfClass:[NSClassFromString(@"G100MainViewController") class]]) {
            G100MAlertIKnow(pushDomain.custtitle, pushDomain.custdesc, NO, nil);
        }else {
            G100BaseVC *mainVC = (G100BaseVC *)APPDELEGATE.mainViewController;
            mainVC.schemeBlockExecuted = NO;
            mainVC.schemeOverBlock = ^(){
                G100MAlertIKnow(pushDomain.custtitle, pushDomain.custdesc, NO, nil);
            };
            [APPDELEGATE.mainNavc popToViewController:mainVC animated:YES];
        }
        
        [[UserManager shareManager] updateBikeListWithUserid:msgUserid complete:nil];
        
        return;
    }
    
    /** 支付成功或失败 */
    if (err == NOTI_MSG_CODE_BUY_SERVICE || err == NOTI_MSG_CODE_BUY_INSURANCE) {
        [MozTopAlertView showG100WithType:MozAlertTypeShake leftImage:[UIImage imageNamed:@"ic_user_dev_logo"] text:pushDomain.apsdomain.alert doText:@"查看" doBlock:^{
            G100MyOrderViewController * order = [[G100MyOrderViewController alloc]init];
            [wself.navigationController pushViewController:order animated:YES];
        } parentView:TOP_VIEW];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNPingPPPayResult object:self userInfo:@{@"result" : @"success"}];
        [[UserManager shareManager] updateBikeListWithUserid:msgUserid complete:nil];
        return;
    }
    
    // 判断是否是当前车辆发出警告 若是则不提醒 不是则提醒但不切换设备 用户在实时追踪界面
    if ([CURRENTVIEWCONTROLLER isKindOfClass:[G100DevGPSViewController class]]) {
        G100DevGPSViewController * tmpLocation = (G100DevGPSViewController *)CURRENTVIEWCONTROLLER;
        if ([tmpLocation.userid isEqualToString:msgUserid] &&
            [tmpLocation.bikeid isEqualToString:msgBikeid] &&
            [tmpLocation.devid isEqualToString:msgDevid]) {
            // 是当前查看的车辆
            return;
        }else if ([tmpLocation.devid isEqualToString:msgDevid]) {
            if (err == NOTI_MSG_CODE_BATTERY_OUT ||
                err == NOTI_MSG_CODE_VOLTAGE_LOW ||
                err == NOTI_MSG_CODE_DEV_FAULT ||
                err == NOTI_MSG_CODE_ILLEGAL_DIS ||
                err == NOTI_MSG_CODE_DEV_SHAKE) {
                // do nothing
                
            }else {
                return;
            }
        }
    }
    
    // 设置顶部通知图标
    UIImage *leftImage = [UIImage imageNamed:@"top_shake_icon"];
    switch (err) {
        case NOTI_MSG_CODE_DEV_SHAKE:
        {
            leftImage = [UIImage imageNamed:@"top_shake_icon"];
        }
            break;
        case NOTI_MSG_CODE_SWITCH_OPEN:
        {
            leftImage = [UIImage imageNamed:@"top_open_icon"];
        }
            break;
        case NOTI_MSG_CODE_SWITCH_CLOSE:
        {
            leftImage = [UIImage imageNamed:@"top_open_icon"];
        }
            break;
        case NOTI_MSG_CODE_BATTERY_IN:
        {
            leftImage = [UIImage imageNamed:@"top_elecmove_icon"];
        }
            break;
        case NOTI_MSG_CODE_BATTERY_OUT:
        {
            leftImage = [UIImage imageNamed:@"top_elecmove_icon"];
        }
            break;
        case NOTI_MSG_CODE_VOLTAGE_LOW:
        {
            leftImage = [UIImage imageNamed:@"top_power_icon"];
        }
            break;
        case NOTI_MSG_CODE_DEV_FAULT:
        {
            leftImage = [UIImage imageNamed:@"top_fault_icon"];
        }
            break;
        case NOTI_MSG_CODE_ILLEGAL_DIS:
        {
            leftImage = [UIImage imageNamed:@"top_move_icon"];
        }
            break;
        default:
            break;
    }
    
    // 开关电门 用户可开关
    if (err == NOTI_MSG_CODE_SWITCH_OPEN || err == NOTI_MSG_CODE_SWITCH_CLOSE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNUpdatePower object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNDevAccStatusOnorOff object:self userInfo:userInfo];
        
        // 开关电门 更新电量 电门关不需要提醒
        if (err == NOTI_MSG_CODE_SWITCH_OPEN) {
            G100DeviceDomain *devDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:msgUserid
                                                                                        bikeid:msgBikeid].mainDevice;
            if (devDomain.security.acc_on_notify) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNPresentBigPopBoxView object:self userInfo:userInfo];
                return;
            }else {
                DLog(@"用户关闭了设备%@的推送", msgBikeid);
            }
        }
    }
    
    // 获取当前车辆的设防模式
    G100DeviceDomain *devDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:msgUserid bikeid:msgBikeid].mainDevice;
    G100DeviceSecuritySetting *setDomain = devDomain.security;
    switch (setDomain.mode) {
        case DEV_SECSET_MODE_DISARMING:     // 关闭通知
        {
            // 不通知
            
        }
            break;
        case DEV_SECSET_MODE_WARN:     // 警戒模式
        {
            // 大的pop框
            if (err == NOTI_MSG_CODE_BATTERY_OUT ||
                err == NOTI_MSG_CODE_VOLTAGE_LOW ||
                err == NOTI_MSG_CODE_DEV_FAULT ||
                err == NOTI_MSG_CODE_ILLEGAL_DIS ||
                (err == NOTI_MSG_CODE_DEV_SHAKE && ([pushDomain.addval integerValue] == DEV_SHAKE_SERIOUS || [pushDomain.addval integerValue] == DEV_SHAKE_MEDIUM)) ||
                err == NOTI_MSG_CODE_ALARM_REMOVE ||
                err == NOTI_MSG_CODE_SWITCH_ILLEGAL_OPEN ||
                err == NOTI_MSG_CODE_MATCH_FAULT ||
                err == NOTI_MSG_CODE_COMM_FAULT ||
                err == NOTI_MSG_CODE_SOS_HANDLE)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNPresentBigPopBoxView object:self userInfo:userInfo];
                
                return;
            }
            
            if ((err == NOTI_MSG_CODE_DEV_SHAKE && ([pushDomain.addval integerValue] == DEV_SHAKE_LIGHT))
                || err == NOTI_MSG_CODE_BATTERY_IN)
            {
                // 震动警告 -》 提醒用户进入实时追踪界面查看
                if (application.applicationState == UIApplicationStateActive) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(1007);
                }
                
                [MozTopAlertView showG100WithType:MozAlertTypeShake leftImage:leftImage text:pushDomain.apsdomain.alert doText:@"查看" doBlock:^{
                    UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:msgUserid
                                                                                                                 bikeid:msgBikeid
                                                                                                                  devid:msgDevid];
                    [wself.navigationController pushViewController:viewController animated:YES];
                } parentView:TOP_VIEW];
                
                return;
            }
        }
            break;
        case DEV_SECSET_MODE_STANDARD:     // 标准模式
        {
            // 大的pop框
            if (err == NOTI_MSG_CODE_BATTERY_OUT ||
                err == NOTI_MSG_CODE_DEV_FAULT ||
                err == NOTI_MSG_CODE_ILLEGAL_DIS ||
                (err == NOTI_MSG_CODE_DEV_SHAKE && [pushDomain.addval integerValue] == DEV_SHAKE_SERIOUS) ||
                err == NOTI_MSG_CODE_ALARM_REMOVE ||
                err == NOTI_MSG_CODE_SWITCH_ILLEGAL_OPEN ||
                err == NOTI_MSG_CODE_MATCH_FAULT ||
                err == NOTI_MSG_CODE_COMM_FAULT ||
                err == NOTI_MSG_CODE_SOS_HANDLE)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNPresentBigPopBoxView object:self userInfo:userInfo];
                
                return;
            }
            
            if ((err == NOTI_MSG_CODE_DEV_SHAKE && ([pushDomain.addval integerValue] == DEV_SHAKE_MEDIUM)) ||
                err == NOTI_MSG_CODE_VOLTAGE_LOW)
            {
                // 震动警告 -》 提醒用户进入实时追踪界面查看
                if (application.applicationState == UIApplicationStateActive) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(1007);
                }
                
                [MozTopAlertView showG100WithType:MozAlertTypeShake leftImage:leftImage text:pushDomain.apsdomain.alert doText:@"查看" doBlock:^{
                    UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:msgUserid
                                                                                                                 bikeid:msgBikeid
                                                                                                                  devid:msgDevid];
                    [wself.navigationController pushViewController:viewController animated:YES];
                } parentView:TOP_VIEW];
                
                return;
            }
            
            // 软件报告内提醒
            if ((err == NOTI_MSG_CODE_DEV_SHAKE && ([pushDomain.addval integerValue] == DEV_SHAKE_LIGHT)) ||
                err == NOTI_MSG_CODE_BATTERY_IN)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNShakeComeFromServer object:nil];
                
                return;
            }
        }
            break;
        case DEV_SECSET_MODE_NODISTURB:     // 免打扰模式
        {
            // 大的pop框
            if (err == NOTI_MSG_CODE_BATTERY_OUT ||
                err == NOTI_MSG_CODE_ILLEGAL_DIS ||
                (err == NOTI_MSG_CODE_DEV_SHAKE && [pushDomain.addval integerValue] == DEV_SHAKE_SERIOUS) ||
                err == NOTI_MSG_CODE_ALARM_REMOVE ||
                err == NOTI_MSG_CODE_SWITCH_ILLEGAL_OPEN ||
                err == NOTI_MSG_CODE_MATCH_FAULT ||
                err == NOTI_MSG_CODE_COMM_FAULT ||
                err == NOTI_MSG_CODE_SOS_HANDLE ||
                err == NOTI_MSG_CODE_DEV_FAULT)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNPresentBigPopBoxView object:self userInfo:userInfo];
                
                return;
            }
            
            // 软件报告内提醒
            if ((err == NOTI_MSG_CODE_DEV_SHAKE && ([pushDomain.addval integerValue] == DEV_SHAKE_LIGHT || [pushDomain.addval integerValue] == DEV_SHAKE_MEDIUM)) ||
                err == NOTI_MSG_CODE_BATTERY_IN ||
                err == NOTI_MSG_CODE_VOLTAGE_LOW ||
                err == NOTI_MSG_CODE_DEV_FAULT)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNShakeComeFromServer object:nil];
                
                return;
            }
        }
            break;
        case DEV_SECSET_MODE_DEVLOST:     // 寻车模式
        {
            // 寻车模式
            if (err == NOTI_MSG_CODE_SWITCH_OPEN ||
                err == NOTI_MSG_CODE_SWITCH_CLOSE ||
                err == NOTI_MSG_CODE_BATTERY_OUT ||
                err == NOTI_MSG_CODE_LOST_DIS)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNPresentBigPopBoxView object:self userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNLostBikeAlarmComeFromServer object:self userInfo:userInfo];
                
                return;
            }
        }
            break;
        default:
            break;
    }
    
    // 报警器设置成功或失败后的推送
    if (err == NOTI_MSG_CODE_ALARM_HANDLE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNRemoteAlarmHandleMsg object:nil userInfo:nil];
        return;
    }
    
    // 设置家的位置推送或低电量离家距离提醒
    if (err == NOTI_MSG_CODE_SETHOME_NOTIFY || err == NOTI_MSG_CODE_GOHOMEDISTANCE_NOTIFY) {
        if (application.applicationState == UIApplicationStateActive) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(1007);
        }
        for (UIView *subView in wself.view.subviews) {
            if ([subView isKindOfClass:[G100HomeSetPopingView class]]) {
                [subView removeFromSuperview];
            }
        }
        G100HomeSetPopingView *homeSetView = [G100HomeSetPopingView popingViewWithHomeSetView];
        if (err == NOTI_MSG_CODE_SETHOME_NOTIFY) {
            [homeSetView showPopingViewWithImage:[UIImage imageNamed:@"ic_home_set"] topContent:nil bottomContent:nil confirmTitle:@"设置家的地址" otherTitle:@"关闭" clickEvent:^() {
                G100HomeSetViewController *homeSet = [[G100HomeSetViewController alloc] init];
                homeSet.userid = msgUserid;
                [wself.navigationController pushViewController:homeSet animated:YES];
                
            } onViewController:wself onBaseView:wself.view];
        }else if (err == NOTI_MSG_CODE_GOHOMEDISTANCE_NOTIFY){
            NSDictionary * addval = [pushDomain.addval mj_JSONObject];
            NSString *distance1 = [NSString stringWithFormat:@"剩余里程%@公里",[addval objectForKey:@"endurance"]];
            NSString *distance2 = [NSString stringWithFormat:@"离家还有%@公里",[addval objectForKey:@"distance"]];
           [homeSetView showPopingViewWithImage:[UIImage imageNamed:@"ic_home_back"] topContent:distance1 bottomContent:distance2 confirmTitle:@"我知道了" otherTitle:nil clickEvent:nil onViewController:wself onBaseView:wself.view];
        }
        return;
    }
    if (err == NOTI_MSG_CODE_UPGRADE__SUCCESS_NOTIFY ||
        err == NOTI_MSG_CODE_UPGRADE__DOWNLOAD_TIMEOUT_NOTIFY ||
        err == NOTI_MSG_CODE_UPGRADE_TIMEOUT_NOTIFY ||
        err == NOTI_MSG_CODE_UPGRADE_FAIL_NOTIFY) {
        //升级通知
        [[UpdateNotificationHelper shareInstance]application:application didReceiveJPushRemoteNotification:userInfo];
        return;
    }
    
    // 剩余的都是其他未知的推送 直接显示出来
    if (err == NOTI_MSG_CODE_DEFAULT_NOTIFY) {
        /**
         * {
         *  "showdialog": 0, // 显示弹窗 0不显示 1显示
         *  "oktext" : "立即查看", // 确定按钮文本
         *  "canceltext": "忽略", // 取消按钮文本
         * }
         *
         */
        
        G100PushMsgAddvalDomain *addval = [[G100PushMsgAddvalDomain alloc] initWithDictionary:[pushDomain.addval mj_JSONObject]];
        if (addval.showdialog) {
            
            if (addval.oktext.length && addval.canceltext.length) {
                if (application.applicationState == UIApplicationStateActive) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(1007);
                }
                
                [MyAlertView MyAlertWithTitle:pushDomain.custtitle message:pushDomain.custdesc delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        if (msg.msgtype == 1 || msg.msgtype == 2) {
                            [[DatabaseOperation operation] hasReadMsgWithMsg:msg success:^(BOOL success) {
                                if (success) {
                                    DLog(@"信息读取成功");
                                    [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:msgUserid hasRead:OfflineMsgReadStatusRead];
                                }else {
                                    DLog(@"信息读取失败");
                                }
                            }];
                        }
                        
                        NSString *url = msg.page.length ? msg.page : msg.mcurl;
                        if ([G100Router canOpenURL:url]) {
                            [G100Router openURL:url];
                        }
                    }
                } cancelButtonTitle:addval.canceltext otherButtonTitles:addval.oktext];
                return;
            }else if (addval.canceltext.length && !addval.oktext.length) {
                if (application.applicationState == UIApplicationStateActive) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(1007);
                }
                
                [MyAlertView MyAlertWithTitle:pushDomain.custtitle message:pushDomain.custdesc delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                    if (msg.msgtype == 1 || msg.msgtype == 2) {
                        [[DatabaseOperation operation] hasReadMsgWithMsg:msg success:^(BOOL success) {
                            if (success) {
                                DLog(@"信息读取成功");
                                [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:msgUserid hasRead:OfflineMsgReadStatusRead];
                            }else {
                                DLog(@"信息读取失败");
                            }
                        }];
                    }
                    
                } cancelButtonTitle:addval.canceltext otherButtonTitles:nil];
                return;
            }
        }
    }
    
    // 需要做页面跳转
    if (pushDomain.action != 0) {
        if (application.applicationState != UIApplicationStateActive) { // 激活状态下不做跳转
            if (msg.msgtype == 1 || msg.msgtype == 2) {
                [[DatabaseOperation operation] hasReadMsgWithMsg:msg success:^(BOOL success) {
                    if (success) {
                        DLog(@"信息读取成功");
                        [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:msgUserid hasRead:OfflineMsgReadStatusRead];
                    }else {
                        DLog(@"信息读取失败");
                    }
                }];
            }
            
            NSString *url = msg.page.length ? msg.page : msg.mcurl;
            if ([G100Router canOpenURL:url]) {
                [G100Router openURL:url];
            }
        }else {
            if (application.applicationState == UIApplicationStateActive) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlaySystemSound(1007);
            }
            
            [MyAlertView MyAlertWithTitle:pushDomain.custtitle message:pushDomain.custdesc delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    if (msg.msgtype == 1 || msg.msgtype == 2) {
                        [[DatabaseOperation operation] hasReadMsgWithMsg:msg success:^(BOOL success) {
                            if (success) {
                                DLog(@"信息读取成功");
                                [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:msgUserid hasRead:OfflineMsgReadStatusRead];
                            }else {
                                DLog(@"信息读取失败");
                            }
                        }];
                    }
                    
                    NSString *url = msg.page.length ? msg.page : msg.mcurl;
                    if ([G100Router canOpenURL:url]) {
                        [G100Router openURL:url];
                    }
                }
            } cancelButtonTitle:@"忽略" otherButtonTitles:@"立即查看"];
        }
    }
}

#pragma mark - 极光离线消息处理
- (void)application:(UIApplication *)application didReceiveJPushOfflineMessage:(NSNotification *)notification {
    if (!self.appHasActived) {
        self.app2 = application;
        self.noti = notification;
        return;
    }
    
    NSDictionary *dict = [[notification userInfo] objectForKey:@"extras"];
    DLog(@"极光离线消息：dict = %@", dict);
    if (!IsLogin()) {
        return;
    }
    
    G100PushMsgDomain * offlineMsg = [[G100PushMsgDomain alloc] initWithDictionary:dict];
    NSString *offlineMsgUserid = [NSString stringWithFormat:@"%@", @(offlineMsg.userid)];
    
    // 向数据库存储消息
    G100MsgDomain * msgDomain = [[G100MsgDomain alloc] initWithDictionary:dict];
    if (msgDomain.msgtype == 1 || msgDomain.msgtype == 2) {
        [[DatabaseOperation operation] insertDatabaseWithMsg:msgDomain success:^(BOOL success) {
            if (success) {
                DLog(@"极光离线消息存储成功");
                [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:offlineMsgUserid hasRead:OfflineMsgReadStatusUnread];
                
            }else{
                DLog(@"极光离线消息存储失败");
            }
        }];
    }
    
    // 判断是否是当前用户
    if (![offlineMsgUserid isEqualToString:[[G100InfoHelper shareInstance] buserid]]) {
        return;
    }
    
    NSInteger offlineMsgCode = offlineMsg.errCode;
    NSInteger offlineMsgAddval = [offlineMsg.addval integerValue];
    NSString *offlineMsgBikeid = offlineMsg.bikeid;
    NSString *offlineMsgDevid  = offlineMsg.deviceid;
    
    if (!offlineMsg.deviceid.length) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:offlineMsgUserid bikeid:offlineMsgBikeid];
        offlineMsgDevid = [NSString stringWithFormat:@"%@", @(bikeDomain.mainDevice.device_id)];
    }
    
    // 报警器设置成功或失败后的推送
    if (offlineMsgCode == NOTI_MSG_CODE_ALARM_HANDLE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNRemoteAlarmHandleMsg object:nil userInfo:nil];
        return;
    }
    
    // 获取当前车辆的设防模式
    G100DeviceDomain *devDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:offlineMsgUserid bikeid:offlineMsgBikeid].mainDevice;
    G100DeviceSecuritySetting *setDomain = devDomain.security;

    switch (setDomain.mode) {
        case DEV_SECSET_MODE_DISARMING: // 关闭通知
        {
            
        }
            break;
        case DEV_SECSET_MODE_WARN: // 警戒模式
        {
            
        }
            break;
        case DEV_SECSET_MODE_STANDARD: // 标准模式
        {
            // 用车报告内提醒
            if ((offlineMsgCode == NOTI_MSG_CODE_DEV_SHAKE && (offlineMsgAddval == DEV_SHAKE_SERIOUS)) ||
                offlineMsgCode == NOTI_MSG_CODE_BATTERY_IN) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNShakeComeFromServer object:nil];
            }
        }
            break;
        case DEV_SECSET_MODE_NODISTURB: // 免打扰模式
        {
            // 用车报告内提醒
            if ((offlineMsgCode == NOTI_MSG_CODE_DEV_SHAKE && (offlineMsgAddval != DEV_SHAKE_SERIOUS)) ||
                offlineMsgCode == NOTI_MSG_CODE_BATTERY_IN ||
                offlineMsgCode == NOTI_MSG_CODE_VOLTAGE_LOW ||
                offlineMsgCode == NOTI_MSG_CODE_DEV_FAULT ) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNShakeComeFromServer object:nil];
            }
        }
            break;
        case DEV_SECSET_MODE_DEVLOST: // 寻车模式
        {
            // 寻车模式
            if (offlineMsgCode == NOTI_MSG_CODE_SWITCH_OPEN ||
                offlineMsgCode == NOTI_MSG_CODE_SWITCH_CLOSE ||
                offlineMsgCode == NOTI_MSG_CODE_BATTERY_OUT ||
                offlineMsgCode == NOTI_MSG_CODE_LOST_DIS) {
                return;
            }
        }
            break;
        default:
            break;
    }
    
    if (dict) { // 存在dict   更新电量
        if (offlineMsgCode == NOTI_MSG_CODE_SWITCH_OPEN ||
            offlineMsgCode == NOTI_MSG_CODE_SWITCH_CLOSE) {
            // 开关电门 更新电量
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNUpdatePower object:self userInfo:dict];
        }
        
        if (offlineMsgCode == NOTI_MSG_CODE_SWITCH_OPEN ||
            offlineMsgCode == NOTI_MSG_CODE_SWITCH_CLOSE ||
            offlineMsgCode == NOTI_MSG_CODE_SWITCH_ILLEGAL_OPEN) {
            // 开关电门 更新电量
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNDevAccStatusOnorOff object:self userInfo:dict];
        }
        
        if (offlineMsgCode == NOTI_MSG_CODE_DEV_STATUS_UPDATE) {
            // 更新电动车列表
            [[UserManager shareManager] updateBikeListWithUserid:offlineMsgUserid complete:nil];
        }
    }
    
    /** 车辆数据更新 || 主用户解绑，向副用户推送消息 || 主用户删除副用户 */
    if (offlineMsgCode == NOTI_MSG_CODE_BIKE_INFO_UPDATE ||
        offlineMsgCode == NOTI_MSG_CODE_UNBIND_MAIN ||
        offlineMsgCode == NOTI_MSG_CODE_VICE_USER_DELETED ||
        offlineMsgCode == NOTI_MSG_CODE_BUY_SERVICE) {
        // 更新电动车列表
        [[UserManager shareManager] updateBikeListWithUserid:offlineMsgUserid complete:nil];
        [[UserManager shareManager] updateBikeInfoWithUserid:offlineMsgUserid bikeid:offlineMsgBikeid complete:nil];
    }
    
    if (offlineMsgCode == NOTI_MSG_CODE_OTHRER_LOGIN) {
        // 验证用户是否真的无效token  防止错误提示
        [[G100UserApi sharedInstance] queryUserinfoWithUserid:@[ offlineMsgUserid ] callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if ((statusCode == 64 || statusCode == 06) && ![UserManager shareManager].remoteLogin)  {
                // 发送被异地登陆的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNRemoteLoginMsg object:nil userInfo:nil];
                [UserManager shareManager].remoteLogin = YES;
                // 记录非正常登录
                [[SoundManager sharedManager] stopAlertSound];
                [[UserManager shareManager] logoff];
                
                G100ReactivePopingView *box = [G100ReactivePopingView grabLoginView];
                box.backgorundTouchEnable = NO;
                
                __weak UIViewController *topVC = CURRENTVIEWCONTROLLER;
                [box dismissWithVc:box.popVc animation:YES];
                [box showPopingViewWithTitle:offlineMsg.custtitle content:offlineMsg.custdesc noticeType:ClickEventBlockCancel otherTitle:nil confirmTitle:@"重新登录" clickEvent:^(NSInteger index) {
                    if (index == 2) {
                        [UserManager shareManager].remoteLogin = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                        [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                        [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                            [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                        }];
                    }
                    [box dismissWithVc:topVC animation:YES];
                } onViewController:topVC onBaseView:topVC.view];
            }
        }];
    }
}

#pragma mark - 本地通知消息处理
- (void)application:(UIApplication *)application didReceiveJPushLocalNotification:(UILocalNotification *)notification {
    NSLog(@"收到了本地通知消息!!!");
    NSString *identifier = [notification.userInfo objectForKey:@"id"];
    if (application.applicationState != UIApplicationStateActive) {
        //激活状态下不做跳转 -> 测试超过等待时间提示
        if ([identifier isEqualToString:kGNAppTestTimeUpNotification]) {
            
        }else if ([identifier isEqualToString:kGNWechatTestTimeUpNotification]) {
            
        }else if ([identifier isEqualToString:kGNPhoneTestTimeUpNotification]) {
            
        }
    }
    [self nh_quickDecreaseBadge];
}

#pragma mark - 快餐方法
- (void)nh_newBadge:(NSInteger)badge {
    if (badge >= 0) {
        [JPUSHService setBadge:badge];
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    }else {
        [JPUSHService setBadge:0];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)nh_quickDecreaseBadge {
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if (badge > 0) {
        badge --;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    }
}

- (void)nh_handleOfflineNotis:(UIApplication *)application {
    if (self.offlineMsgArray.count) {
        for (NSNotification * notification in self.offlineMsgArray) {
            [[NotificationHelper shareInstance] application:application didReceiveJPushOfflineMessage:notification];
        }
        [self.offlineMsgArray removeAllObjects];
    }
}

@end
