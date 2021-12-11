//
//  G100PopBoxHelper.m
//  G100
//
//  Created by Tilink on 15/8/13.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxHelper.h"
#import "G100PopView.h"
#import "G100PushMsgDomain.h"
#import "G100BikeApi.h"
#import "G100DevApi.h"
#import "G100ScanViewController.h"
#import "G100DevLogsViewController.h"
#import "G100DevUnderFindingViewController.h"

#import "G100NewPromptBox.h"
#import "G100FunctionViewController.h"
#import "G100TestConfirmViewController.h"

#import "G100Mediator+GPS.h"

@interface G100PopBoxHelper ()

@property (strong, nonatomic) NSMutableArray * popViewsArray;

@end

@implementation G100PopBoxHelper
@synthesize popViewsArray;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGNPresentBigPopBoxView
                                                  object:nil];
}

+(instancetype)sharedInstance {
    static G100PopBoxHelper * sharedInstance = nil;
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[G100PopBoxHelper alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    if (self = [super init]) {
        popViewsArray = [[NSMutableArray alloc] init];
        // 监听收到弹出pop 框的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tl_presentPopBoxView:)
                                                     name:kGNPresentBigPopBoxView
                                                   object:nil];
    }
    
    return self;
}

- (void)startupPopBoxService {
    // 暂不处理
    
}

- (void)stopPopBoxService {
    // 暂不处理
    
}

-(void)addNewPopView:(G100PopView *)popView {
    [popViewsArray addObject:popView];
}

-(void)removeOldPopView:(G100PopView *)popView {
    if ([popViewsArray containsObject:popView]) {
        [popViewsArray removeObject:popView];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    for (G100PopView * view in popViewsArray) {
        if (view.popCode == popView.popCode) {
            if ([view.pushMsg.bikeid isEqualToString:popView.pushMsg.bikeid]) {
                [arr addObject:view];
            }
        }
    }
    
    for (G100PopView * view in arr) {
        [view hideSelf];
    }
    
    [popViewsArray removeObjectsInArray:arr];
}

- (void)removeAllPopView {
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    for (G100PopView * view in popViewsArray) {
        [view hideSelf];
    }
    
    [popViewsArray removeObjectsInArray:arr];
}

#pragma mark - 推送警告
-(void)tl_presentPopBoxView:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    DLog(@"\n\n即将弹出pop框：\n\n G100PopBoxHelper: %@\n \n bigPushInfo = %@\n\n", self, userInfo);
    
    G100PushMsgDomain * pushDomain = [[G100PushMsgDomain alloc] initWithDictionary:userInfo];
    if (pushDomain.custtitle.length == 0 && pushDomain.custdesc.length == 0) {
        return;
    }
    
    // 状态码
    NSInteger errCode = pushDomain.errCode;
    
    UIColor * lColor = [UIColor whiteColor];
    NSString * imageName = [[NSString alloc]init];
    switch (errCode) {
        case NOTI_MSG_CODE_DEV_SHAKE:
            imageName = @"ic_pop_shake";
            lColor = [UIColor colorWithRed:251.0f / 255.0f green:180.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_BATTERY_IN:
            imageName = @"";
            lColor = [UIColor colorWithRed:251.0f / 255.0f green:180.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_BATTERY_OUT:
            imageName = @"ic_pop_power_move";
            lColor = [UIColor colorWithRed:86.0f / 255.0f green:168.0f / 255.0f blue:215.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_VOLTAGE_LOW:
            imageName = @"ic_pop_power_low";
            lColor = [UIColor colorWithRed:150.0f / 255.0f green:202.0f / 255.0f blue:117.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_DEV_FAULT:
            imageName = @"ic_pop_devfault";
            lColor = [UIColor colorWithRed:89.0f / 255.0f green:187.0f / 255.0f blue:126.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_ILLEGAL_DIS:
            imageName = @"ic_pop_unusual_move";
            lColor = [UIColor colorWithRed:224.0f / 255.0f green:94.0f / 255.0f blue:87.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_MATCH_FAULT:
            imageName = @"ic_pop_devfault";
            lColor = [UIColor colorWithRed:89.0f / 255.0f green:187.0f / 255.0f blue:126.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_COMM_FAULT:
            imageName = @"ic_pop_devfault";
            lColor = [UIColor colorWithRed:89.0f / 255.0f green:187.0f / 255.0f blue:126.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_ALARM_REMOVE:
            imageName = @"ic_pop_alarm_remove";
            lColor = [UIColor colorWithRed:255.0f / 255.0f green:119.0f / 255.0f blue:88.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_SWITCH_ILLEGAL_OPEN:
            imageName = @"ic_pop_switch_open";
            lColor = [UIColor colorWithRed:255.0f / 255.0f green:133.0f / 255.0f blue:55.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_DEFAULT_NOTIFY:
            imageName = @"ic_pop_report";
            lColor = [UIColor colorWithRed:251.0f / 255.0f green:180.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_SWITCH_OPEN:
            imageName = @"ic_pop_elec_open";
            lColor = [UIColor colorWithRed:215.0f / 255.0f green:98.0f / 255.0f blue:86.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_SOS_HANDLE:
            imageName = @"ic_pop_sos_please";
            lColor = [UIColor colorWithRed:223.0f / 255.0f green:31.0f / 255.0f blue:30.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_LOST_DIS:
            imageName = @"ic_pop_unusual_move";
            lColor = [UIColor colorWithRed:223.0f / 255.0f green:31.0f / 255.0f blue:30.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_SWITCH_CLOSE:
            imageName = @"ic_pop_elec_open";
            lColor = [UIColor colorWithRed:215.0f / 255.0f green:98.0f / 255.0f blue:86.0f / 255.0f alpha:1.0f];
            break;
        case NOTI_MSG_CODE_TEST_PUSH:
            imageName = @"ic_pop_alarm_test";
            lColor = [UIColor colorWithRed:253.0f / 255.0f green:155.0f / 255.0f blue:39.0f / 255.0f alpha:1.0f];
            break;
        default:
            break;
    }
    
    pushDomain.imageName = imageName;
    pushDomain.lColor = lColor;
    
    NSString *userid = [NSString stringWithFormat:@"%@", @(pushDomain.userid)];
    NSString *bikeid = pushDomain.bikeid;
    
    NSString *devid  = pushDomain.deviceid;
    if (!pushDomain.deviceid.length) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid bikeid:bikeid];
        devid = [NSString stringWithFormat:@"%@", @(bikeDomain.mainDevice.device_id)];
    }
    
    __weak UIViewController * weakTopVC = [APPDELEGATE.mainNavc topViewController];
    G100PopView * popView = [[[NSBundle mainBundle]loadNibNamed:@"G100PopView" owner:self options:nil]lastObject];
    [popView showWithInfoData:pushDomain ignoreBlock:^(G100PushMsgDomain *pushMsg) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid
                                                                                   bikeid:bikeid];
        NSString *devid = [NSString stringWithFormat:@"%@", @(bikeDomain.mainDevice.device_id)];
        // 忽略
        if (pushMsg.errCode == NOTI_MSG_CODE_ILLEGAL_DIS) {
            [[G100DevApi sharedInstance] ignoreOrFindDevWhenWarnComeWithBikeid:bikeid devid:devid type:@"ignore" callback:nil];
        }
        NSArray *deviceArray = [[G100InfoHelper shareInstance] findMyDevListWithUserid:userid bikeid:bikeid];
        G100DeviceDomain *devDomain;
        for (G100DeviceDomain *deviceDomin in deviceArray) {
            if (deviceDomin.isMainDevice) {
                devDomain = deviceDomin;
                break;
            }
        }
        if (devDomain.security.ignore_notify_time != 0) {
            // 用户设置了忽略时间 在忽略
            NSMutableString * pushtype = [NSString stringWithFormat:@"%@", @(pushMsg.errCode)].mutableCopy;
            if (pushtype.length == 1) {
                // 如果是一位数  前面插入0
                [pushtype insertString:@"0" atIndex:0];
            }
            
            if (pushMsg.errCode == NOTI_MSG_CODE_DEV_SHAKE) {
                [pushtype appendString:pushMsg.addval];
            }
            [[G100BikeApi sharedInstance] ignoreSamePushWithBikeid:bikeid pushtype:pushtype.copy callback:nil];
        }
    } helpBlock:^(G100PushMsgDomain *pushMsg) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid
                                                                                   bikeid:bikeid];
        NSString *devid = [NSString stringWithFormat:@"%@", @(bikeDomain.mainDevice.device_id)];
        
        // 首先判断是不是测试推送 是 则做特别操作
        if (pushMsg.errCode == NOTI_MSG_CODE_TEST_PUSH) {
            // 弹窗 提醒用户测试成功 点击进入安防设置 确认收到测试推送
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppTestRecievedNotification object:self userInfo:userInfo];
            __weak UIViewController *weakNewTopVC = [APPDELEGATE.mainNavc topViewController];
            G100NewPromptSimpleBox *box = [G100NewPromptSimpleBox promptAlertViewWithSimpleStyle];
            [box showPromptBoxWithTitle:@"测试成功" Content:@"您的App成功收到了报警测试！" confirmButtonTitle:@"好的，知道了" event:^(NSInteger index) {
                if (index == 0) {
                    // 跳转到安防设置界面
                    NSMutableArray *navs = [[weakNewTopVC.navigationController viewControllers] mutableCopy];
                    BOOL hasOldVC = NO;
                    UIViewController *oldVC = nil;
                    for (UIViewController *vc in navs) {
                        if ([vc isKindOfClass:[G100FunctionViewController class]]) {
                            G100FunctionViewController *tmpvc = (G100FunctionViewController *)vc;
                            if ([tmpvc.userid isEqualToString:userid] &&
                                [tmpvc.bikeid isEqualToString:bikeid]) {
                                hasOldVC = YES;
                                oldVC    = vc;
                                break;
                            }
                        }
                    }
                    if (hasOldVC) {
                        if ([weakNewTopVC isKindOfClass:NSClassFromString(@"G100TestConfirmViewController")]) {
                            G100TestConfirmViewController *tmp = (G100TestConfirmViewController *)weakNewTopVC;
                            // 只有在当前栈顶是测试结果页面&&入口是App报警测试的时候 才pop回去
                            if (tmp.entrance == 1) {
                                [weakNewTopVC.navigationController popToViewController:oldVC animated:YES];
                            }
                        }else {
                            
                        }
                    }else {
                        // 判断是否真的存在未完成的测试
                        NSDictionary *testResultInfo = [[G100InfoHelper shareInstance] findThereisPushTestResultWithUserid:[NSString stringWithFormat:@"%@", @(pushMsg.userid)]];
                        if (!testResultInfo || [testResultInfo[@"entrance"] integerValue] != 1) {
                            if ([weakNewTopVC isKindOfClass:NSClassFromString(@"G100TestConfirmViewController")]) {
                                G100FunctionViewController *funvc = [[G100FunctionViewController alloc] init];
                                funvc.userid = userid;
                                funvc.bikeid = bikeid;
                                
                                UIViewController *lastVC = [navs lastObject];
                                if ([lastVC isKindOfClass:NSClassFromString(@"G100TestConfirmViewController")]) {
                                    G100TestConfirmViewController *tmp = (G100TestConfirmViewController *)weakNewTopVC;
                                    // 只有在当前栈顶是测试结果页面&&入口是App报警测试的时候 才pop回去
                                    if (tmp.entrance == 1) {
                                        [navs removeLastObject];
                                    }
                                }
                                [navs addObject:funvc];
                                [weakNewTopVC.navigationController setViewControllers:navs.copy animated:YES];
                            }
                        }else {
                            G100FunctionViewController *funvc = [[G100FunctionViewController alloc] init];
                            funvc.userid = userid;
                            funvc.bikeid = bikeid;
                            
                            UIViewController *lastVC = [navs lastObject];
                            if ([lastVC isKindOfClass:NSClassFromString(@"G100TestConfirmViewController")]) {
                                G100TestConfirmViewController *tmp = (G100TestConfirmViewController *)weakNewTopVC;
                                // 只有在当前栈顶是测试结果页面&&入口是App报警测试的时候 才pop回去
                                if (tmp.entrance == 1) {
                                    [navs removeLastObject];
                                }
                            }
                            [navs addObject:funvc];
                            [weakNewTopVC.navigationController setViewControllers:navs.copy animated:YES];
                        }
                    }
                }
                
                [box dismissWithVc:weakNewTopVC animation:YES];
            } onViewController:weakNewTopVC onBaseView:weakNewTopVC.view];
            return;
        }
        
        /** 先判断车辆状态 寻车模式下走特定操作*/
        // 获取当前车辆的设防模式
        G100DeviceSecuritySetting * setDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:userid
                                                                                             bikeid:bikeid
                                                                                              devid:devid].security;
        if (setDomain.mode == DEV_SECSET_MODE_DEVLOST) {
            if (pushMsg.errCode == NOTI_MSG_CODE_LOST_DIS ||
                pushMsg.errCode == NOTI_MSG_CODE_SWITCH_OPEN ||
                pushMsg.errCode == NOTI_MSG_CODE_SWITCH_CLOSE ||
                pushMsg.errCode == NOTI_MSG_CODE_BATTERY_OUT) {
                // 寻车模式
                if (bikeDomain.lost_id) {
                    // 判断当前页面是不是寻车页面
                    if ([weakTopVC isKindOfClass:[G100DevUnderFindingViewController class]]) {
                        return;
                    }
                    // 确实是寻车模式 且存在lostid
                    G100DevUnderFindingViewController *underFind = [[G100DevUnderFindingViewController alloc] init];
                    underFind.userid = userid;
                    underFind.bikeid = bikeid;
                    underFind.devid  = devid;
                    underFind.lostid = bikeDomain.lost_id;
                    [weakTopVC.navigationController pushViewController:underFind animated:YES];
                }
            }else {
                // 其他各种 到实时追踪界面
                UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:userid
                                                                                                             bikeid:bikeid
                                                                                                              devid:devid];
                [weakTopVC.navigationController pushViewController:viewController animated:YES];
            }
        }else {
            // 立即找车
            if (pushMsg.errCode == NOTI_MSG_CODE_ILLEGAL_DIS) {
                 [[G100DevApi sharedInstance] ignoreOrFindDevWhenWarnComeWithBikeid:devid devid:nil type:@"find" callback:nil];
            }
            
            if (errCode == NOTI_MSG_CODE_DEV_FAULT) {
                // 设备故障 跳转到一键体检
                G100ScanViewController * scanVC = [[G100ScanViewController alloc] init];
                scanVC.userid = userid;
                scanVC.bikeid = bikeid;
                scanVC.devid = devid;
                [weakTopVC.navigationController pushViewController:scanVC animated:YES];
            }else if (errCode == NOTI_MSG_CODE_COMM_FAULT || errCode == NOTI_MSG_CODE_MATCH_FAULT) {
                // 对码故障 跳转到用车报告
                G100DevLogsViewController* devLogs = [[G100DevLogsViewController alloc] init];
                devLogs.userid = userid;
                devLogs.bikeid = bikeid;
                devLogs.devid = devid;
                [weakTopVC.navigationController pushViewController:devLogs animated:YES];
            }else {
                // 其他各种 到实时追踪界面
                UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:userid
                                                                                                             bikeid:bikeid
                                                                                                              devid:devid];
                [weakTopVC.navigationController pushViewController:viewController animated:YES];
            }
        }
    }];
}

@end
