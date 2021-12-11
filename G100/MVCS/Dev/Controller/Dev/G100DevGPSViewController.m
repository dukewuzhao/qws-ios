//
//  G100DevGPSViewController.m
//  G100
//
//  Created by yuhanle on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevGPSViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "CustomMAPointAnnotation.h"
#import "CustomMAAnnotationView.h"
#import "UIImage+Rotate.h"
#import "G100TrackingFunctionView.h"

#import "G100AMapOfflineMapViewController.h"
#import "DevPositionPaoPaoView.h"
#import "MAGeoCodeResult.h"
#import "G100RTCollectionViewCell.h"

#import "G100DevApi.h"
#import "G100DeviceDomain.h"

#import "G100Mediator+BikeReport.h"
#import "G100Mediator+HelpFindBike.h"
#import "G100Mediator+ServiceStatus.h"
#import "G100Mediator+SecuritySetting.h"
#import "G100Mediator+BuyService.h"
#import "G100Mediator+Management.h"
#import "G100Mediator+BikeFinding.h"

#import "G100DevManagementViewController.h"
#import "G100DevDataHandler.h"
#import "G100BikesRuntimeDomain.h"
#import "G100MapChangeView.h"

#import "G100GPSRemoteCtrlView.h"

#import "G100DoubleLabelView.h"
#import "G100DevSelectedView.h"
#import "G100HoledView.h"
#import "G100NetworkHintView.h"

#import "G100WebViewController.h"
#import "G100UrlManager.h"
#import "G100TopHintView.h"
#import "EBOfflineMapService.h"

NSString * DuiMaSuodingHint;
NSString * DuiMaUnSuodingHint;
NSString * InsuranceWarningHint;

NSString * DuiMaSuodingText;
NSString * DuiMaUnSuodingText;

NSString * DuiMaSuodingFailText;
NSString * DuiMaUnSuodingFailText;

NSString * DuiMaSuodingSendingText;
NSString * DuiMaUnSuodingSendingText;

NSString * DuiMaSuodingDealText;
NSString * DuiMaUnSuodingDealText;

#define kMapShowEdgeInset UIEdgeInsetsMake(120, 140, 200, 140)

@interface G100DevGPSViewController () <MAMapViewDelegate, G100TrackingFunctionViewDelegate, G100DevDataHandlerDelegate, G100DevSelectedViewDelegate,G100HoledViewDelegate, UIAlertViewDelegate, EBOfflineMapServiceDelegate,G100TopViewClickActionDelegate> {
    BOOL _hasLoacated;
    BOOL _hasTongxinFault;
    BOOL _viewDidAppear;
}

@property (nonatomic, assign) BOOL hasLoadLocationServiceUnknownNotice;

@property (strong, nonatomic) G100TrackingFunctionView * functionView;
@property (strong, nonatomic) G100MapChangeView * mapChangeView;

@property (nonatomic, strong) UIImageView *scaleBg;
@property (nonatomic, strong) UIButton *locationUserBtn;

@property (strong, nonatomic) MAUserLocation          *userLocation;
@property (strong, nonatomic) CustomMAPointAnnotation *userAnnotation;
@property (strong, nonatomic) NSMutableArray *deviceAnnotationsArray;

@property (assign, nonatomic) CLLocationCoordinate2D  userLocaitonCoordinate;

@property (strong, nonatomic) G100DeviceDomain * devDomain;
@property (strong, nonatomic) G100BikeDomain * bikeDomain;

@property (strong, nonatomic) G100DevDataHandler * dataHandler;
@property (strong, nonatomic) G100BikesRuntimeDomain * bikesRuntimeDomain;

@property (strong, nonatomic) UIButton * mapChangeBtn;
@property (strong, nonatomic) G100DoubleLabelView *dTitleLabelView;
@property (strong, nonatomic) G100DevSelectedView *devSelectedView;

@property (strong, nonatomic) NSString *selectedDevid;
@property (strong, nonatomic) CustomMAPointAnnotation *selectedDevAnnotation;
@property (assign, nonatomic) CLLocationCoordinate2D  selectedDevCoordinate;
@property (strong, nonatomic) MAGroundOverlay *eleCircle;
/** 记录设备数量没有变化前的设备个数 如果有变化的话 标注就需要刷新*/
@property (assign, nonatomic) NSInteger oldDeviceCount;

@property (strong, nonatomic) G100HoledView *holedView;
@property (strong, nonatomic) G100TopHintView *hintView;
@property (strong, nonatomic) EBOfflineMapService *ebservice;
@property (copy, nonatomic) NSString *adcode;
@property (nonatomic, strong) G100NetworkHintView *netview;
    
@end

@implementation G100DevGPSViewController

#pragma mark - Lazy Load Method
- (CustomMAPointAnnotation *)userAnnotation {
    if (!_userAnnotation) {
        _userAnnotation = [[CustomMAPointAnnotation alloc] init];
        _userAnnotation.type = 2;
    }
    return _userAnnotation;
}
- (NSMutableArray *)deviceAnnotationsArray {
    if (!_deviceAnnotationsArray) {
        _deviceAnnotationsArray = [[NSMutableArray alloc] init];
    }
    return _deviceAnnotationsArray;
}

- (EBOfflineMapService *)ebservice {
    if (!_ebservice) {
        _ebservice = [[EBOfflineMapService alloc] init];
        _ebservice.delegate = self;
    }
    return _ebservice;
}

- (G100TrackingFunctionView *)functionView {
    if (!_functionView) {
        _bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
        _functionView = [[G100TrackingFunctionView alloc] initWithShowBikeInfo:!_bikeDomain.isMOTOBike];
        _functionView.delegate = self;
    }
    return _functionView;
}

- (G100MapChangeView *)mapChangeView {
    if (!_mapChangeView) {
        _mapChangeView = [[G100MapChangeView alloc] initWithMapView:self.mapView
                                                           position:CGPointMake(self.mapChangeBtn.v_right, self.mapChangeBtn.v_bottom-8)];
        [self.contentView addSubview:_mapChangeView];
        
        __weak typeof(self) wself = self;;
        _mapChangeView.viewHideCompletion = ^(){
            wself.mapChangeBtn.selected = NO;
        };
    }
    return _mapChangeView;
}

- (G100DoubleLabelView *)dTitleLabelView {
    if (!_dTitleLabelView) {
        _dTitleLabelView = [[G100DoubleLabelView alloc] init];
    }
    return _dTitleLabelView;
}

- (G100DevSelectedView *)devSelectedView {
    if (!_devSelectedView) {
        _devSelectedView = [[G100DevSelectedView alloc] init];
        _devSelectedView.acpoint = CGPointMake(WIDTH - 20, 120);
        _devSelectedView.delegate = self;
    }
    return _devSelectedView;
}

- (G100DevDataHandler *)dataHandler {
    if (!_dataHandler) {
        _dataHandler = [[G100DevDataHandler alloc]initWithUserid:self.userid bikeid:self.bikeid];
        _dataHandler.delegate = self;
    }
    return _dataHandler;
}

-(G100TopHintView *)hintView{
    if (!_hintView) {
        _hintView = [[G100TopHintView alloc] init];
        _hintView.hintText = @"当前所在城市地图未下载，点击下载";
        _hintView.delegate = self;
    }
    return _hintView;
}

#pragma mark - 通知监听
- (void)setupNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(infoDomainDidChange:)
                                                 name:CDDDataHelperBikeInfoDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(infoDomainDidChange:)
                                                 name:CDDDataHelperDeviceInfoDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insepectNet)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
}

#pragma mark - initialData & setupView
- (void)initialData {
    _hasLoacated = NO;
    _selectedDevid = self.devid;
    
    self.devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    [self.functionView configDataWithBikeDomain:self.bikeDomain devDomain:self.devDomain bikesRuntimeDomain:self.bikesRuntimeDomain];
    
    self.dTitleLabelView.mainText = self.bikeDomain.name;
    NSInteger count = 0;
    for (G100DeviceDomain *device in self.bikeDomain.gps_devices) {
        if ([device isNormalDevice]) {
            count++;
        }
    }
    self.dTitleLabelView.viceText = [NSString stringWithFormat:@"本车已绑定%@台设备", @(count)];
    
    self.devSelectedView.dataArray = self.bikeDomain.gps_devices;
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;

    // 配置提示文案
    BOOL isG500 = self.devDomain.isG500Device;
    BOOL isMotoBike = self.bikeDomain.isMOTOBike;
    
    DuiMaSuodingHint     = isMotoBike ? @"远程断电后，车辆将无法正常启动，直至您开启供电。" : isG500 ? @"远程锁车后，车辆将进入设防状态，直至远程解锁后恢复正常。" : @"远程断电后，车辆将在停止后无法骑行，直至开启供电后恢复正常。";
    DuiMaUnSuodingHint   = isMotoBike ? @"开启供电后，车辆可以正常启动。" : isG500 ? @"请确认是否远程解锁，远程解锁后您的车辆将恢复正常状态。" : @"请确认是否开启供电，开启供电后您的车辆将恢复正常状态。";
    InsuranceWarningHint = isMotoBike ? @"保险车辆的盗抢险已进入破案等待期流程，启动“开启供电”程序将默认您已找回车辆，此次报案将消除同时系统将为您恢复保险保障。" : isG500 ? @"保险车辆的盗抢险已进入破案等待期流程，启动“远程解锁”程序将默认您已找回车辆，此次报案将消除同时系统将为您恢复保险保障。" : @"保险车辆的盗抢险已进入破案等待期流程，启动“恢复供电”程序将默认您已找回车辆，此次报案将消除同时系统将为您恢复保险保障。";
    
    DuiMaSuodingText   = isMotoBike ? @"远程断电" : isG500 ? @"远程锁车" : @"远程断电";
    DuiMaUnSuodingText = isMotoBike ? @"开启供电" : isG500 ? @"远程解锁" : @"开启供电";
    
    DuiMaSuodingFailText   = isMotoBike ? @"远程断电失败" : isG500 ? @"锁车失败" : @"断电失败";
    DuiMaUnSuodingFailText = isMotoBike ? @"开启供电失败" : isG500 ? @"解锁失败" : @"供电失败";
    
    DuiMaSuodingSendingText   = isMotoBike ? @"正在远程断电" : isG500 ? @"正在锁车" : @"正在断电";
    DuiMaUnSuodingSendingText = isMotoBike ? @"正在开启供电" : isG500 ? @"正在解锁" : @"正在供电";
    
    DuiMaSuodingDealText   = isMotoBike ? @"" : isG500 ? @"" : @"";
    DuiMaUnSuodingDealText = isMotoBike ? @"开启供电" : isG500 ? @"远程解锁" : @"恢复供电";
}
- (void)setupView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationBarView setBackgroundColor:[UIColor clearColor]];
    [self.navigationBarView setHidden:YES];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(kNavigationBarHeight - 44);
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(-kBottomHeight);
    }];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"ic_gps_back"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:CreateImageWithColor([UIColor colorWithHexString:@"000000" alpha:0.7f]) forState:UIControlStateNormal];
    
    backBtn.layer.masksToBounds = YES;
    backBtn.layer.cornerRadius = 6.0f;
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.top.equalTo(@28);
        make.size.equalTo(CGSizeMake(40, 48));
    }];
    
    CGPoint point = self.mapView.compassOrigin;
    point.y += 40;
    [self.mapView setCompassOrigin:point];
    
    // 缩放按钮
    self.scaleBg = [[UIImageView alloc]init];
    self.scaleBg.userInteractionEnabled = YES;
    self.scaleBg.image = [UIImage imageNamed:@"ic_location_suofang_bg"];
    [self.contentView addSubview:self.scaleBg];
    
    UIButton * bigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bigBtn setImage:[UIImage imageNamed:@"ic_location_scale_big"] forState:UIControlStateNormal];
    bigBtn.tag = 100;
    [bigBtn addTarget:self action:@selector(scaleMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.scaleBg addSubview:bigBtn];
    
    UIButton * smallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    smallBtn.tag = 101;
    [smallBtn setImage:[UIImage imageNamed:@"ic_location_scale_small"] forState:UIControlStateNormal];
    [smallBtn addTarget:self action:@selector(scaleMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.scaleBg addSubview:smallBtn];
    
    //地图模式切换
    self.mapChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mapChangeBtn setImage:[UIImage imageNamed:@"ic_map_open"] forState:UIControlStateNormal];
    [self.mapChangeBtn setBackgroundImage:CreateImageWithColor([UIColor colorWithHexString:@"000000" alpha:0.7f]) forState:UIControlStateNormal];
    [self.mapChangeBtn addTarget:self action:@selector(mapModeChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.mapChangeBtn.layer.masksToBounds = YES;
    self.mapChangeBtn.layer.cornerRadius = 6.0f;
    [self.mapChangeBtn setExclusiveTouch:YES];
    [self.contentView addSubview:self.mapChangeBtn];
    
    [self.mapChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-20);
        make.centerY.equalTo(backBtn);
        make.size.equalTo(CGSizeMake(40, 48));
    }];
    
    // 定位button
    self.locationUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationUserBtn.tag = 202;
    [self.locationUserBtn setImage:[UIImage imageNamed:@"ic_location_user"] forState:UIControlStateNormal];
    [self.locationUserBtn addTarget:self action:@selector(locationPosition:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationUserBtn setBackgroundColor:[UIColor colorWithHexString:@"000000" alpha:0.7f]];
    [self.locationUserBtn setExclusiveTouch:YES];
    [self.contentView addSubview:self.locationUserBtn];
    
    self.locationUserBtn.layer.masksToBounds = YES;
    self.locationUserBtn.layer.cornerRadius = 6.0f;
    
    [self.scaleBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.width.equalTo(@40);
        make.height.equalTo(@80);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(@-200);
    }];
    
    [bigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.width.and.height.equalTo(@40);
    }];
    
    [smallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.equalTo(@0);
        make.width.and.height.equalTo(@40);
    }];
    
    [self.locationUserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-20);
        make.size.equalTo(CGSizeMake(40, 0));
        make.top.equalTo(self.mapChangeBtn.mas_bottom).with.offset(@20);
    }];
    
    // 标题栏视图
    [self.contentView addSubview:self.dTitleLabelView];
    [self.dTitleLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(backBtn.mas_trailing).with.offset(@20);
        make.height.and.centerY.equalTo(backBtn);
        make.centerX.equalTo(self.view);
    }];
    
    [self.contentView addSubview:self.devSelectedView];
    
    [self.contentView addSubview:self.functionView];
    [self.functionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(Side_Spacing-1);
        make.right.equalTo(-Side_Spacing+1);
        make.bottom.equalTo(@8);
        make.height.equalTo(BTN_HEIGHT+ITEM_HEIGHT);
    }];
}
#pragma mark - 添加引导提示
- (void)addHoledView {
    //添加遮罩指示
    self.holedView = [[G100HoledView alloc] initWithFrame:self.contentView.bounds];
    self.holedView.holeViewDelegate = self;
    [self.contentView addSubview:_holedView];
    
    CGRect buttonFrame = self.mapChangeBtn.frame;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame.origin.x - 2,
                                                        buttonFrame.origin.y - 2,
                                                        buttonFrame.size.width + 4,
                                                        buttonFrame.size.height + 4)
                            withCornerRadius:6.0f];
    
    CGRect buttonFrame1 = self.devSelectedView.frame;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame1.origin.x - 2,
                                                        buttonFrame1.origin.y - 2,
                                                        buttonFrame1.size.width + 4,
                                                        buttonFrame1.size.height + 4)
                            withCornerRadius:10.0f];

    CGRect buttonFrame2 = self.functionView.frame;
    buttonFrame2.origin.y = self.contentView.v_height - 45 - kBottomPadding;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame2.origin.x-5,
                                                        buttonFrame2.origin.y,
                                                        buttonFrame2.size.width+10,
                                                        buttonFrame2.size.height+20)
                            withCornerRadius:10.0f];

    // 图文说明 地图切换
    UIImageView *hintImageView = [[UIImageView alloc] init];
    hintImageView.frame = CGRectMake(WIDTH - 68 - 225, kNavigationBarHeight, 225, 71);
    hintImageView.image = [UIImage imageNamed:@"ic_tips_changeMap"];
    
    [self.holedView addHCustomView:hintImageView onRect:hintImageView.frame];
    
    // 图文说明 已绑定的设备
    UIImageView *hintImageView1 = [[UIImageView alloc] init];
    hintImageView1.frame = CGRectMake(WIDTH  - 164 - 60 - 10, 120 + 40, 164, 90);
    hintImageView1.image = [UIImage imageNamed:@"ic_tips_bindingdev"];
    
    [self.holedView addHCustomView:hintImageView1 onRect:hintImageView1.frame];
    
    // 图文说明 设备功能
    UIImageView *hintImageView3 = [[UIImageView alloc] init];
    hintImageView3.frame = CGRectMake(WIDTH - 20 - 170 - 85, HEIGHT - 50 - 135, 170, 135);
    hintImageView3.image = [UIImage imageNamed:@"ic_tips_devFunction"];
    
    [self.holedView addHCustomView:hintImageView3 onRect:hintImageView3.frame];
    
    UIButton *iKnowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [iKnowBtn setBackgroundImage:[UIImage imageNamed:@"ic_tips_iknow"] forState:UIControlStateNormal];
    [iKnowBtn setTitle:@"我知道了" forState:UIControlStateNormal];
    [iKnowBtn setTitleColor:[UIColor colorWithHexString:@"#00E7E4"] forState:UIControlStateNormal];
    [iKnowBtn addTarget:self action:@selector(iKnowBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    iKnowBtn.frame = CGRectMake((WIDTH - 160) / 2, HEIGHT / 2 + 40, 160, 40);
    [self.holedView addHCustomView:iKnowBtn onRect:iKnowBtn.frame];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - G100HoledViewDelegate
- (void)iKnowBtnClicked{
    [UIView animateWithDuration:0.3f animations:^{
        self.holedView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.holedView removeHoles];
            [self.holedView removeFromSuperview];
        }
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }];
}

- (void)holedView:(G100HoledView *)holedView didSelectHoleAtIndex:(NSUInteger)index {
    
}

#pragma mark - 地图页面数据配置
- (void)configDataWithBikeid:(NSString *)bikeid manually:(BOOL)isManually isFirst:(BOOL)isFirst {
    [self removeAutoLocatedPointAnnotation];
    
    self.dTitleLabelView.mainText = self.bikeDomain.name;
    NSInteger count = 0;
    for (G100DeviceDomain *device in self.bikeDomain.gps_devices) {
        if ([device isNormalDevice]) {
            count++;
        }
    }
    self.dTitleLabelView.viceText = [NSString stringWithFormat:@"本车已绑定%@台设备", @(count)];
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    self.devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    
    BOOL hasDeviceLocation = NO;
    for (G100BikeRuntimeDomain * bikeDomain in self.bikesRuntimeDomain.runtime) {
        if ([bikeid integerValue] == bikeDomain.bike_id) {
            self.functionView.accState = bikeDomain.acc;
            self.functionView.battery = bikeDomain.batt_soc;
            self.functionView.distance = bikeDomain.expected_distance;
            [self.functionView configDataWithBikeDomain:self.bikeDomain devDomain:self.devDomain bikesRuntimeDomain:self.bikesRuntimeDomain];
            
            // 判断是否有通信故障
            if (![bikeDomain.fault_code hasContainString:@"193"]) {
                _hasTongxinFault = NO;
            }else {
                _hasTongxinFault = YES;
            }
            
            if (self.oldDeviceCount != bikeDomain.device_runtimes.count) {
                [self.mapView removeAnnotations:[self.mapView annotations]];
                [self.deviceAnnotationsArray removeAllObjects];
            }
            
            NSInteger index = 0;
            self.oldDeviceCount = bikeDomain.device_runtimes.count;
            
            for (NSDictionary * dict in bikeDomain.device_runtimes) {
                hasDeviceLocation = YES;
                
                G100DeviceRuntimeDomain * deviceRuntimeDomain = [[G100DeviceRuntimeDomain alloc] initWithDictionary:dict];
                PositionDomain * positionDomain = [[PositionDomain alloc]init];
                G100DeviceDomain *device = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:[NSString stringWithFormat:@"%@", @(deviceRuntimeDomain.device_id)]];
                
                // 如果不是GPS 设备 则不添加标注
                if (![device isGPSDevice]) {
                    continue;
                }
                
                if (bikeDomain.device_runtimes.count > 1) {
                    positionDomain.name = [NSString stringWithFormat:@"%@ %@", @(index+1), device.name];
                }else {
                    positionDomain.name = device.name;
                }
                positionDomain.gpssvs = deviceRuntimeDomain.gps_level;
                positionDomain.bssignal = deviceRuntimeDomain.bs_level;
                positionDomain.devid =[NSString stringWithFormat:@"%ld", deviceRuntimeDomain.device_id];
                positionDomain.index = index;
                positionDomain.longi = [NSString stringWithFormat:@"%@", @(deviceRuntimeDomain.longi)];
                positionDomain.lati = [NSString stringWithFormat:@"%@", @(deviceRuntimeDomain.lati)];
                positionDomain.isMainDevice = device.isMainDevice;
                
                if (deviceRuntimeDomain.lati == 0 && deviceRuntimeDomain.longi == 0) {
                    NSString * time = [self locationTimeParase:deviceRuntimeDomain.bs_loc_time];
                    positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", time];
                    positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntimeDomain.bs_loc_desc];
                    positionDomain.desc = deviceRuntimeDomain.bs_loc_desc;
                    positionDomain.time = time;
                }else
                {
                    NSString * time = [self locationTimeParase:deviceRuntimeDomain.loc_time];
                    positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", time];
                    positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntimeDomain.loc_desc];
                    positionDomain.desc = deviceRuntimeDomain.loc_desc;
                    positionDomain.time = time;
                }
                if (![self.deviceAnnotationsArray safe_objectAtIndex:index]) {
                    CustomMAPointAnnotation *anno = [[CustomMAPointAnnotation alloc] init];
                    anno.type = 3;
                    anno.positionDomain = positionDomain;
                    anno.index = index;
                    
                    MAAnnotationView *view = [self.mapView viewForAnnotation:anno];
                    if ([view isKindOfClass:[CustomMAAnnotationView class]]) {
                        CustomMAAnnotationView *cusView = (CustomMAAnnotationView *)view;
                        cusView.positionDomain = positionDomain;
                    }
                    
                    CLLocationCoordinate2D coordinate;
                    if (deviceRuntimeDomain.lati == 0 && deviceRuntimeDomain.longi == 0) {
                        coordinate = CLLocationCoordinate2DMake(deviceRuntimeDomain.bs_lati, deviceRuntimeDomain.bs_longi);
                    }else {
                        coordinate = CLLocationCoordinate2DMake(deviceRuntimeDomain.lati, deviceRuntimeDomain.longi);
                        coordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
                    }
                    
                    anno.coordinate = coordinate;
                    positionDomain.coordinate = coordinate;
                    [self configEleFenceWithLocation:coordinate];
                    [self.deviceAnnotationsArray addObject:anno];
                }else {
                    CustomMAPointAnnotation *anno = [self.deviceAnnotationsArray safe_objectAtIndex:index];
                    anno.type = 3;
                    anno.positionDomain = positionDomain;
                    
                    MAAnnotationView *view = [self.mapView viewForAnnotation:anno];
                    if ([view isKindOfClass:[CustomMAAnnotationView class]]) {
                        CustomMAAnnotationView *cusView = (CustomMAAnnotationView *)view;
                        cusView.positionDomain = positionDomain;
                    }
                    
                    CLLocationCoordinate2D coordinate;
                    if (deviceRuntimeDomain.lati == 0 && deviceRuntimeDomain.longi == 0) {
                        coordinate = CLLocationCoordinate2DMake(deviceRuntimeDomain.bs_lati, deviceRuntimeDomain.bs_longi);
                    }else {
                        coordinate = CLLocationCoordinate2DMake(deviceRuntimeDomain.lati, deviceRuntimeDomain.longi);
                        coordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
                    }
                    
                    anno.coordinate = coordinate;
                    positionDomain.coordinate = coordinate;
                }
                
                if (positionDomain.coordinate.latitude == 0 &&
                    positionDomain.coordinate.longitude == 0 &&
                    deviceRuntimeDomain.device_id == [self.selectedDevid integerValue]) {
                    if (isManually) {
                        [self showHint:@"没有找到设备"];
                    }
                }else {
                    [self refreshMapViewAnnotationState];
                    
                    if (isManually) {
                        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
                            if ([anno.positionDomain.devid isEqualToString:self.selectedDevid]) {
                                [self showAnnotationDetailWithAnnotation:anno isCenter:YES isSelected:YES];
                                break;
                            }
                        }
                    } else {
                        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
                            if (anno.selected) {
                                [self showAnnotationDetailWithAnnotation:anno isCenter:NO isSelected:YES];
                            }
                        }
                    }
                }
                
                // 首次进入 实时追踪页面进入时默认显示主设备的详细地址信息栏，并居中显示
                /*
                if (isFirst) {
                    if (index == 0) {
                        CustomMAPointAnnotation *anno = [self.deviceAnnotationsArray safe_objectAtIndex:0];
                        if (anno) {
                            [self showAnnotationDetailWithAnnotation:anno isCenter:YES isSelected:YES];
                        }
                    }
                }
                 */
                
                if ([device isGPSDevice]) {
                    index++;
                }
                
            }
            break;
        }
    }
    
    if (isFirst) {
        if (self.userLocation && self.mapView.annotations.count <= 0) {
            // 显示默认当前位置区域
            [self.mapView setCenterCoordinate:self.userLocation.coordinate animated:YES];
        } else {
            [self showAllAnnotationsWithEdgeInset:kMapShowEdgeInset animated:YES];
        }
    }
    if (!hasDeviceLocation) {
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self.deviceAnnotationsArray removeAllObjects];
    }
    
    self.devSelectedView.dataArray = self.bikeDomain.gps_devices;
}

#pragma mark - 地图模式切换
- (void)mapModeChangeAction:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.mapChangeView show];
    }else{
        [self.mapChangeView hide];
    }
}

#pragma mark - 定位点击事件
- (void)locationPosition:(UIButton *)button {
    [self showHint:@"正在定位"];
    
    _locationUserBtn.selected = YES;
    if (self.userAnnotation && self.userAnnotation.coordinate.latitude != 0 && self.userAnnotation.coordinate.longitude != 0) {
        [self showAnnotationDetailWithAnnotation:self.userAnnotation isCenter:YES isSelected:YES];
    }
    
    // 开始定位
    [self startLocationService];
    
    double delayInSeconds = 6.0f;
    __weak typeof(self) wself = self;;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [wself hideHud];
    });
}

#pragma mark - 地图缩放
- (void)scaleMap:(UIButton *)button {
    if (button.tag == 100) {
        [self zoomIn];
    }else if (button.tag == 101) {
        [self zoomOut];
    }
}

#pragma mark - 退出页面
- (void)backBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 监听通知的操作
- (void)infoDomainDidChange:(NSNotification *)noti {
    if ([noti.userInfo[@"user_id"] integerValue] != [self.userid integerValue]) {
        return;
    }
    
    if ([noti.name isEqualToString:CDDDataHelperBikeInfoDidChangeNotification]) {
        self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    }else if ([noti.name isEqualToString:CDDDataHelperDeviceInfoDidChangeNotification]) {
        self.devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    }
    
    [self.functionView configDataWithBikeDomain:self.bikeDomain devDomain:self.devDomain bikesRuntimeDomain:self.bikesRuntimeDomain];
}
    
#pragma mark - 监测网络变化
- (void)insepectNet {
    if ([_netview superview]) {
        [_netview removeFromSuperview];
    }
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        self.netview = [[G100NetworkHintView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 20)
                                                            title:@"网络无法链接请检查您的网络。"
                                                            color:[UIColor redColor]];
        if ([_hintView superview]) {
            [self.view insertSubview:self.netview aboveSubview:_hintView];
        }else{
            [self.contentView addSubview:self.netview];
        }
        
        [self.netview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.top.equalTo(@20);
            make.height.equalTo(@20);
        }];
    }
}

#pragma mark - MAMapViewDelegate 
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (!_userLocation) {
        _userLocation = [[MAUserLocation alloc] init];
        [self locationInCoordinate:userLocation.coordinate];
    }
    
    _userLocation = userLocation;
    _userLocaitonCoordinate = userLocation.location.coordinate;
    self.userAnnotation.coordinate = userLocation.location.coordinate;
    
    if (![self.mapView.annotations containsObject:self.userAnnotation]) {
        //[self.mapView addAnnotation:self.userAnnotation];
    }
    
    [self removeAutoLocatedPointAnnotation];
    
    if (!_hasLoacated) {
        _hasLoacated = YES;
        
        if (self.userLocation && self.mapView.annotations.count <= 0) {
            // 显示默认当前位置区域
            [self.mapView setCenterCoordinate:self.userLocation.coordinate animated:YES];
        } else {
            [self showAllAnnotationsWithEdgeInset:kMapShowEdgeInset animated:YES];
        }
    }
    
    if (updatingLocation) {
        // 查询当前位置信息
        [self onClickReverseAMMapGeocode:_userLocation.location.coordinate];
    }
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"%@",error); // kCLErrorDomain error 0.
    if (kCLErrorDenied == error.code) { //未打开定位功能
        [self stopLocationService];
        
        if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kLocationServiceOff"]) {
            //添加 开启定位弹框提示
            if (ISIOS8ADD) {
                [MyAlertView MyAlertWithTitle:@"打开定位开关"
                                      message:@"定位服务未开启，请进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许骑卫士使用定位服务"
                                     delegate:self
                             withMyAlertBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                } cancelButtonTitle:@"取消" otherButtonTitles:@"立即开启"];
            }else{
                [MyAlertView MyAlertWithTitle:@"打开定位开关"
                                      message:@"定位服务未开启，请进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许骑卫士使用定位服务"
                                     delegate:self
                             withMyAlertBlock:nil
                            cancelButtonTitle:nil
                            otherButtonTitles:@"我知道了"];
            }
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"kLocationServiceOff" leftTimes:0];
            
        }
    }else if (kCLErrorLocationUnknown == error.code) {//信号差
        if (!self.hasLoadLocationServiceUnknownNotice) {
            [MyAlertView MyAlertWithTitle:@"GPS信号弱或无GPS信号"
                                  message:@"请移步空旷的地方重新尝试"
                                 delegate:self
                         withMyAlertBlock:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:@"我知道了"];
            self.hasLoadLocationServiceUnknownNotice = YES;
        }
    }
}
- (MAAnnotationView*)getRouteAnnotationView:(MAMapView *)mapview viewForAnnotation:(CustomMAPointAnnotation *)routeAnnotation {
    CustomMAAnnotationView * view = nil;
    
    switch (routeAnnotation.type) {
        case 0:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageNamed:@"icon_nav_start.png"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = FALSE;
                view.userInteractionEnabled = NO;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageNamed:@"icon_nav_end.png"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
                view.userInteractionEnabled = NO;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"location_user_pin"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"location_user_pin"];
                view.image = [UIImage imageNamed:@"ic_map_loc_mine"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
            }
            view.backgroundColor = [UIColor clearColor];
            view.annotation = routeAnnotation;
            view.positionDomain = routeAnnotation.positionDomain;
            
            if (routeAnnotation.selected == YES) {
                [view setSelected:YES animated:YES];
            }
        }
            break;
        case 3:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"location_dev_pin"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"location_dev_pin"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
                view.userInteractionEnabled = YES;
            }
            view.backgroundColor = [UIColor clearColor];
            view.annotation = routeAnnotation;
            view.positionDomain = routeAnnotation.positionDomain;
            
            if (self.bikeDomain.gps_devices.count > 1) {
                if (routeAnnotation.positionDomain.index == 0) {
                    view.image = [UIImage imageNamed:@"ic_map_dev_only"];
                }else{
                   view.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_map_dev_%@", @(routeAnnotation.positionDomain.index+1)]];
                }
                
            }else {
                if (self.bikeDomain.battery_devices.count >0) {
                    view.image = [UIImage imageNamed:@"ic_batt_smart_Dev"];
                }else{
                    view.image = [UIImage imageNamed:@"ic_map_dev_only"];
                }
            }
            view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
            
            if (routeAnnotation.selected == YES) {
                [view setSelected:YES animated:YES];
            }
        }
            break;
        case 4:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageNamed:@"icon_direction.png"];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        case 5:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"location_dev_lost_pin"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"location_dev_lost_pin"];
                view.image = [UIImage imageNamed:@"ic_findcar_lost_pin"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
            }
            view.backgroundColor = [UIColor clearColor];
            view.annotation = routeAnnotation;
            view.positionDomain = routeAnnotation.positionDomain;
            
            if (routeAnnotation.selected == YES) {
                [view setSelected:YES animated:YES];
            }
        }
            break;
        case 6:
        {
            view = (CustomMAAnnotationView *)[mapview dequeueReusableAnnotationViewWithIdentifier:@"location_dev_find_pin"];
            if (view == nil) {
                view = [[CustomMAAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"ic_location_dev_pin"];
                view.image = [UIImage imageNamed:@"ic_location_dev_pin"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
            }
            view.backgroundColor = [UIColor clearColor];
            view.annotation = routeAnnotation;
            view.positionDomain = routeAnnotation.positionDomain;
            
            if (routeAnnotation.selected == YES) {
                [view setSelected:YES animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[CustomMAPointAnnotation class]]) {
        return [self getRouteAnnotationView:mapView viewForAnnotation:(CustomMAPointAnnotation*)annotation];
    }else if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        // 自定义定位样式的图片
        annotationView.image = [[UIImage alloc] init];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        [self.functionView hideFunctionView];
    }
}

- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        [self.functionView hideFunctionView];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer * polylineView = [[MAPolylineRenderer alloc] initWithPolyline:(MAPolyline *)overlay];
        polylineView.lineDashType = kMALineDashTypeNone;
        polylineView.lineWidth = 4.f;
        polylineView.strokeColor = [UIColor colorWithHexString:@"33CC00"];
        polylineView.lineJoinType = kMALineJoinRound;//连接类型
        polylineView.lineCapType = kMALineCapRound;//端点类型
        return polylineView;
    }else if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *circleRender = [[MAGroundOverlayRenderer alloc] initWithGroundOverlay:(MAGroundOverlay *)overlay];
        return circleRender;
    }else if ([overlay isKindOfClass:[MACircle class]] ){
        if (self.mapView.userLocationAccuracyCircle == overlay) {
            return nil;
        }
    }
    return nil;
}
#pragma mark - 高德逆地址编码
-(void)onClickReverseAMMapGeocode:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc]init];
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    request.requireExtension = YES;
    
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc]init];
    }
    
    self.search.delegate = self;
    [self.search AMapReGoecodeSearch:request];
}
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    if ((float)request.location.latitude != (float)self.userLocaitonCoordinate.latitude ||
        (float)request.location.longitude != (float)self.userLocaitonCoordinate.longitude) {
        return;
    }
    
    if (response) {
        
        MAGeoCodeResult *geo = [MAGeoCodeResult instance];
        
        NSString *adcode = response.regeocode.addressComponent.adcode;
        self.adcode = adcode;
        
        if (![EBOfflineMapTool sharedManager].hasShowedNotice) {
            if ([[EBOfflineMapTool sharedManager] needRemainderUserWithAdcode:adcode]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"地图下载"
                                                                    message:@"检测到当前所在城市地图未下载，是否需要前往下载？"
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"取消", @"立即下载", @"连接WiFi时自动下载", nil];
                alertView.tag = 2001;
                [alertView show];
                NSUserDefaults *p = [NSUserDefaults standardUserDefaults];
                [p setBool:YES forKey:EBOfflineMapToolHasShowNoticeKey];
                [p synchronize];
            }
        }else{
            if ([[EBOfflineMapTool sharedManager] needRemainderUserWithAdcode:adcode]) {
                [self updateTopHintUI];
            }else{
                [self removeHintViewUI];
            }
        }
        
        geo.result = response;
        CLLocationAccuracy horizontalAccuracy = _userLocation.location.horizontalAccuracy;
        
        PositionDomain * positionDomain = [[PositionDomain alloc] init];
        positionDomain.topTitle = [NSString stringWithFormat:@"位置：%@", response.regeocode.formattedAddress];
        positionDomain.bottomContent = [NSString stringWithFormat:@"精度：约%.lf米", horizontalAccuracy];
        
        _userAnnotation.positionDomain = positionDomain;
        _userAnnotation.title = [NSString stringWithFormat:@"位置：%@", response.regeocode.formattedAddress];
        _userAnnotation.subtitle = [NSString stringWithFormat:@"精度：约%.lf米", horizontalAccuracy];
        
        self.userAnnotation.positionDomain = positionDomain;
        
        UIView *view = [self.mapView viewForAnnotation:self.userAnnotation];
        if ([view isKindOfClass:[CustomMAAnnotationView class]]) {
            CustomMAAnnotationView *cusView = (CustomMAAnnotationView *)view;
            cusView.positionDomain = positionDomain;
        }
        
        if (self.userAnnotation.selected) {
            [self showAnnotationDetailWithAnnotation:self.userAnnotation isCenter:NO isSelected:NO];
        }
    }
}

- (void)updateTopHintUI{
    if (![self.hintView superview]) {
        [self.contentView addSubview:self.hintView];
        CGFloat topViewHeight = [self.hintView getHeightOfTopHintView];
        [self.hintView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(@0);
            make.trailing.equalTo(0);
            make.height.equalTo(topViewHeight);
        }];
    }
}

- (void)removeHintViewUI{
    if ([self.hintView superview]) {
        [self.hintView removeFromSuperview];
        self.hintView = nil;
    }
}

#pragma mark - UIAlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2001) {
        if (buttonIndex == 1) {
            [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:self.adcode downloadType:EBOfflineItemDownloadTypeWWAN];
        } else if (buttonIndex == 2){
            [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:self.adcode downloadType:EBOfflineItemDownloadTypeWIFI];
        } else {
            [self updateTopHintUI];
        }
    }
}

#pragma mark - EBOfflineMapServiceDelegate
- (void)mapTool:(EBOfflineMapTool *)tool didFinishedItem:(MAOfflineItem *)downloadItem {
    [self.mapView reloadMap];
    [self removeHintViewUI];
}

#pragma mark - 移除定位自动添加的标注
- (void)removeAutoLocatedPointAnnotation {
    MAUserLocation *ua = nil;
    
    for (MAPointAnnotation *anno in self.mapView.annotations) {
        if ([anno isKindOfClass:[MAUserLocation class]]) {
            ua = (MAUserLocation *)anno;
        }
    }
    
    [self.mapView removeAnnotation:ua];
}

#pragma mark - 选中某一个标注
/**
 选中一个标注

 @param annotation 标注
 @param isCenter   是否居中
 @param isSelected 是否选中
 */
- (void)showAnnotationDetailWithAnnotation:(CustomMAPointAnnotation *)annotation isCenter:(BOOL)isCenter isSelected:(BOOL)isSelected {
    if (isCenter) {
        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
            anno.isCenter = NO;
        }
        
        self.userAnnotation.isCenter = NO;
        [self locationInCoordinate:annotation.coordinate];
    }
    
    if (isSelected) {
        for (CustomMAPointAnnotation *anno in [self.mapView annotations]) {
            if (anno == annotation) {
                CustomMAAnnotationView *anview = (CustomMAAnnotationView *)[self.mapView viewForAnnotation:anno];
                if (anview.selected) {
                    continue;
                }
                
                [self.mapView deselectAnnotation:anno animated:NO];
                [self.mapView selectAnnotation:anno animated:YES];
            }else {
                [self.mapView deselectAnnotation:anno animated:NO];
            }
        }
        
        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
            anno.selected = NO;
        }
        
        self.userAnnotation.selected = NO;
    }
    
    if (annotation.type == 2) {
        
    }else if (annotation.type == 3) {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }else {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }
    
    annotation.isCenter = isCenter;
    annotation.selected = isSelected;
}

#pragma mark - 选中标注时弹出气泡
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    CustomMAPointAnnotation * annotation = (CustomMAPointAnnotation *)[view annotation];
    // 如果在中央，则显示在中央
    if (annotation.isCenter) {
        [self locationInCoordinate:annotation.coordinate];
    }
    
    self.selectedDevAnnotation = annotation;
    self.selectedDevCoordinate = annotation.coordinate;
    
    CustomMAAnnotationView *cusView = (CustomMAAnnotationView *)view;
    
    if (annotation.type == 3 && [view isKindOfClass:[CustomMAAnnotationView class]]) {
        __weak typeof(self) wself = self;
        cusView.calloutView.navigationButtonBlock = ^(){
            __strong typeof(wself) strongSelf = wself;
            [strongSelf callThirdMapForNavigationWithStartCoor:strongSelf.userLocaitonCoordinate
                                                  endCoor:strongSelf.selectedDevCoordinate
                                                startName:strongSelf.userAnnotation.positionDomain.desc
                                                  endName:strongSelf.selectedDevAnnotation.positionDomain.desc];
        };
    }
    
    if (annotation.type == 2) {
        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
            anno.selected = NO;
        }
        annotation.selected = YES;
    }else if (annotation.type == 3) {
        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
            anno.selected = NO;
        }
        annotation.selected = YES;
        self.userAnnotation.selected = NO;
        
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }else {
        for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
            anno.selected = NO;
        }
        annotation.selected = YES;
        self.userAnnotation.selected = NO;
        
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }
    
    [self.devSelectedView selectedDeviceAtIndex:annotation.index];
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    self.userAnnotation.selected = NO;
    [self.devSelectedView invertSelection];
}

// 单击取消标注的选择
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    for (MAPointAnnotation *anno in [self.mapView annotations]) {
        [self.mapView deselectAnnotation:anno animated:NO];
    }
    
    for (CustomMAPointAnnotation *anno in self.deviceAnnotationsArray) {
        anno.selected = NO;
    }
    
    self.userAnnotation.selected = NO;
    [self.devSelectedView invertSelection];
}

-(void)locationInCoordinate:(CLLocationCoordinate2D)coordinate {
    if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        
    }else {
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    }
}

#pragma mark - 获取设备位置信息
- (void)loadDevicePositionWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback showHUD:(BOOL)showHUD {
    
}

#pragma mark - G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.errCode == 0 && response.data) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
        [self configDataWithBikeid:bikeid manually:NO isFirst:NO];
    }
}

#pragma mark - 添加电子围栏
- (void)configEleFenceWithLocation:(CLLocationCoordinate2D)location{
    //TODO: 电子围栏功能 待添加
    /** 隐藏电子围栏功能
    [self.mapView removeOverlays:self.mapView.overlays];
    //2.计算距离
    MACoordinateRegion region =  MACoordinateRegionMakeWithDistance(location, 50, 50);
    self.eleCircle = [MAGroundOverlay groundOverlayWithBounds:MACoordinateBoundsMake(CLLocationCoordinate2DMake(location.latitude + region.span.latitudeDelta, location.longitude + region.span.longitudeDelta), CLLocationCoordinate2DMake(location.latitude - region.span.latitudeDelta, location.longitude - region.span.longitudeDelta)) icon:[UIImage imageNamed:@"icon_electronic_fence"]];
    [self.mapView addOverlay:self.eleCircle];
     */
}

#pragma mark - G100TrackingFunctionViewDelegate
- (void)trackingFunctionView:(G100TrackingFunctionView *)functionView didSelected:(G100RTCommandModel *)model {
    switch (model.rt_command) {
        case 1:
        {
            NSLog(@"安防设置");
            // 安防设置
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSecuritySetting:self.userid
                                                                                                                     bikeid:self.bikeid
                                                                                                                      devid:self.devid];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 2:
        {
            NSLog(@"用车报告");
            // 用车报告
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeReport:self.userid
                                                                                                                bikeid:self.bikeid
                                                                                                                 devid:self.devid];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 3:
        {
            NSLog(@"远程遥控");
            G100DeviceDomain *deviceDomain = [self.bikeDomain ableRemote_ctrlDevice];
            NSString *deviceid = [NSString stringWithFormat:@"%@", @(deviceDomain.device_id)];
            G100GPSRemoteCtrlView *view = [[G100GPSRemoteCtrlView alloc] init];
            view.userid = self.userid;
            view.bikeid = self.bikeid;
            view.devid = deviceid;
            
            G100CardModel *cardModel = [[G100CardModel alloc] init];
            cardModel.devid = deviceid;
            cardModel.bike = self.bikeDomain;
            cardModel.device = deviceDomain;
            
            view.cardModel = cardModel;
            
            [view showInVc:self view:self.view animation:YES];
        }
            break;
        case 4:
        {
            NSLog(@"帮我找车");
            
            // 寻车记录 仅针对主用户有效
            if (!self.bikeDomain.isMaster) {
                [self.parentViewController showHint:@"副用户不提供此功能"];
                return;
            }
            
            if ([self.bikeDomain isLostBike]) {
                UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeFinding:self.userid
                                                                                                                     bikeid:self.bikeid
                                                                                                                     lostid:self.bikeDomain.lost_id];
                [self.navigationController pushViewController:viewController animated:YES];
            }else {
                // 帮我找车
                UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForHelpFindBike:self.userid
                                                                                                                      bikeid:self.bikeid
                                                                                                                       devid:self.devid];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
            break;
        case 5:
        {
            NSLog(@"远程断电");
            // 先判断是否存在通信故障 若果存在故障 弹框提醒 直接return
            if (_hasTongxinFault) {
                G100MAlertIKnow(@"提示", TFDuiMaTongxinFaultToast, YES, nil);
                return;
            }
            
            BOOL isMotoBike = self.bikeDomain.isMOTOBike;
            
            if (isMotoBike) {
                // 摩托车远程断电和开启供电操作
                if (self.functionView.suoDingStyle == DuiMaUnSuoDingMyCarStyle) {
                    // 要远程断电
                    [[G100InfoHelper shareInstance] setLeftRemainderTimesWithKey:@"kG800RelayRemainder" times:1 userid:self.userid devid:self.bikeid dependOnVersion:NO];
                    if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kG800RelayRemainder" userid:self.userid devid:self.bikeid] > 0){
                        __weak typeof(self) wself = self;
                        G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
                        [pop showPopingViewWithTitle:@"提醒" content:@"使用“远程断电”需要安装继电器，是否已安装？" noticeType:ClickEventBlockCancel otherTitle:@"未安装" confirmTitle:@"已安装" clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                NSInteger num = [[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kG800RelayRemainder" userid:wself.userid devid:wself.bikeid];
                                if (num > 0) {
                                    num--;
                                    [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"kG800RelayRemainder"
                                                                                      leftTimes:num
                                                                                         userid:wself.userid
                                                                                          devid:wself.bikeid];
                                }
                            }
                            [pop dismissWithVc:wself animation:YES];
                        } onViewController:self onBaseView:self.view];
                    } else {
                        __weak typeof(self) wself = self;
                        G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithHintReactiveView];
                        [pop showPopingViewWithTitle:DuiMaSuodingText content:DuiMaSuodingHint noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                [wself lockOrUnLockDev:wself.devid lock:1 showHUD:YES callback:^(BOOL isOk){
                                    
                                }];
                            }
                            [pop dismissWithVc:wself animation:YES];
                        } onViewController:self onBaseView:self.view];
                        
                        pop.hintLabel.text = @"*使用此功能，请保持车辆处于网络畅通处，否则无法远程断电。";
                        [pop configConfirmViewTitleColorWithConfirmColor:@"000000" otherColor:@"02bb00"];
                    }
                    
                }else if (self.functionView.suoDingStyle == DuiMaSuoDingMyCarStyle) {
                    // 要开启供电
                    [[G100InfoHelper shareInstance] setLeftRemainderTimesWithKey:@"kG800RelayRemainder" times:1 userid:self.userid devid:self.bikeid dependOnVersion:NO];
                    if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kG800RelayRemainder" userid:self.userid devid:self.bikeid] > 0){
                        __weak typeof(self) wself = self;
                        G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
                        [pop showPopingViewWithTitle:@"提醒" content:@"使用“开启供电”需要安装继电器，是否已安装？" noticeType:ClickEventBlockCancel otherTitle:@"未安装" confirmTitle:@"已安装" clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                NSInteger num = [[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kG800RelayRemainder" userid:wself.userid devid:wself.bikeid];
                                if (num > 0) {
                                    num--;
                                    [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"kG800RelayRemainder"
                                                                                      leftTimes:num
                                                                                         userid:wself.userid
                                                                                          devid:wself.bikeid];
                                }
                            }
                            [pop dismissWithVc:wself animation:YES];
                        } onViewController:self onBaseView:self.view];
                    } else {
                        __weak typeof(self) wself = self;
                        G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithHintReactiveView];
                        [pop showPopingViewWithTitle:DuiMaUnSuodingText content:DuiMaUnSuodingHint noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                            __strong typeof(wself) strongSelf = wself;
                            if (index == 2) {
                                [strongSelf lockOrUnLockDev:strongSelf.devid lock:2 showHUD:YES callback:^(BOOL isOk){
                                    
                                }];
                            }
                            [pop dismissWithVc:strongSelf animation:YES];
                        } onViewController:self onBaseView:self.view];
                        
                        pop.hintLabel.text = @"*使用此功能，请保持车辆处于网络畅通处，否则无法开启供电。";
                        [pop configConfirmViewTitleColorWithConfirmColor:@"02bb00" otherColor:@"000000"];
                    }
                }else if (self.functionView.suoDingStyle == DuiMaSuoDingMyCaringStyle) {
                    [self showWarningHint:DuiMaSuodingSendingText];
                }else if (self.functionView.suoDingStyle == DuiMaUnSuoDingMyCaringStyle) {
                    [self showWarningHint:DuiMaUnSuodingSendingText];
                }
                
                return;
            }
            
            // 电动车供断电操作
            G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithHintReactiveView];
            if (self.functionView.suoDingStyle == DuiMaUnSuoDingMyCarStyle) {
                if (self.devDomain.isG500Device) {
                    __weak typeof(self) wself = self;
                    NSString * content = @"远程锁车后，车辆将进入设防状态，直至远程解锁后恢复正常。了解更多详情，点击查看远程锁车功能说明";
                    [pop showRichTextPopingViewWithTitle:@"是否远程锁车" content:content richText:@"远程锁车功能说明" noticeType:ClickEventBlockDefine otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself lockOrUnLockDev:wself.devid lock:1 showHUD:YES callback:^(BOOL isOk){
                                
                            }];
                        }
                        [pop dismissWithVc:wself animation:YES];
                    } ClickRichTextlBlock:^(NSInteger index){
                        G100WebViewController *webVc = [[G100WebViewController alloc]init];
                        webVc.httpUrl = [[G100UrlManager sharedInstance] getRemoteLockCarUrlWithUserid:wself.userid bikeid:wself.bikeid devid:wself.devid];
                        [wself.navigationController pushViewController:webVc animated:YES];
                    } onViewController:self onBaseView:self.view];
                    
                    pop.hintLabel.text = @"*远程锁车后，车辆遥控器无法解锁，请谨慎使用。\n*使用此功能，请保持车辆处于网络畅通处，否则无法远程锁车。";
                    [pop configConfirmViewTitleColorWithConfirmColor:@"000000" otherColor:@"02bb00"];
                }
                else
                {
                    __weak typeof(self) wself = self;
                    [pop showPopingViewWithTitle:DuiMaSuodingText content:DuiMaSuodingHint noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself lockOrUnLockDev:wself.devid lock:1 showHUD:YES callback:^(BOOL isOk){
                                
                            }];
                        }
                        [pop dismissWithVc:wself animation:YES];
                    } onViewController:self onBaseView:self.view];
                    
                    pop.hintLabel.text = @"*远程断电后，车辆遥控器无法开启供电，请谨慎使用。\n*使用此功能，请保持车辆处于网络畅通处，否则无法远程断电。";
                    [pop configConfirmViewTitleColorWithConfirmColor:@"000000" otherColor:@"02bb00"];
                }
            }else if (self.functionView.suoDingStyle == DuiMaSuoDingMyCarStyle) {
                
                for (G100BikeRuntimeDomain * bikeRuntimeDomain in self.bikesRuntimeDomain.runtime) {
                    if (self.bikeid.integerValue == bikeRuntimeDomain.bike_id) {
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * deginDate = [dateFormatter dateFromString:bikeRuntimeDomain.detection_begin_data];
                        if ([bikeRuntimeDomain.theft_insurance integerValue] == 3 && [[NSDate date] isLaterThanDate:deginDate]) {
                            __weak typeof(self) wself = self;
                            G100ReactivePopingView * insurancePop = [G100ReactivePopingView popingViewWithHintReactiveView];
                            [insurancePop showPopingViewWithTitle:DuiMaUnSuodingText content:InsuranceWarningHint noticeType:ClickEventBlockCancel otherTitle:@"暂不处理" confirmTitle:DuiMaUnSuodingDealText clickEvent:^(NSInteger index) {
                                __strong typeof(wself) strongSelf = wself;
                                if (index == 2) {
                                    [pop showPopingViewWithTitle:DuiMaUnSuodingText content:DuiMaUnSuodingHint noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                                        if (index == 2) {
                                            [strongSelf lockOrUnLockDev:strongSelf.devid lock:2 showHUD:YES callback:^(BOOL isOk){
                                                
                                            }];
                                        }
                                        [pop dismissWithVc:strongSelf animation:YES];
                                    } onViewController:strongSelf onBaseView:strongSelf.view];
                                    
                                    if (wself.devDomain.isG500Device) {
                                        pop.hintLabel.text = @"*爱车远程锁车状态下，车辆遥控器无法解锁。\n*使用此功能，请保持车辆处于网络畅通处，否则无法远程解锁。";
                                    } else {
                                        pop.hintLabel.text = @"*爱车远程断电状态下，车辆遥控器无法开启供电。\n*使用此功能，请保持车辆处于网络畅通处，否则无法开启供电。";
                                    }

                                    
                                    [pop configConfirmViewTitleColorWithConfirmColor:@"02bb00" otherColor:@"000000"];
                                }
                                [insurancePop dismissWithVc:strongSelf animation:YES];
                            } onViewController:self onBaseView:self.view];
                        }else{
                            __weak typeof(self) wself = self;
                            [pop showPopingViewWithTitle:DuiMaUnSuodingText content:DuiMaUnSuodingHint noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                                __strong typeof(wself) strongSelf = wself;
                                if (index == 2) {
                                    [strongSelf lockOrUnLockDev:strongSelf.devid lock:2 showHUD:YES callback:^(BOOL isOk){
                                        
                                    }];
                                }
                                [pop dismissWithVc:strongSelf animation:YES];
                            } onViewController:self onBaseView:self.view];
                            
                            if (wself.devDomain.isG500Device) {
                                pop.hintLabel.text = @"*爱车远程锁车状态下，车辆遥控器无法解锁。\n*使用此功能，请保持车辆处于网络畅通处，否则无法远程解锁。";
                            } else {
                                pop.hintLabel.text = @"*爱车远程断电状态下，车辆遥控器无法开启供电。\n*使用此功能，请保持车辆处于网络畅通处，否则无法开启供电。";
                            }
                            
                            [pop configConfirmViewTitleColorWithConfirmColor:@"02bb00" otherColor:@"000000"];
                        }
                    }
                }
                
            }else if (self.functionView.suoDingStyle == DuiMaSuoDingMyCaringStyle) {
                [self showWarningHint:DuiMaSuodingSendingText];
            }else if (self.functionView.suoDingStyle == DuiMaUnSuoDingMyCaringStyle) {
                [self showWarningHint:DuiMaUnSuodingSendingText];
            }
            
        }
            break;
        case 6:
        {
            if (![UserAccount sharedInfo].appfunction.servicestatus_buy.enable && IsLogin()) {
                return;
            };
            NSLog(@"流量服务");
            // 购买服务
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBuyService:self.userid
                                                                                                                bikeid:self.bikeid
                                                                                                                 devid:nil];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 7:
        {
            NSLog(@"GPS设置");
            // 设备管理
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForManagement:self.userid
                                                                                                                bikeid:self.bikeid];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        default:
        {
            NSLog(@"安防设置");
        }
            break;
    }
}

#pragma mark - 电动车加解锁   1   加锁  2   解锁
-(void)lockOrUnLockDev:(NSString *)devid lock:(NSInteger)lock showHUD:(BOOL)showHUD callback:(void (^)(BOOL isSuccess))scallback {
    __weak typeof(self) wself = self;;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (showHUD) {
            [wself hideHud];
        }
        
        if (requestSucces) {
            NSInteger status = [[response.data objectForKey:@"controller_status"] integerValue];
            
            if (self.functionView.suoDingStyle != status) {
                self.functionView.suoDingStyle = status;
            }
            
        }else {
            if (lock == 1) {
                [wself showWarningHint:DuiMaSuodingFailText];
            }else {
                [wself showWarningHint:DuiMaUnSuodingFailText];
            }
        }
    };
    if (showHUD) {
        if (lock == 1) {
            [self showHudInView:self.view hint:DuiMaSuodingSendingText];
        }else {
            [self showHudInView:self.view hint:DuiMaUnSuodingSendingText];
        }
    }
    
    [[G100DevApi sharedInstance] controllerLockWithBikeid:self.bikeid devid:self.devid lock:lock callback:callback];
}

#pragma mark - G100DevSelectedViewDelete
- (void)G100DevSelectedView:(G100DevSelectedView *)selectedView device:(G100DeviceDomain *)device {
    if (!device.location_display) {
        DLog(@"该设备设置隐藏状态");
        return;
    }
    
    for (MAPointAnnotation *annotation in [self.mapView annotations]) {
        if ([annotation isKindOfClass:[CustomMAPointAnnotation class]]) {
            CustomMAPointAnnotation *customAnnotation = (CustomMAPointAnnotation *)annotation;
            if ([customAnnotation.positionDomain.devid integerValue] == device.device_id) {
                [self showAnnotationDetailWithAnnotation:customAnnotation isCenter:YES isSelected:YES];
            }
        }
    }
    
    [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    
    self.selectedDevid = [NSString stringWithFormat:@"%@", @(device.device_id)];
    
    __weak typeof(self) wself = self;;
    [self.dataHandler concernNow:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
            [self configDataWithBikeid:self.bikeid manually:YES isFirst:NO];
        }else{
            [wself showHint:response.errDesc];
        }
    }];
}

- (void)G100DevSelectedView:(G100DevSelectedView *)selectedView device:(G100DeviceDomain *)device visiableState:(BOOL)visiableState {
    for (MAPointAnnotation *annotation in [self.mapView annotations]) {
        if ([annotation isKindOfClass:[CustomMAPointAnnotation class]]) {
            CustomMAPointAnnotation *customAnnotation = (CustomMAPointAnnotation *)annotation;
            if ([customAnnotation.positionDomain.devid integerValue] == device.device_id) {
                customAnnotation.isVisible = visiableState;
            }
        }
    }
    
    for (CustomMAPointAnnotation *annotation in self.deviceAnnotationsArray) {
        if ([annotation.positionDomain.devid integerValue] == device.device_id) {
            annotation.isVisible = visiableState;
        }
    }
    
    // 需要更新数据库用户对此设备的显示隐藏设置
    NSString *deviceid = [NSString stringWithFormat:@"%@", @(device.device_id)];
    [[G100InfoHelper shareInstance] updateMyDevLocationDisplayWithuserid:self.userid bikeid:self.bikeid deviceid:deviceid locationDisplay:visiableState];

    self.devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    
    self.devSelectedView.dataArray = self.bikeDomain.gps_devices;
    
    [self refreshMapViewAnnotationState];
}

- (BOOL)G100DevSelectedView:(G100DevSelectedView *)selectedView visibleDevice:(G100DeviceDomain *)device {
    /** 2.2.1 版本 眼睛状态与设备位置 无关
    for (CustomMAPointAnnotation *annotation in self.deviceAnnotationsArray) {
        if ([annotation.positionDomain.devid integerValue] == device.device_id) {
            if (annotation.coordinate.latitude == 0 &&
                annotation.coordinate.longitude == 0 ) {
                return NO;
            }
            return YES;
        }
    }
     */
    
    return YES;
}

- (void)refreshMapViewAnnotationState {
    for (CustomMAPointAnnotation *annotation in self.deviceAnnotationsArray) {
        if ([[self.mapView annotations] containsObject:annotation]) {
            if (!annotation.isVisible) {
                [self.mapView removeAnnotation:annotation];
            }
            
            if (annotation.coordinate.latitude == 0 && annotation.coordinate.longitude == 0) {
                // 位置不存在的无效标注
                [self.mapView removeAnnotation:annotation];
            }
        }else {
            if (annotation.coordinate.latitude == 0 && annotation.coordinate.longitude == 0) {
                // 位置不存在的无效标注
                
            }else {
                // 先判断用户有没有设置显示位置信息
                G100DeviceDomain *domain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid
                                                                                        bikeid:self.bikeid
                                                                                         devid:annotation.positionDomain.devid];
                
                if (annotation.isVisible && domain.location_display) {
                    [self.mapView addAnnotation:annotation];
                }
                
                [self showAnnotationDetailWithAnnotation:annotation isCenter:annotation.isCenter isSelected:annotation.selected];
            }
        }
    }
}

#pragma mark - 定位时间解析
-(NSString *)locationTimeParase:(NSString *)timeStr {
    if (!timeStr.length) {
        return @"";
    }
    
    NSString * result = nil;
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * locationDate = [formatter dateFromString:timeStr];
    NSDate * nowDate = [NSDate dateToday0Dian]; //今天0点
    
    NSTimeInterval interval = [locationDate timeIntervalSinceDate:nowDate];
    
    if (interval > 0) {
        result = [NSString stringWithFormat:@"今天 %@", [timeStr substringWithRange:NSMakeRange(11, 5)]];
    }else if (interval > -24 * 60 * 60) {
        result = [NSString stringWithFormat:@"昨天 %@", [timeStr substringWithRange:NSMakeRange(11, 5)]];
    }else {
        result = [timeStr substringWithRange:NSMakeRange(5, 11)];
    }
    
    return result;
}

#pragma mark - G100TopViewClickActionDelegate
-(void)topViewClicked{
    G100AMapOfflineMapViewController *viewController = [[G100AMapOfflineMapViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self initialData];
    
    [self ebservice];
    
    [self showDefaultMapViewRect:NO];
    
    [self setupNotificationObserver];
    
    __weak typeof(self) wself = self;;
    [self.dataHandler concernNow:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
            [self configDataWithBikeid:self.bikeid manually:YES isFirst:YES];
        }else{
            [wself showHint:response.errDesc];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if (self.hasAppear) {
        // 刷新标注显示图案 解决从其他页面刷新标注后 显示标注图案错误 大头钉
        if ([self.deviceAnnotationsArray count]) {
            [self.mapView removeAnnotations:[self.mapView annotations]];
            [self refreshMapViewAnnotationState];
        }
    }
    self.hasAppear = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.dataHandler addConcernByCustomInterval];
    
    [self.functionView regulateLayout];
    
    [self startLocationService];
    
    if (!_viewDidAppear) {
        if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"tipsfor_devGPSView"]) {
            [self addHoledView];
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"tipsfor_devGPSView" leftTimes:0];
        }
    }
    _viewDidAppear = YES;
    
    [self insepectNet];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    // 防止其他情况导致 引导提示无法消除
    if (_holedView || _holedView.superview) {
        [self.holedView removeHoles];
        [self.holedView removeFromSuperview];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.dataHandler removeConcernByCustomInterval];
    
    [self stopLocationService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog(@"GPS 页面销毁");
    
    _ebservice.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperBikeInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperDeviceInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
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
