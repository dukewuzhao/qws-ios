//
//  G100CardRemoteCtrlViewController.m
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardRemoteCtrlViewController.h"
#import "G100MainDetailViewController.h"
#import "G100CardRemoteCtrlView.h"
#import "G100RemoteCtrlManager.h"

#import "G100DeviceDomain.h"
#import "G100DevDataHandler.h"

#import "G100BikesRuntimeDomain.h"

static CGFloat kSendOrderTimeOutTimeInterval = 30.0;

@interface G100CardRemoteCtrlViewController () <G100CardRemoteCtrlViewDelegate, G100DevDataHandlerDelegate> {
    BOOL _isCommandSending;
    
    /** 表示当前是否使用5s 间隔的频率*/
    BOOL _customDataHandler;
}

@property (nonatomic, strong) G100CardRemoteCtrlView *remoteCtrlView;
@property (nonatomic, strong) G100DevDataHandler *dataHandler;

@property (nonatomic, strong) G100BikesRuntimeDomain *bikesRuntimeDomain;

@property (nonatomic, strong) NSTimer *sendOrderTimeOutTimer;
@property (nonatomic, strong) G100RTCommandModel *sendingCommand;

@end

@implementation G100CardRemoteCtrlViewController

- (void)dealloc {
    DLog(@"rtview 已经销毁");
    
    _dataHandler.delegate = nil;
    _dataHandler = nil;
}

#pragma mark - Lazzy load
- (G100CardRemoteCtrlView *)remoteCtrlView {
    if (!_remoteCtrlView) {
        _remoteCtrlView = [[G100CardRemoteCtrlView alloc]init];
        _remoteCtrlView.rtStatus = 2;
        _remoteCtrlView.delegate = self;
    }
    return _remoteCtrlView;
}

#pragma mark - G100CardRemoteCtrlViewDelegate
- (void)cardRemoteCtrlView:(G100CardRemoteCtrlView *)ctrlView commandViewDidTapped:(G100RTCollectionViewCell *)viewCell {
    if (_isCommandSending) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(remoteCommandSendResult:result:) object:nil];
    
    _isCommandSending = YES;
    self.remoteCtrlView.isCommandSending = YES;
    self.remoteCtrlView.topStatusView.mwsSwitch.mws_enable = NO;
    [self.remoteCtrlView.topStatusView mws_sendCommand:viewCell.rtCommand];
    
    
    if (viewCell.rtCommand.rt_status == 2) {
        // GPRS 远程控制
        __weak __typeof__(self) weakSelf = self;
        API_CALLBACK callbakck = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                // 判断当前是不是正在发送指令 设防 撤防 开电门 关电门 一键启动 需要等待 其他直接返回
                if (viewCell.rtCommand.rt_command == 1 ||
                    viewCell.rtCommand.rt_command == 2 ||
                    viewCell.rtCommand.rt_command == 3 ||
                    viewCell.rtCommand.rt_command == 8) {
                    [weakSelf startCheckOrderSendStatus:viewCell.rtCommand];
                    [weakSelf remoteCommandSendResult:viewCell.rtCommand result:2];
                }else {
                    [weakSelf remoteCommandSendResult:viewCell.rtCommand result:1];
                }
            }else {
                [weakSelf.topParentViewController showHint:response.errDesc];
                [weakSelf remoteCommandSendResult:viewCell.rtCommand result:0];
            }
        };
        
        // 发送远程控制指令
        [[G100RemoteCtrlManager sharedInstance] operateAlertorWithBikeid:self.bikeid
                                                                   devid:self.devid
                                                                 command:viewCell.rtCommand.rt_command
                                                           commandParams:@{@"type" : [NSNumber numberWithInt:viewCell.rtCommand.rt_type]}
                                                                    type:viewCell.rtCommand.rt_type
                                                                callback:callbakck];
    }else if (viewCell.rtCommand.rt_status == 1) {
        // BLE 远程控制
        [self performSelector:@selector(remoteCommandSendResult:result:) withObject:viewCell.rtCommand afterDelay:3.0];
    }else {
        [self remoteCommandSendResult:viewCell.rtCommand result:0];
    }
}

/**
 *  发送指令完成 停止动画 恢复状态
 *
 *  @param command 指令对应id
 *  @param result  指令发送结果 0 失败 1 成功 2 发送过程中 3 用户取消（暂不支持取消指令）
 */
- (void)remoteCommandSendResult:(G100RTCommandModel *)rtCommand result:(int)result {
    if (result != 2) {
        // 最终结果
        [self stopCheckOrderSendStatus];
    }
    
    _isCommandSending = NO;
    self.remoteCtrlView.isCommandSending = NO;
    self.remoteCtrlView.topStatusView.mwsSwitch.mws_enable = YES;
    [self.remoteCtrlView.topStatusView mws_completeCommand:rtCommand result:result];
}

- (void)cardRemoteCtrlView:(G100CardRemoteCtrlView *)ctrlView switchDidChanged:(G100CtrlTopStatusView *)topStatusView status:(int)status {
    if ([_cardModel.ownerVc isKindOfClass:NSClassFromString(@"G100MainDetailViewController")]) {
        
        [[G100InfoHelper shareInstance] updateMyDevListWithUserid:self.userid bikeid:self.bikeid devid:self.devid devInfo:@{@"remote_ctrl_mode" : @(status)}];
        G100MainDetailViewController *ownerVc = (G100MainDetailViewController *)_cardModel.ownerVc;
        
        [UIView animateWithDuration:0.3 animations:^{
            
        } completion:^(BOOL finished) {
            [ownerVc reloadRowsAtIndexPaths:_cardModel.indexPath
                           withRowAnimation:UITableViewRowAnimationNone
                           atScrollPosition:UITableViewScrollPositionBottom
                                   animated:YES];
        }];
        
    }
}

#pragma mark G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.errCode == 0) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
        for (G100BikeRuntimeDomain * bikeRuntimeDomain in self.bikesRuntimeDomain.runtime) {
            if ([bikeid integerValue] == bikeRuntimeDomain.bike_id) {
                [self.remoteCtrlView mws_setupGPRS_signalLevel:(int)bikeRuntimeDomain.bs_level];
                [self.remoteCtrlView mws_setupSecurityStatus:(int)bikeRuntimeDomain.alertor_status.security];
                
                // 判断当前是不是正在发送指令 1 设防 2 撤防 3.1 开电门 3.2关电门 8 一键启动 需要等待 其他直接返回
                if (self.sendingCommand != nil) {
                    if (self.sendingCommand.rt_command == 1 ||
                        self.sendingCommand.rt_command == 2 ||
                        self.sendingCommand.rt_command == 3 ||
                        self.sendingCommand.rt_command == 8){
                        if (self.sendingCommand.rt_command == 1) {
                            // 设防
                            if (bikeRuntimeDomain.alertor_status.security == 2) {
                                [self remoteCommandSendResult:self.sendingCommand result:1];
                            }
                        }else if (self.sendingCommand.rt_command == 2) {
                            // 撤防
                            if (bikeRuntimeDomain.alertor_status.security == 4) {
                                [self remoteCommandSendResult:self.sendingCommand result:1];
                            }
                        }else if (self.sendingCommand.rt_command == 3) {
                            // 电门
                            if (self.sendingCommand.rt_type == 1) {
                                // 开电门
                                if (bikeRuntimeDomain.acc == 1) {
                                    [self remoteCommandSendResult:self.sendingCommand result:1];
                                }
                            }else if (self.sendingCommand.rt_type == 2) {
                                // 关电门
                                if (bikeRuntimeDomain.acc == 0) {
                                    [self remoteCommandSendResult:self.sendingCommand result:1];
                                }
                            }
                        }else if (self.sendingCommand.rt_command == 8) {
                            // 一键启动
                            if (bikeRuntimeDomain.acc == 1) {
                                [self remoteCommandSendResult:self.sendingCommand result:1];
                            }
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - Setter/Getter
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.bikeDomain = cardModel.bike;
    
    [self.remoteCtrlView.dataGPSArray removeAllObjects];
    
    // 构造功能按钮
    G100DeviceDomain *devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    
    NSInteger count = 0;
    NSInteger i = 0;
    for (NSNumber *result in devDomain.func.alertor.remote_ctrl_func) {
        if ([result integerValue] == 1) {
            G100RTCommandModel *rtModel = nil;
            if (i == 0) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"设防" image:@"ic_rc_garrison" command:1];
            }else if (i == 1) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"撤防" image:@"ic_rc_disarm" command:2];
            }else if (i == 2) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"开电门" image:@"ic_rc_switch_open" command:3];
            }else if (i == 3) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"关电门" image:@"ic_rc_switch_close" command:3];
                rtModel.rt_type = 2; // 关电门
            }else if (i == 4) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"开坐桶" image:@"ic_rc_barrel_open" command:5];
            }else if (i == 5) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"中撑锁" image:@"ic_rc_staysLock" command:6];
            }else if (i == 6) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"寻车" image:@"ic_rc_find_car" command:4];
            }else if (i == 7) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"龙头锁" image:@"ic_rc_faucetLock" command:7];
            }else if (i == 8){
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"一键启动" image:@"ic_rc_onekey_start" command:8];
            }else if (i == 9) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"追车报警" image:@"ic_rc_car_chase" command:9];
            }else if (i == 10) {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"低速挡" image:@"ic_rc_speed_low" command:10];
            }else {
                rtModel = [G100RTCommandModel rt_commandModelWithTitle:@"通用" image:@"ic_rc_default" command:99];
            }
            
            if (count == 0 || count == 1) {
                rtModel.tintColorStr = @"00c2a3";
            } else if (count == 2 || count == 3) {
                rtModel.tintColorStr = @"62dc00";
            } else if (count == 4 || count == 5) {
                rtModel.tintColorStr = @"1fc6ff";
            } else if (count == 6 || count == 7 || count == 9) {
                rtModel.tintColorStr = @"da99ed";
            } else {
                rtModel.tintColorStr = @"00c2a3";
            }
            
            [self.remoteCtrlView.dataGPSArray addObject:rtModel];
            count++;
        }
        i++;
    }
    
    NSInteger remaindCount = (count%4 == 0 ? 0 : 4 - count%4);
    for (NSInteger i = 0; i < remaindCount; i++) {
        [self.remoteCtrlView.dataGPSArray addObject:[G100RTCommandModel rt_commandEmpty]];
    }
    
    if (cardModel.device.remote_ctrl_mode == 1) {
        // 选中蓝牙模式
        [self.remoteCtrlView setStatus:1];
    }else {
        [self.remoteCtrlView setStatus:2];
    }
    
    [self refreshSignalLevel];
}

#pragma mark - Private Method
- (void)refreshSignalLevel {
    //[self.remoteCtrlView mws_setupBLE_signalLevel:rand()%2];
    //[self.remoteCtrlView mws_setupGPRS_signalLevel:rand()%5];
}

- (void)startCheckOrderSendStatus:(G100RTCommandModel *)command {
    _customDataHandler = YES;
    
    self.sendingCommand = command;
    
    [self.dataHandler removeConcern];
    [self.dataHandler addConcernByCustomInterval];
    
    self.sendOrderTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:kSendOrderTimeOutTimeInterval
                                                                  target:self
                                                                selector:@selector(timeOutCheckOrderSendStatus)
                                                                userInfo:nil
                                                                 repeats:NO];
}

- (void)stopCheckOrderSendStatus {
    _customDataHandler = NO;
    
    self.sendingCommand = nil;
    
    [self.dataHandler removeConcernByCustomInterval];
    [self.dataHandler addConcern];
    
    if ([self.sendOrderTimeOutTimer isValid]) {
        [_sendOrderTimeOutTimer invalidate];
        _sendOrderTimeOutTimer = nil;
    }
}

- (void)timeOutCheckOrderSendStatus {
    if (self.sendingCommand) {
        [self remoteCommandSendResult:self.sendingCommand result:0];
    }
    [self stopCheckOrderSendStatus];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 布局
    [self.view addSubview:self.remoteCtrlView];
    [self.remoteCtrlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    _isCommandSending = NO;
    _customDataHandler = NO;
    
    _dataHandler = [[G100DevDataHandler alloc] initWithUserid:self.userid bikeid:self.bikeid];
    _dataHandler.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 出现/消失
- (void)mdv_viewWillAppear:(BOOL)animated {
    [super mdv_viewWillAppear:animated];
    
}
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
}
- (void)mdv_viewWillDisappear:(BOOL)animated {
    [super mdv_viewWillDisappear:animated];
    
}
- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
}

- (void)freeIt {
    [super freeIt];
    
    _dataHandler.delegate = nil;
    _dataHandler = nil;
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
