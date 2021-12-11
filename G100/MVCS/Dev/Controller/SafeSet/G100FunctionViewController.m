//
//  G100FunctionViewController.m
//  G100
//
//  Created by Tilink on 15/2/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100FunctionViewController.h"
#import "SetSelecteCell.h"
#import "SecuritySetCell.h"
#import "SecuritySetNoPromptCell.h"

#import "G100DevApi.h"
#import "G100BikeApi.h"

#import "G100FuncSetNoPromptViewController.h"
#import "G100FuncReminderSetViewController.h"
#import "G100AlertorSoundSelcetViewController.h"

#import "G100WebViewController.h"

#import <YYText.h>

/** 20160603 新增报警通知设置*/
#import "SetAlarmNotiSetCell.h"
#import "G100PushAlarmTestView.h"
#import "G100NewPromptBox.h"
#import "WechatQRView.h"
#import "G100ABHelper.h"

#import "G100DeviceDomain.h"
#import <WXApi.h>
#import "G100GPSRemoteCtrlView.h"
#import "G100UrlManager.h"
#import "NotificationHelper.h"
#import "G100ThirdAuthManager.h"
#import "G100ABManager.h"

static NSString * const kG100TableSectionKey_PromptModel        = @"prompt_model";
static NSString * const kG100TableSectionKey_AlarmNotiSetting   = @"alarm_noti_setting";
static NSString * const kG100TableSectionKey_SensorAlarmOptions = @"sensor_alarm_options";
static NSString * const kG100TableSectionKey_RemoteControl      = @"remote_control";

@interface G100FunctionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableArray *sectionArr;
@property (strong, nonatomic) NSArray        *statusArr;
@property (assign, nonatomic) NSInteger      statusSelected;

@property (nonatomic, strong) NSMutableArray *footerSectionContentArr;
/** 记录报警通知设置内的详细内容*/
@property (nonatomic, strong) NSMutableArray *alarmNotiSetArray;

@property (nonatomic, strong) UIView *pushNotOpenView;
@property (nonatomic, strong) MASConstraint *tableViewTopMasConstraint;

@property (copy, nonatomic) NSString *partner;
@property (copy, nonatomic) NSString *partneraccount;
@property (copy, nonatomic) NSString *partneraccounttoken;
@property (copy, nonatomic) NSString *partneruseruid;

@property (assign, nonatomic) BOOL isFirstWechatPermission;
@property (assign, nonatomic) BOOL isFirstPhonePermission;

/** 记录微信报警开关信息*/
@property (assign, nonatomic) BOOL wx_oldStatsus;
@property (strong, nonatomic) NSIndexPath *wx_indexPath;
@property (strong, nonatomic) NSMutableDictionary *wx_infoDict;

@property (strong, nonatomic) G100BikeDomain *bikeDomain;
@property (strong, nonatomic) G100DeviceDomain *devDomain;

@property (strong, nonatomic) NSString *G500Devid;

@property (nonatomic, assign) BOOL isSwitching;

@end

@implementation G100FunctionViewController

#pragma mark - 创建数据源
- (void)createDataSource {
    
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    
    [_dataArray removeAllObjects];
    
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"StatusWarns" ofType:@"plist"];
    self.statusArr = [[NSArray alloc] initWithContentsOfFile:plist];
    [_dataArray addObject:_statusArr];
    
    // 不管外面传什么设备id 内部全部转成主设备id
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    self.devid = [NSString stringWithFormat:@"%@", @(self.bikeDomain.mainDevice.device_id)];
    
    // 状态提醒模式添加完毕
    G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    
    //电子围栏
//    NSMutableDictionary *eleDict = @{@"type" : [NSNumber numberWithInteger:4],
//                                     @"topTitle" : @"电子围栏",
//                                     @"bottomDetail" : @"当车辆在关闭电门或设防状态下驶出围栏范围后将收到报警",
//                                     @"leftImage" : devDomain.efence.switch_efence ? @"efence_on" : @"efence_off",
//                                     @"switchon" : [NSNumber numberWithBool:devDomain.efence.switch_efence],
//                                     }.mutableCopy;
//    NSString *radiuEle = [NSString stringWithFormat:@"%ld",(long)devDomain.efence.radius];
//    NSMutableDictionary *radiusDict = @{@"topTitle" : @"围栏半径",
//                                        @"bottomDetail" : devDomain.efence.radius ? radiuEle : @"50",
//                                        }.mutableCopy;
//    if (devDomain.efence.switch_efence) {
//        [_dataArray addObject:@[eleDict,radiusDict]];
//    }else{
//        [_dataArray addObject:@[eleDict]];
//    }

    // 报警器通知设置
    NSMutableDictionary *appDict = @{@"type" : [NSNumber numberWithInteger:1],
                                     @"topTitle" : @"App报警通知",
                                     @"bottomDetail" : @"通过App推送报警通知",
                                     @"lastDescription" : @"",
                                     @"leftImage" : @"2_0_ic_set_push_app_on"
                                     }.mutableCopy;
    NSString *yishouquanWx = [NSString stringWithFormat:@"已授权微信%@接收报警通知", devDomain.security.wx_notify.nick_name];
    NSMutableDictionary *wxDict = @{@"type" : [NSNumber numberWithInteger:2],
                                    @"topTitle" : @"微信报警通知",
                                    @"bottomDetail" : devDomain.security.wx_notify.switch_on ? yishouquanWx : @"通过微信消息推送报警通知",
                                    @"lastDescription" : (devDomain.security.wx_notify.switch_on && devDomain.security.wx_notify.label.length) ? devDomain.security.wx_notify.label : @"当您绑定了微信帐号后，在车辆有潜在危险时，会通过微信消息通知您",
                                    @"switchon" : [NSNumber numberWithBool:devDomain.security.wx_notify.switch_on],
                                    @"leftImage" : devDomain.security.wx_notify.switch_on ? @"2_0_ic_set_push_wx_on" : @"2_0_ic_set_push_wx_off"
                                    }.mutableCopy;
    NSString *yishouquanPhone = [NSString stringWithFormat:@"已授权%@接收报警通知",  [NSString shieldImportantInfo:devDomain.security.phone_notify.callee_num]];
    NSMutableDictionary *pnDict = @{@"type" : [NSNumber numberWithInteger:3],
                                    @"topTitle" : @"电话报警通知",
                                    @"bottomDetail" : devDomain.security.phone_notify.switch_on ? yishouquanPhone : [NSString stringWithFormat:@"通过来电发送报警通知，每月%@次免费推送", @(devDomain.security.phone_notify.month_limit)],
                                    @"lastDescription" : (devDomain.security.phone_notify.switch_on && devDomain.security.phone_notify.label.length) ? devDomain.security.phone_notify.label : [NSString stringWithFormat:@"当您的车辆有潜在危险时，我们会来电通知您；\n本月您还剩余%@次免费推送，测试报警不计算在%@次之内", @(devDomain.security.phone_notify.month_limit - devDomain.security.phone_notify.used), @(devDomain.security.phone_notify.month_limit)],
                                    @"switchon" : [NSNumber numberWithBool:devDomain.security.phone_notify.switch_on],
                                    @"leftImage" : devDomain.security.phone_notify.switch_on ? @"2_0_ic_set_push_phone_on" : @"2_0_ic_set_push_phone_off"
                                    }.mutableCopy;
    if ([WXApi isWXAppInstalled]) {
        [_dataArray addObject:@[ appDict, wxDict, pnDict ]];
    }else{
        [_dataArray addObject:@[ appDict, pnDict ]];
    }
    self.sectionArr = @[@"车辆状态提醒模式", @"报警通知设置"].mutableCopy;
    self.footerSectionContentArr = @[@"", @""].mutableCopy;
    
    /* 1.4.2 版本 无需用户选择是否有报警器 不显示报警防盗器开关
    if (devDomain.alertor != DEV_ALERTOR_TYPE_NOTAPPLICABLE) {
        // 报警器不可用的情况下   隐藏报警器选项设置  如果设备是副用户 则不可点击
        [_dataArray addObject:@[@"baojingqi"]];
        [_sectionArr addObject:@""];
        [_footerSectionContentArr addObject:@"打开/关闭此服务请先确认360骑卫士感应防盗器安装状态，点击此处了解更多"];
    }*/
    
    // 带报警器的设备 && 主用户
    if ([self.bikeDomain ableRemote_ctrlDevice] && self.bikeDomain.isMaster) {
        /*
        // 判断用户远程控制是否可用
        [_dataArray addObject:@[@"yaokongqi"]];
        [_sectionArr addObject:@"感应防盗器选项"];
        [_footerSectionContentArr addObject:@"使用前请确认车辆所在地的移动网络通讯良好"];
        */
    }
    
    // 判断是否可以设置声音
    for (G100DeviceDomain *device in self.bikeDomain.gps_devices) {
        if (device.func.alertor.alertor_sound.enable && self.bikeDomain.isMaster) {
            [_dataArray addObject:@[@"soundset"]];
            [_sectionArr addObject:@"设备声音设置"];
            [_footerSectionContentArr addObject:@""];
            
            self.G500Devid = [NSString stringWithFormat:@"%@", @(device.device_id)];
            break;
        }
    }
    
    self.devDomain = devDomain;
}

#pragma mark - 模式返index
-(NSInteger)indexOfDevModeWithMode:(NSInteger)mode {
    NSInteger index = 0;
    switch (mode) {
        case DEV_SECSET_MODE_DISARMING:     // 关闭通知
        {
            index = 3;
        }
            break;
        case DEV_SECSET_MODE_WARN:         // 警戒模式
        {
            index = 0;
        }
            break;
        case DEV_SECSET_MODE_STANDARD:     // 标准模式
        {
            index = 1;
        }
            break;
        case DEV_SECSET_MODE_NODISTURB:    // 免打扰模式
        {
            index = 2;
        }
            break;
        case DEV_SECSET_MODE_DEVLOST:    // 免打扰模式
        {
            index = 4;
        }
            break;
        default:
            break;
    }
    
    return index;
}
/*
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (animated) {
        if (self.isSwitching) {
            return;
        }
        self.isSwitching = YES;
    }
    
    [self.navigationController pushViewController:viewController animated:animated];
    
}

#pragma mark - navigationCotroller delegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.isSwitching = NO;
}*/
#pragma mark - UITableViewDelegate 相关
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [_dataArray[section] count] + 1;
    }
    return [_dataArray[section] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == [_dataArray[indexPath.section] count]) {
            return 64;
        }
        NSDictionary * dict = [_statusArr safe_objectAtIndex:indexPath.row];
        // 调整cell行高
        CGSize constraint = CGSizeMake(WIDTH - 120, 100);
        CGSize size = [[dict objectForKey:@"detail"] calculateSize:constraint font:[UIFont systemFontOfSize:14]];
        
        return 64 + size.height - 21;
    }else if (indexPath.section == 1) {
        NSMutableDictionary * dict = [[_dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
        return [SetAlarmNotiSetCell heightForDict:dict];
    }else {
        NSString * identifier = _dataArray[indexPath.section][indexPath.row];
        
        if ([identifier isEqualToString:@"baojingqi"]) {
            return 50;
        }else if ([identifier isEqualToString:@"yaokongqi"]) {
            return 50;
        }else if ([identifier isEqualToString:@"soundset"]) {
            return 50;
        }
    }
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        NSString * lastfooter = _footerSectionContentArr[section - 1];
        if (lastfooter && lastfooter.length) {
            NSString * content = self.sectionArr[section];
            
            if (!content.length) {
                return 8;
            }else {
                CGSize contentSize = [content calculateSize:CGSizeMake(WIDTH - 115, 1000) font:[UIFont systemFontOfSize:15]];
                return contentSize.height + 12;
            }
            
            return 0.1;
        }
    }
    
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString * content = self.footerSectionContentArr[section];
    
    CGFloat h = 0.1;
    if (section == [self.footerSectionContentArr count] - 1) {
        h = 20;
    }
    
    if (!content.length) {
        return h;
    }else {
        CGSize contentSize = [content calculateSize:CGSizeMake(WIDTH - 115, 1000) font:[UIFont systemFontOfSize:14]];
        return contentSize.height + h;
    }
    
    return h;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width - 35, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    [backView addSubview:titleLabel];
    
    titleLabel.text = _sectionArr[section];
    
    return backView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    YYLabel *label = [[YYLabel alloc]initWithFrame:CGRectMake(50, 0, backView.v_width - 65, 30)];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    
    [backView addSubview:label];
    
    label.text = self.footerSectionContentArr[section];
    
    if (section == 2) {
        NSString * content = self.footerSectionContentArr[section];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:content];
        text.yy_font = [UIFont systemFontOfSize:14];
        text.yy_color = [UIColor grayColor];
        
        NSRange hiRange = [content rangeOfString:@"点击此处"];
        
        [text yy_setColor:RGBColor(74, 94, 173, 1.0) range:hiRange];
        label.attributedText = text;
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor grayColor]];
        
        G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
        __weak typeof(self) wself = self;
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            G100WebViewController * helper = [G100WebViewController loadNibWebViewController];
            helper.userid = self.userid;
            helper.httpUrl =  [[G100UrlManager sharedInstance]getFunctionAlarmUrlWithSn:devDomain.sn.length ? devDomain.sn : @"0" ];
            [wself.navigationController pushViewController:helper animated:YES];
        };
        [text yy_setTextHighlight:highlight range:hiRange];
        
        label.attributedText = text;
    }
    
    CGSize contentSize = [label.text calculateSize:CGSizeMake(WIDTH - 115, 1000) font:[UIFont systemFontOfSize:14]];
    backView.v_height = label.v_height = contentSize.height + 8;
    
    return backView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SetSelecteCell * rankCell = [tableView dequeueReusableCellWithIdentifier:@"statuscell"];
    if (indexPath.section == 0) {

        if (indexPath.row == [_dataArray[indexPath.section] count]) {
            SecuritySetNoPromptCell * baojingsetCell = (SecuritySetNoPromptCell *)[tableView dequeueReusableCellWithIdentifier:@"baojinghulveset"];
            if (!baojingsetCell) {
                baojingsetCell = [[[NSBundle mainBundle] loadNibNamed:@"SecuritySetNoPromptCell" owner:self options:nil] lastObject];
            }
            return baojingsetCell;
        }

        NSDictionary * dict = [_statusArr safe_objectAtIndex:indexPath.row];
        rankCell.statusTitle.text = [dict objectForKey:@"status"];
        rankCell.statusContent.text = [dict objectForKey:@"detail"];

        // 调整cell行高
        CGSize constraint = CGSizeMake(WIDTH - 120, 100);
        CGSize size = [rankCell.statusContent.text calculateSize:constraint font:[UIFont systemFontOfSize:14]];
        rankCell.statusContent.numberOfLines = 0;
        rankCell.statusContent.v_height = size.height;
        rankCell.v_height = 64 + (size.height - 21);

        if (_statusSelected == indexPath.row && // 并且用户处于开启通知的状态
            [[NotificationHelper shareInstance] notificationServicesEnabled]) {
            rankCell.leftImageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
            rankCell.statusButton.selected = YES;
        }else {
            rankCell.leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", [dict objectForKey:@"image"]]];
            rankCell.statusButton.selected = NO;
        }

        rankCell.userInteractionEnabled = YES;
        // 寻车模式不能设置 报警模式
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
            if ([bikeDomain isLostBike]) {
                rankCell.enabled = NO;
                rankCell.userInteractionEnabled = NO;
            }else {
                rankCell.enabled = YES;
                rankCell.userInteractionEnabled = YES;

                if ([[NotificationHelper shareInstance] notificationServicesEnabled]) {
                    rankCell.enabled = YES;
                    rankCell.userInteractionEnabled = YES;
                }else {
                    rankCell.enabled = NO;
                    rankCell.userInteractionEnabled = NO;
                }
            }
            rankCell.statusButton.hidden = NO;
        }else if (indexPath.row == 4){
            rankCell.userInteractionEnabled = NO;
            if ([bikeDomain isLostBike]) {
                rankCell.statusButton.hidden = NO;
                rankCell.statusButton.selected = YES;
                rankCell.leftImageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
            }else{
                rankCell.statusButton.hidden = YES;
                rankCell.leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", [dict objectForKey:@"image"]]];
            }

        }

        return rankCell;
    }else if (indexPath.section == 1) {
        // 报警通知设置
        NSMutableDictionary * dict = [[_dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
        SetAlarmNotiSetCell *alarmSet = [SetAlarmNotiSetCell alarmNotiSetCellWithType:[dict[@"type"] integerValue]];

        /** type 1 App测试 2 微信测试 3 电话测试*/
        NSInteger type = [dict[@"type"] integerValue];
        __weak G100FunctionViewController *wself = self;
        alarmSet.serviceAgreementClickBlock = ^(){
            if (type == 2 || type == 3) {
                G100WebViewController *webVC = [G100WebViewController loadNibWebViewController];
                webVC.userid  = wself.userid;
                webVC.devid   = wself.devid;
                if (type == 2) {
                    // 微信协议
                    webVC.userid = wself.userid;
                    webVC.httpUrl = [[G100UrlManager sharedInstance]getWeChatAlarmProtocolUrl:1];
                    [wself.navigationController pushViewController:webVC animated:YES];
                }else if (type == 3) {
                    // 电话报警协议
                    webVC.userid = wself.userid;
                    webVC.httpUrl =  [[G100UrlManager sharedInstance]getPhoneAlarmProtocolUrl:1];
                    [wself.navigationController pushViewController:webVC animated:YES];
                }
            } else {
                DLog(@"不存在这个入口");
            }
        };
        alarmSet.testButtonEventBlock = ^(UIButton *button){
            if (kNetworkNotReachability) {
                [wself showHint:kError_Network_NotReachable];
                return;
            }

            // 首先判断 用户是否打开系统推送
            if (![[NotificationHelper shareInstance] notificationServicesEnabled] && type == 1) {
                if ([NotificationHelper canOpenSystemNotificationSettingPage]) {
                    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                    [box showPopingViewWithTitle:@"提示"
                                         content:@"您的手机禁止了App通知，\n这将导致无法接收App消息\n请前往设置"
                                      noticeType:ClickEventBlockCancel
                                      otherTitle:@"取消"
                                    confirmTitle:@"去设置"
                                      clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [NotificationHelper openSystemNotificationSettingPage];
                        }
                        [box dismissWithVc:wself animation:YES];
                    }
                                onViewController:wself
                                      onBaseView:wself.view];
                } else {
                    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                    [box showPopingViewWithTitle:@"提示"
                                         content:@"您的手机禁止了App通知，\n这将导致无法接收App消息\n请前往设置"
                                      noticeType:ClickEventBlockCancel
                                      otherTitle:nil
                                    confirmTitle:@"我知道了"
                                      clickEvent:^(NSInteger index) {
                                          [box dismissWithVc:wself animation:YES];
                                      }
                                onViewController:wself
                                      onBaseView:wself.view];
                }
                return;
            }

            G100PushAlarmTestView *testView = [[G100PushAlarmTestView alloc] init];
            testView.userid = wself.userid;
            testView.bikeid = wself.bikeid;
            testView.devid = wself.devid;
            //TODO:切换正确的报警电话
            testView.phoneNum = wself.bikeDomain.mainDevice.security.phone_notify.callee_num;
            testView.isTrainTest = NO;

            if (type == 1) {
                // App报警推送测试
                testView.entrance = 1;
            }else if (type == 2) {
                // 微信报警消息测试
                testView.entrance = 2;
            }else if (type == 3) {
                // 电话报警发送测试
                testView.entrance = 3;
            }

            [testView showInVc:wself view:wself.view animation:YES];
        };

        alarmSet.testAlarmSwitchChangedBlock = ^(UISwitch *us){
            if (kNetworkNotReachability) {
                [wself showHint:kError_Network_NotReachable];
                return;
            }

            if (type == 2) {
                // 微信报警
                if (!us.on) {
                    // 开启报警
                    wself.wx_oldStatsus = !us.on;
                    wself.wx_infoDict = dict;
                    wself.wx_indexPath = indexPath;

                    [wself tl_openWxAlarmWithDict:dict oldStatus:!us.on indexPath:indexPath];
                }else {
                    // 关闭报警
                    [wself showHudInView:wself.contentView hint:nil];
                    [[G100BikeApi sharedInstance] setWXNotifyWithBikeid:wself.bikeid notify:NO callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        if (requestSuccess) {
                            [[UserManager shareManager] updateDevInfoWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                [wself hideHud];
                                if (requestSuccess) {
                                    [wself createDataSource];
                                    [wself.tableView reloadData];
                                    [wself showHint:@"微信报警通知关闭成功"];
                                }
                            }];
                        }else {
                            [wself hideHud];
                            [wself showHint:response.errDesc];
                        }
                    }];
                }
            }else if (type == 3) {
                // 电话报警
                if (!us.on) {
                    // 开启报警
                    // 识别 如果属于样机帐号 弹窗输入手机号
                    if ([UserAccount sharedInfo].appwatermarking.type == 1) {
                        // 样机帐号
                        G100AlertView * surePhoneNumView = [G100AlertView G100AlertWithTitle:@"输入手机号" placehoder:@"" alertBlock:nil];
                        surePhoneNumView.maxCount = 11; // 设置最多允许输入11位数字
                        __weak G100AlertView * weakSurePhoneNumView = surePhoneNumView;
                        surePhoneNumView.alertBlockTF = ^(NSInteger index, NSString *string){
                            if ([NSString checkPhoneNum:string]) {
                                [wself showHint:[NSString checkPhoneNum:string]];
                                return;
                            }

                            [weakSurePhoneNumView hide];
                            [wself tl_openPhoneAlarmWithBikeid:wself.bikeid devid:wself.devid phoneNum:[string trim]];
                        };

                        [weakSurePhoneNumView show];
                    }else {
                        [wself tl_openPhoneAlarmWithBikeid:wself.bikeid devid:wself.devid phoneNum:nil];
                    }
                }else {
                    // 关闭报警
                    [wself showHudInView:wself.contentView hint:nil];
                    [[G100BikeApi sharedInstance] setPhoneNotifyWithBikeid:wself.bikeid notify:NO callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        if (requestSuccess) {
                            [[UserManager shareManager] updateDevInfoWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                [wself hideHud];
                                if (requestSuccess) {
                                    [wself createDataSource];
                                    [wself.tableView reloadData];
                                    [wself showHint:@"电话报警通知关闭成功"];
                                }
                            }];
                        }else {
                            [wself hideHud];
                            [wself showHint:response.errDesc];
                        }
                    }];
                }
            }
        };

        [alarmSet showUIWithDict:dict];

        return alarmSet;
    }else {
        NSString * identifier = _dataArray[indexPath.section][indexPath.row];

        if ([identifier isEqualToString:@"baojingqi"]) {
            // 报警器设置
            SecuritySetCell * baojingqiCell = [tableView dequeueReusableCellWithIdentifier:@"baojingqicell"];

            if (!baojingqiCell) {
                baojingqiCell = [SecuritySetCell securitySetCellWithIdentifier:@"baojingqicell"];
            }

            baojingqiCell.selectionStyle = UITableViewCellSelectionStyleNone;
            baojingqiCell.hintTitleLabel.text = @"骑卫士感应防盗器";

            G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid
                                                                                        bikeid:self.bikeid
                                                                                         devid:self.devid];
            if (devDomain.func.alertor.switch_on == DEV_ALERTOR_TYPE_NOTAPPLICABLE) {
                baojingqiCell.rightSwitch.enabled = NO;
                if (devDomain.func.alertor.switch_on == DEV_ALERTOR_TYPE_NOALARM) {
                    baojingqiCell.rightSwitch.on = NO;
                    baojingqiCell.leftImageView.highlighted = NO;
                }else if (devDomain.func.alertor.switch_on == DEV_ALERTOR_TYPE_HASALARM) {
                    baojingqiCell.rightSwitch.on = YES;
                    baojingqiCell.leftImageView.highlighted = YES;
                }
                baojingqiCell.leftImageView.highlighted = NO;
            }else {
                baojingqiCell.rightSwitch.enabled = YES;
                if (devDomain.func.alertor.switch_on == DEV_ALERTOR_TYPE_NOALARM) {
                    baojingqiCell.rightSwitch.on = NO;
                    baojingqiCell.leftImageView.highlighted = NO;
                }else if (devDomain.func.alertor.switch_on == DEV_ALERTOR_TYPE_HASALARM) {
                    baojingqiCell.rightSwitch.on = YES;
                    baojingqiCell.leftImageView.highlighted = YES;
                }

                if (!devDomain.main_device) {
                    // 副用户不可操作
                    baojingqiCell.rightSwitch.enabled = NO;
                }else {
                    baojingqiCell.rightSwitch.enabled = YES;
                }
            }

            baojingqiCell.openStatus = baojingqiCell.rightSwitch.on;
            __weak G100FunctionViewController * wself = self;
            __weak SecuritySetCell * wCell = baojingqiCell;
            baojingqiCell.rightSwitchBlock = ^(BOOL result) {
                if (kNetworkNotReachability) {
                    [wself showHint:kError_Network_NotReachable];
                    return;
                }

                if (result) {
                    // 打开
                    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                    [box showPopingViewWithTitle:@"注意"
                                         content:@"打开此前请和经销商确认您已经安装了骑卫士感应防盗器，如果没有安装则此服务打开后不会有任何安防作用"
                                      noticeType:ClickEventBlockCancel
                                      otherTitle:@"取消"
                                    confirmTitle:@"确定"
                                      clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself updateAlertSwitchWithDevid:wself.devid alertor:DEV_ALERTOR_TYPE_HASALARM complete:^{
                                wCell.rightSwitch.on = result;
                                wCell.leftImageView.highlighted = result;
                            }];
                        }else {
                            wCell.rightSwitch.on = !result;
                            wCell.leftImageView.highlighted = !result;
                        }
                        [box dismissWithVc:wself animation:YES];
                    }
                                onViewController:wself
                                      onBaseView:wself.view];
                }else {
                    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                    [box showPopingViewWithTitle:@"注意"
                                         content:@"关闭此服务可能存在安全风险"
                                      noticeType:ClickEventBlockCancel
                                      otherTitle:@"取消"
                                    confirmTitle:@"确定"
                                      clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself updateAlertSwitchWithDevid:wself.devid alertor:DEV_ALERTOR_TYPE_NOALARM complete:^{
                                wCell.rightSwitch.on = result;
                                wCell.leftImageView.highlighted = result;
                            }];
                        }else {
                            wCell.rightSwitch.on = !result;
                            wCell.leftImageView.highlighted = !result;
                        }
                        [box dismissWithVc:wself animation:YES];
                    }
                                onViewController:wself
                                      onBaseView:wself.view];
                }
            };

            return baojingqiCell;

        }else if ([identifier isEqualToString:@"yaokongqi"]) {
            /*
            // 遥控器设置
            SecuritySetCell * yaokongqiCell = [tableView dequeueReusableCellWithIdentifier:@"yaokongqicell"];

            if (!yaokongqiCell) {
                yaokongqiCell = [SecuritySetCell securitySetCellWithIdentifier:@"yaokongqicell"];
            }

            yaokongqiCell.hintTitleLabel.text = @"远程控制";

            return yaokongqiCell;
             */
        }else if ([identifier isEqualToString:@"soundset"]) {
            // 报警器声音设置
            SecuritySetCell * soundsetCell = [tableView dequeueReusableCellWithIdentifier:@"soundset"];

            if (!soundsetCell) {
                soundsetCell = [SecuritySetCell securitySetCellWithIdentifier:@"soundset"];
            }

            soundsetCell.leftImageView.image = [UIImage imageNamed:@"2_0_ic_set_alarmsound"];
            soundsetCell.hintTitleLabel.text = @"设备声音设置";

            return soundsetCell;
        }else {

        }
    }
//
    return rankCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == _statusSelected) {
            return;
        }
        
        if (kNetworkNotReachability && indexPath.row != 4) {
            [self showHint:kError_Network_NotReachable];
            return;
        }
        
        // 安防等级设置
        switch (indexPath.row) {
            case 3:
            {
                [self updateCurrenfMsgMode:DEV_SECSET_MODE_DISARMING];
            }
                break;
            case 0:
            {
                [self updateCurrenfMsgMode:DEV_SECSET_MODE_WARN];
            }
                break;
            case 1:
            {
                [self updateCurrenfMsgMode:DEV_SECSET_MODE_STANDARD];
            }
                break;
            case 2:
            {
                [self updateCurrenfMsgMode:DEV_SECSET_MODE_NODISTURB];
            }
                break;
            case 4:
       
                break;
            case 5:{
                G100FuncReminderSetViewController * funcReminderSet = [[G100FuncReminderSetViewController alloc] initWithNibName:@"G100FuncReminderSetViewController" bundle:nil];
                funcReminderSet.userid = self.userid;
                funcReminderSet.bikeid = self.bikeid;
                funcReminderSet.devid = self.devid;
                [self.navigationController pushViewController:funcReminderSet animated:YES];

            }
                break;

            default:
                break;
        }
    }else if (indexPath.section == 1){
        
    } else {
        NSString * identifier = _dataArray[indexPath.section][indexPath.row];
        
        // 保护identitier 不会因此造成崩溃
        if ([identifier isKindOfClass:[NSString class]]) {
            if ([identifier isEqualToString:@"baojingqi"]) {
                
            }else if ([identifier isEqualToString:@"yaokongqi"]) {
                // 远程控制
                /*
                NSString *deviceid = [NSString stringWithFormat:@"%@", @([self.bikeDomain ableRemote_ctrlDevice].device_id)];
                G100GPSRemoteCtrlView *view = [[G100GPSRemoteCtrlView alloc] init];
                view.userid = self.userid;
                view.bikeid = self.bikeid;
                view.devid = deviceid;
                
                G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
                G100DeviceDomain *deviceDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:deviceid];
                G100CardModel *cardModel = [[G100CardModel alloc] init];
                cardModel.devid = deviceid;
                cardModel.bike = bikeDomain;
                cardModel.device = deviceDomain;
                
                view.cardModel = cardModel;
                
                [view showInVc:self view:self.view animation:YES];
                 */
            }else if ([identifier isEqualToString:@"soundset"]) {
                G100AlertorSoundSelcetViewController *viewController = [[G100AlertorSoundSelcetViewController alloc] init];
                viewController.userid = self.userid;
                viewController.bikeid = self.bikeid;
                viewController.devid = self.G500Devid;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
}

#pragma mark - 更新当前车辆设置
-(void)updateCurrenfMsgMode:(NSInteger)mode {
    // 先刷新  为了用户体验
    self.statusSelected = [self indexOfDevModeWithMode:mode];
    [self.tableView reloadData];
    
    __weak G100FunctionViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [[UserManager shareManager] updateDevInfoWithUserid:self.userid bikeid:self.bikeid devid:self.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:wself.userid bikeid:self.bikeid devid:wself.devid];
                wself.statusSelected = [self indexOfDevModeWithMode:devDomain.security.mode];
                [wself.tableView reloadData];
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [[G100BikeApi sharedInstance] setBikeSecuritySettingsWithUserid:self.userid bikeid:self.bikeid devid:self.devid mode:mode callback:callback];
}

-(void)updateAlertSwitchWithDevid:(NSString *)devid alertor:(NSInteger)alertor complete:(void (^)())completeBlock {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak G100FunctionViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            // 刷新设备列表
            if (completeBlock) {
                completeBlock();
            }
            
            [[UserManager shareManager] updateDevInfoWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself createDataSource];
                    [wself.tableView reloadData];
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [self showHudInView:self.contentView hint:nil];
    [[G100DevApi sharedInstance] setAlertSwitchWithDevid:devid alertor:alertor callback:callback];
}

#pragma mark - 懒加载
- (UIView *)pushNotOpenView {
    if (!_pushNotOpenView) {
        self.pushNotOpenView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
        self.pushNotOpenView.backgroundColor = RGBColor(245, 153, 0, 1.0);
        
        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.textColor = [UIColor whiteColor];
        hintLabel.font = [UIFont systemFontOfSize:15];
        hintLabel.numberOfLines = 0;
        if ([NotificationHelper canOpenSystemNotificationSettingPage]) {
            hintLabel.text = @"系统推送未打开，点击去设置";
        }else {
            hintLabel.text = @"系统推送未打开，请前往设置-骑卫士-通知 选择打开通知";
        }
        [self.pushNotOpenView addSubview:hintLabel];
        
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.top.equalTo(@5);
            make.center.equalTo(@0);
            make.height.greaterThanOrEqualTo(@21);
        }];
        
        // 添加点击事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tl_gotoSetUserPush)];
        [self.pushNotOpenView addGestureRecognizer:tapGesture];
    }
    return _pushNotOpenView;
}

#pragma mark - 判断用户是否开启推送
- (void)tl_judgeUserPushIsOrNotOpen:(NSNotification *)noti {
    if (![[NotificationHelper shareInstance] notificationServicesEnabled]) {
        self.pushNotOpenView.hidden = NO;
        
        [self.tableViewTopMasConstraint uninstall];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.tableViewTopMasConstraint = make.top.equalTo(self.pushNotOpenView.mas_bottom);
        }];
    }else {
        self.pushNotOpenView.hidden = YES;
        
        [self.tableViewTopMasConstraint uninstall];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.tableViewTopMasConstraint = make.top.equalTo(@0);
        }];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.tableView layoutIfNeeded];
        [self.tableView layoutSubviews];
    } completion:^(BOOL finished) {
        [self createDataSource];
        [self.tableView reloadData];
    }];
}

- (void)tl_gotoSetUserPush {
    [NotificationHelper openSystemNotificationSettingPage];
}

#pragma mark - 微信绑定授权
-(void)bindWxAuth {
    self.partner = @"wx";
    
    [G100ThirdAuthManager getThirdWechatAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        } else {
            [self authSuccessWith:thirdAccount];
        }
    }];
}
#pragma mark - 授权成功
-(void)authSuccessWith:(UMSocialUserInfoResponse *)snsAccount {
    self.partneraccount = snsAccount.openid.length ? snsAccount.openid :snsAccount.uid;
    self.partneruseruid = snsAccount.uid;
    
    // 制作用户的临时密码 临时密码格式：360[渠道][用户id]QWS[YYYYMMDD] + md5
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * pw = [formatter stringFromDate:[NSDate date]];
    
    self.partneraccounttoken = [[NSString stringWithFormat:@"360%@%@QWS%@", self.partner, self.partneraccount, pw] stringFromMD5];
    
    // 判断是否存在第三方登录信息
    __weak G100FunctionViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // 调登录接口   此处肯定不存在该帐号
            [wself showHint:@"该平台已绑定其他帐号"];
        }else {
            // 不存在  去注册
            if (response) {
                if (response.errCode == 57) {
                    [wself authorizeBindThird];
                }else if (response.errCode == 56) {
                    [wself showHint:@"请检查系统时间是否正确"];
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

-(void)authorizeBindThird {
    __weak G100FunctionViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        [wself hideHud];
        if (requestSucces) {
            [wself showHint:@"授权成功"];
            // 绑定微信成功后 主动检查用户是否关注骑卫士公众号 然后提示开通
            if (wself.wx_infoDict && wself.wx_indexPath) {
                [wself tl_openWxAlarmWithDict:wself.wx_infoDict oldStatus:wself.wx_oldStatsus indexPath:wself.wx_indexPath];
            }
            
            wself.wx_oldStatsus = NO;
            wself.wx_infoDict = nil;
            wself.wx_indexPath = nil;
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_bindPartnerRelationPartner:_partner
                                                 partneraccount:_partneraccount
                                                   partnertoken:_partneraccounttoken
                                               partner_user_uid:_partneruseruid
                                                       callback:callback];
}

#pragma mark - 开通微信报警提醒
/**
 *  开通微信报警提醒
 *
 *  @param dict      存储相关信息的字典
 *  @param oldStatus 旧开关状态
 *  @param indexPath 所在的索引信息
 */
- (void)tl_openWxAlarmWithDict:(NSMutableDictionary *)dict oldStatus:(BOOL)oldStatus indexPath:(NSIndexPath *)indexPath {
    // 开启报警
    __weak G100FunctionViewController *wself = self;
    [wself showHudInView:wself.contentView hint:nil];
    [[G100UserApi sharedInstance] sv_checkWxmpWithCallback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        if (requestSuccess) {
            // 符合 可以开始绑定微信报警通知
            G100WebViewController *webVC = [G100WebViewController loadNibWebViewController];
            __weak G100WebViewController *weakWebVC = webVC;
            webVC.whenWebCloseTodoEventBlock = ^(void (^result)()){
                [wself showHudInView:KEY_WINDOW hint:nil];
                [[G100BikeApi sharedInstance] setWXNotifyWithBikeid:wself.bikeid notify:YES callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    [wself hideHud];
                    if (requestSuccess) {
                        wself.isFirstWechatPermission = YES;
                        [wself showHint:@"微信报警通知开通成功"];
                        [[UserManager shareManager] updateDevInfoWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            if (requestSuccess) {
                                [wself createDataSource];
                                [wself.tableView reloadData];
                            }
                        }];
                        
                        if (result) {
                            result();
                        }
                    }else
                        [weakWebVC showHint:response.errDesc];
                }];
            };
            webVC.userid  = wself.userid;
            webVC.devid   = wself.devid;
            webVC.httpUrl = [[G100UrlManager sharedInstance]getWeChatAlarmProtocolUrl:0];
            [wself.navigationController pushViewController:webVC animated:YES];
            
        }else if (response.errCode == SERV_RESP_ERROR_NOBIND_WX) {
            // 没有绑定微信帐号 提示绑定微信帐号
            G100NewPromptDefaultBox *box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
            [box showPromptBoxWithTitle:@"您尚未绑定微信" content:@"请先完成绑定微信" confirmButtonTitle:@"去绑定" cancelButtonTitle:@"返回" event:^(NSInteger index) {
                if (index == 0) {
                    // 去绑定微信
                    [wself bindWxAuth];
                }
                [box dismissWithVc:wself animation:YES];
                
            } onViewController:wself onBaseView:wself.view];
            
        }else if (response.errCode == SERV_RESP_ERROR_NOATTENTION_WX) {
            // 没有关注骑卫士公众号
            G100NewPromptDisplayBox *box = [G100NewPromptDisplayBox promptAlertViewDisplayStyle];
            [box showPromptBoxWithConfirmButtonTitle:@"已关注" otherButtonTitle:@"去关注" cancelButtonTitle:@"返回" event:^(NSInteger index) {
                if (index == 0) {
                    // 已关注 跳转协议页面
                    [wself showHudInView:wself.contentView hint:nil];
                    [[G100UserApi sharedInstance] sv_checkWxmpWithCallback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        [wself hideHud];
                        if (requestSuccess) {
                            [box dismissWithVc:wself animation:YES];
                            G100WebViewController *webVC = [G100WebViewController loadNibWebViewController];
                            __weak G100WebViewController *weakWebVC = webVC;
                            webVC.whenWebCloseTodoEventBlock = ^(void (^result)()){
                                [wself showHudInView:KEY_WINDOW hint:nil];
                                [[G100BikeApi sharedInstance] setWXNotifyWithBikeid:wself.bikeid notify:YES callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                    [wself hideHud];
                                    if (requestSuccess) {
                                        wself.isFirstWechatPermission = YES;
                                        [wself showHint:@"微信报警通知开通成功"];
                                        [[UserManager shareManager] updateDevInfoWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                            if (requestSuccess) {
                                                [wself createDataSource];
                                                [wself.tableView reloadData];
                                            }
                                        }];
                                        
                                        if (result) {
                                            result();
                                        }
                                    }else
                                        [weakWebVC showHint:response.errDesc];
                                }];
                            };
                            webVC.userid  = wself.userid;
                            webVC.devid   = wself.devid;
                            webVC.httpUrl = [[G100UrlManager sharedInstance]getWeChatAlarmProtocolUrl:0];
                            [wself.navigationController pushViewController:webVC animated:YES];
                        }else {
                            [wself showHint:response.errDesc];
                        }
                    }];
                }else if (index == 1) {
                    // 去关注微信公众号
                    /**
                     * 微信沟通接口失效
                    if ([WXApi isWXAppInstalled]) {
                        JumpToBizWebviewReq *req = [[JumpToBizWebviewReq alloc] init];
                        req.tousrname = @"gh_ff67146ac148";
                        [WXApi sendReq:req];
                    }else {
                        WechatQRView *wechatQRView = [[[NSBundle mainBundle]loadNibNamed:@"WechatQRView" owner:wself options:nil] firstObject];
                        [wechatQRView showInVc:wself view:wself.view animation:YES];
                    }
                     */
                    
                    WechatQRView *wechatQRView = [[[NSBundle mainBundle]loadNibNamed:@"WechatQRView" owner:wself options:nil] firstObject];
                    [wechatQRView showInVc:wself view:wself.view animation:YES];
                }else if (index == 2) {
                    [box dismissWithVc:wself animation:YES];
                }
            } onViewController:wself onBaseView:wself.view];
        }
    }];
}


/**
 开通电话报警

 @param devid    设备id
 @param phoneNum 手机号
 */
- (void)tl_openPhoneAlarmWithBikeid:(NSString *)bikeid devid:(NSString *)devid phoneNum:(NSString *)phoneNum {
    __weak __typeof(self) wself = self;
    G100WebViewController *webVC = [G100WebViewController loadNibWebViewController];
    webVC.whenWebCloseTodoEventBlock = ^(void (^result)()){
        __strong __typeof__(wself) strongSelf = wself;
        [strongSelf showHudInView:KEY_WINDOW hint:nil];
        
        [[G100ABManager sharedInstance] checkAddressBookAuthorization:^(bool isAuthorized) {
            if (!isAuthorized) {
                [strongSelf hideHud];
                [CURRENTVIEWCONTROLLER showWarningHint:@"请先到“设置-隐私-通讯录”开启权限"];
                return;
            }
            
            [[G100BikeApi sharedInstance] setPhoneNotifyWithBikeid:strongSelf.bikeid phoneNum:phoneNum notify:YES callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                [strongSelf hideHud];
                if (requestSuccess) {
                    strongSelf.isFirstPhonePermission = YES;
                    [CURRENTVIEWCONTROLLER showHint:@"电话报警通知开通成功"];
                    [[UserManager shareManager] updateDevInfoWithUserid:strongSelf.userid bikeid:strongSelf.bikeid devid:strongSelf.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        if (requestSuccess) {
                            [strongSelf createDataSource];
                            [strongSelf.tableView reloadData];
                        }
                    }];
                    
                    // 写入报警电话
                    [[G100ABManager sharedInstance] ab_checkUpdateWithType:AB_CheckUpdateTypeAlarm checkComplete:nil];
                    
                    if (result) {
                        result();
                    }
                }else {
                    [CURRENTVIEWCONTROLLER showHint:response.errDesc];
                }
            }];
        }];
    };
    webVC.userid  = wself.userid;
    webVC.devid   = wself.devid;
    webVC.httpUrl = [[G100UrlManager sharedInstance] getPhoneAlarmProtocolUrl:0];
    [wself.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"安防设置"];
    
    // 创建数据源
    [self createDataSource];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.tableViewTopMasConstraint = make.top.equalTo(0);
        make.bottom.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
    
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    [_tableView registerNib:[UINib nibWithNibName:@"SetSelecteCell" bundle:nil] forCellReuseIdentifier:@"statuscell"];
    
    // 添加顶部提醒
    [self.contentView addSubview:self.pushNotOpenView];
    [self.pushNotOpenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.leading.and.trailing.equalTo(@0);
    }];
    
    self.pushNotOpenView.hidden = YES;
    
    // 状态提醒模式添加完毕
    G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    _statusSelected = [self indexOfDevModeWithMode:devDomain.security.mode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tl_judgeUserPushIsOrNotOpen:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
//    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.devid && self.userid) {
        __weak G100FunctionViewController * wself = self;
        [[UserManager shareManager] updateDevInfoWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (requestSuccess) {
                [wself createDataSource];
                [wself.tableView reloadData];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isFirstWechatPermission) {
        G100PushAlarmTestView *testView = [[G100PushAlarmTestView alloc] init];
        testView.userid = self.userid;
        testView.bikeid = self.bikeid;
        testView.devid = self.devid;
        testView.phoneNum = self.bikeDomain.mainDevice.security.phone_notify.callee_num;
        testView.isTrainTest = NO;
        testView.entrance = 2;
        
        [testView showInVc:self view:self.view animation:YES];
        
        self.isFirstWechatPermission = NO;
        return;
    }
    if (self.isFirstPhonePermission) {
        G100PushAlarmTestView *testView = [[G100PushAlarmTestView alloc] init];
        testView.userid = self.userid;
        testView.bikeid = self.bikeid;
        testView.devid = self.devid;
        testView.phoneNum = self.bikeDomain.mainDevice.security.phone_notify.callee_num;
        testView.isTrainTest = NO;
        testView.entrance = 3;
        
        [testView showInVc:self view:self.view animation:YES];
        
        self.isFirstPhonePermission = NO;
        return;
    }
    
    [self tl_judgeUserPushIsOrNotOpen:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

@end
