//
//  G100CardDevStateViewController.m
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardDevStateViewController.h"
#import "G100DevStateView.h"
#import "G100InfoHelper.h"
#import "G100Mediator+GPS.h"
#import "G100Mediator+BikeReport.h"
#import "G100Mediator+HelpFindBike.h"
#import "G100Mediator+BikeFinding.h"
#import "G100Mediator+ServiceStatus.h"
#import "G100Mediator+SecuritySetting.h"
#import "G100DevDataHandler.h"
#import "G100BikesRuntimeDomain.h"
#import "G100DevPositionDomain.h"
#import "G100InfoHelper.h"

#import "G100DevApi.h"

#define WIFI_REFRESH_INTERVAL 5.0

@interface G100CardDevStateViewController () <G100DevDataHandlerDelegate> {
    BOOL hasAppear;
}

@property (nonatomic, strong) G100DevStateView * stateView;

@property (nonatomic, strong) G100DevDataHandler * dataHandler;

@property (nonatomic, assign) NSInteger networkStatus;

@property (nonatomic, strong) G100BikesRuntimeDomain * bikesRuntimeDomain;

@property (strong, nonatomic) G100DevPositionDomain * positonDomain;

@property (assign, nonatomic) CGFloat lati;

@property (assign, nonatomic) CGFloat longi;

@end

@implementation G100CardDevStateViewController

- (void)dealloc {
    DLog(@"DeviceState 已经销毁");
    
    _dataHandler.delegate = nil;
    _dataHandler = nil;
}

#pragma mark - lazy loading
- (G100DevStateView *)stateView {
    if (!_stateView) {
        _stateView = [G100DevStateView loadDevStateView];
    }
    return _stateView;
}

#pragma mark - Public method
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    
    [self.stateView configDeviceIndex:cardModel.orderIndex count:cardModel.bike.gps_devices.count];
    
    if (cardModel.device.main_device == 0) {
        [self.stateView configViewWithState:DevStateTypeViceUser];
    }
    else {
        if (cardModel.bike.state == 4) {
            [self.stateView configViewWithState:DevStateTypeFinding];
        }else {
            [self.stateView configViewWithState:DevStateTypeNormal];
        }
    }
    
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    [self.stateView configDeviceName:cardModel.device.name];
    [self.stateView configDataWithLati:self.lati longi:self.longi];
    [self.stateView configDeviceSecurityMode:cardModel.device.security.mode];
    [self.stateView configDeviceLeft_dayes:cardModel.device.service.left_days];
    [self.stateView configViewWithSimCardState:cardModel.device.model_type_id];
}

#pragma mark - 电动车加解锁   1   加锁  2   解锁
-(void)lockOrUnLockDev:(NSString *)devid lock:(NSInteger)lock showHUD:(BOOL)showHUD callback:(void (^)(BOOL isSuccess))scallback {
    __weak typeof(self) wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (showHUD) {
            [wself.topParentViewController hideHud];
        }
        
        if (requestSucces) {
            NSInteger status = [[response.data objectForKey:@"controllerstatus"] integerValue];
            
            if (self.stateView.powerStateType != status) {
                self.stateView.powerStateType = status;
            }
            
            [UIView animateWithDuration:0.3f animations:^{
                wself.stateView.findingView.secondView.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    wself.stateView.findingView.secondView.alpha = 1;
                }];
            }];
        }else {
            if (lock == 1) {
                [wself.topParentViewController showWarningHint:@"断电失败"];
            }else {
                [wself.topParentViewController showWarningHint:@"供电失败"];
            }
        }
    };
    if (showHUD) {
        if (lock == 1) {
            [self.topParentViewController showHudInView:self.topParentViewController.view hint:@"正在断电"];
        }else {
            [self.topParentViewController showHudInView:self.topParentViewController.view hint:@"正在供电"];
        }
    }
    
    [[G100DevApi sharedInstance] controllerLockWithBikeid:self.bikeid devid:self.devid lock:lock callback:callback];
}

#pragma mark G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.errCode == 0) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];

        BOOL hasDeviceLocation = NO;
        for (G100BikeRuntimeDomain * bikeDomain in self.bikesRuntimeDomain.runtime) {
            
            if ([bikeid integerValue] == bikeDomain.bike_id) {
                // 如果该设备是主设备 则直接取车辆的定位信息
                if ([_cardModel.device isMainDevice]) {
                    hasDeviceLocation = YES;
                    self.lati = bikeDomain.lati;
                    self.longi = bikeDomain.longi;
                    [self.stateView setPowerStateType:bikeDomain.controller_status];
                    [self.stateView configDataWithLati:bikeDomain.lati longi:bikeDomain.longi];
                }
                else {
                    for (NSDictionary *dict in bikeDomain.device_runtimes) {
                        G100DeviceRuntimeDomain * deviceRuntimeDomain = [[G100DeviceRuntimeDomain alloc] initWithDictionary:dict];
                        NSString * devid = [NSString stringWithFormat:@"%@",@(deviceRuntimeDomain.device_id)];
                        if ([devid isEqualToString:self.devid]) {
                            hasDeviceLocation = YES;
                            self.lati = deviceRuntimeDomain.lati;
                            self.longi = deviceRuntimeDomain.longi;
                            [self.stateView setPowerStateType:bikeDomain.controller_status];
                            [self.stateView configDataWithLati:deviceRuntimeDomain.lati longi:deviceRuntimeDomain.longi];
                            break;
                        }
                    }
                }
                
                break;
            }
        }
        
        if (!hasDeviceLocation) {
            // 没有找到与本车相关的定位信息 恢复默认状态
            self.lati = 0;
            self.longi = 0;
            [self.stateView configDataWithLati:0 longi:0];
        }
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 布局
    __weak __typeof__(self) weakSelf = self;
    [self.view addSubview:self.stateView];
    [self.stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.stateView.mapTapAction = ^(){
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:weakSelf.userid
                                                                                                     bikeid:weakSelf.bikeid
                                                                                                      devid:weakSelf.devid];
        [weakSelf.navigationController pushViewController:viewController animated:YES];
    };
    
    self.stateView.normalFunctionTapAction = ^(NSInteger index){
        if (index == 0) {
            // 安防设置
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSecuritySetting:weakSelf.userid
                                                                                                                     bikeid:weakSelf.bikeid
                                                                                                                      devid:weakSelf.devid];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }else if (index == 1) {
            // 用车报告
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeReport:weakSelf.userid
                                                                                                                bikeid:weakSelf.bikeid
                                                                                                                 devid:weakSelf.devid];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }else if (index == 2) {
            // 服务状态
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForServiceStatus:weakSelf.userid
                                                                                                                   bikeid:weakSelf.bikeid
                                                                                                                    devid:weakSelf.devid];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }else if (index == 3) {
            G100BikeDomain * bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:weakSelf.userid bikeid:weakSelf.bikeid];
            if (![bikeDomain.is_master integerValue]) {
                [weakSelf.parentViewController showHint:@"副用户不提供此功能"];
                return;
            }
            // 帮我找车
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForHelpFindBike:weakSelf.userid
                                                                                                                  bikeid:weakSelf.bikeid
                                                                                                                   devid:weakSelf.devid];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }
    };
    
    self.stateView.findingFunctionTapAction = ^(NSInteger index, GPSType type){
        if (index == 0) {
            // 寻车记录 仅针对主用户有效
            if (!weakSelf.bikeDomain.isMaster) {
                [weakSelf.parentViewController showHint:@"副用户不提供此功能"];
                return;
            }
            
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeFinding:weakSelf.userid
                                                                                                                 bikeid:weakSelf.bikeid
                                                                                                                 lostid:weakSelf.bikeDomain.lost_id];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }else if (index == 1) {
            // 供断电 仅针对主用户有效
            if (!weakSelf.bikeDomain.isMaster) {
                [weakSelf.parentViewController showHint:@"副用户不提供此功能"];
                return;
            }
            
            if (weakSelf.stateView.powerStateType == PowerStateTypeRecovered) {
                [weakSelf lockOrUnLockDev:weakSelf.bikeid lock:1 showHUD:YES callback:nil];
            }else if (weakSelf.stateView.powerStateType == PowerStateTypePowerOffed) {
                [weakSelf lockOrUnLockDev:weakSelf.bikeid lock:2 showHUD:YES callback:nil];
            }
        }else if (index == 2) {
            // 用车报告 或 安防设置
            if (type == GPSTypeNoSuit) {
                // 用车报告
                UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeReport:weakSelf.userid
                                                                                                                    bikeid:weakSelf.bikeid
                                                                                                                     devid:weakSelf.devid];
                [weakSelf.navigationController pushViewController:viewController animated:YES];
            }else if (type == GPSTypeSuit) {
                // 安防设置
                UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSecuritySetting:weakSelf.userid
                                                                                                                         bikeid:weakSelf.bikeid
                                                                                                                          devid:weakSelf.devid];
                [weakSelf.navigationController pushViewController:viewController animated:YES];
            }else {
                ;
            }
        }else {
            ;
        }
    };
    
    self.stateView.viceUserFunctionTapActiom = ^(){
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForServiceStatus:weakSelf.userid
                                                                                                               bikeid:weakSelf.bikeid
                                                                                                                devid:weakSelf.devid];
        [weakSelf.navigationController pushViewController:viewController animated:YES];
    };
    
    // 实例化观察者
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

#pragma mark - 出现/消失
- (void)mdv_viewWillAppear:(BOOL)animated {
    [super mdv_viewWillAppear:animated];
    
    [self.stateView mdv_viewWillAppear:animated];
}
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
    [self.stateView mdv_viewDidAppear:animated];
}
- (void)mdv_viewWillDisappear:(BOOL)animated {
    [super mdv_viewWillDisappear:animated];
    
    [self.stateView mdv_viewWillDisappear:animated];
}
- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
    [self.stateView mdv_viewDidDisappear:YES];
}

@end
