//
//  G100CardUserCarViewController2.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardUserCarViewController2.h"
#import "G100BikeManager.h"
#import "G100Mediator+BikeDetail.h"
#import "G100Mediator+AddBike.h"
#import "G100DeviceDomain.h"
#import "BikeQRCodeView.h"
#import "G100DevDataHandler.h"
#import "G100BikesRuntimeDomain.h"
#import "CDDDataHelper.h"
#import "G100BikeInfoView.h"
#import "G100BikeCardView.h"
#import "G100Mediator+BikeDetection.h"
#import "G100ScanViewController.h"
#import "G100WebViewController.h"
#import "G100UrlManager.h"
#import "G100Mediator+Login.h"

@interface G100CardUserCarViewController2 () <G100DevDataHandlerDelegate, G100BikeInfoTapDelegate>

@property (strong, nonatomic) G100BikeManager *bikeManager;
@property (strong, nonatomic) G100DeviceDomain *deviceDomin;
@property (strong, nonatomic) G100DevDataHandler *dataHandler;
@property (strong, nonatomic) G100BikesRuntimeDomain *bikesRuntimeDomain;

@property (strong, nonatomic) G100BikeCardView *bikeCardView;
@property (strong, nonatomic) G100BikeInfoView *bikeInfoView;

@property (assign, nonatomic) BOOL isBike;
@property (assign, nonatomic) BOOL isDevice;

@end

@implementation G100CardUserCarViewController2

- (void)dealloc {
    DLog(@"UserCar 已经销毁");
    
    _dataHandler.delegate = nil;
    _dataHandler = nil;
}

#pragma mark - Lazy load
- (G100BikeManager *)bikeManager {
    if (!_bikeManager) {
        _bikeManager = [[G100BikeManager alloc] init];
    }
    return _bikeManager;
}

- (G100BikeCardView *)bikeCardView {
    if (!_bikeCardView) {
        _bikeCardView = [G100BikeCardView showView];
        _bikeCardView.bikeInfoView.delegate = self;
    }
    return _bikeCardView;
}

- (G100BikeInfoView *)bikeInfoView {
    if (!_bikeInfoView) {
        _bikeInfoView = [G100BikeInfoView loadBikeInfoView];
        _bikeInfoView.backgroundColor = [UIColor clearColor];
        _bikeInfoView.delegate = self;
    }
    return _bikeInfoView;
}

#pragma mark - Public Method
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.bikeDomain = _cardModel.bike;
    [self differIsBikeAndisDevice];
    [self initBikeData];
}

#pragma mark - setupView
- (void)setupView {
    [self.view addSubview:self.bikeInfoView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bikeInfoViewTap)];
    [self.bikeInfoView.rightBattView addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor clearColor];
    [self.bikeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - Private Method
- (void)bikeInfoViewTap {
    if (!IsLogin()) {
        [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
            if ([UIApplication sharedApplication].statusBarHidden) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            }
        }];
        return;
    }
    
    NSString *isMaster = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:[self.bikeDomain isMaster]]];
    G100WebViewController *webVc = [[G100WebViewController alloc]init];
    webVc.httpUrl = [[G100UrlManager sharedInstance] getBatteryAndVoltageUrlWithUserid:self.userid
                                                                                bikeid:self.bikeid
                                                                              isMaster:isMaster
                                                                                 devid:[NSString stringWithFormat:@"%ld",(long)self.bikeDomain.mainDevice.device_id]
                                                                              model_id:self.bikeDomain.mainDevice.model_id];
    [self.navigationController pushViewController:webVc animated:YES];
}

- (void)initBikeData {
    __weak typeof(self) wself = self;
    [self.bikeManager getBikeModelWithData:self.bikeDomain compete:^(G100BikeModel *bikeModel) {
        wself.bikeInfoView.bikeModel = bikeModel;
        if ([wself.bikeid isEqualToString:@"-9999"]) {
            wself.bikeInfoView.setSafeMode = -1;
            wself.bikeInfoView.soc = 100;
            wself.bikeInfoView.expecteddistance = 999;
            wself.bikeInfoView.eleDoorState = NO;
            wself.bikeInfoView.isCompute = YES;
            [wself.bikeInfoView updateSafeState];
        }
    }];
}

/** 判断当前车辆有无设备 */
- (void)differIsBikeAndisDevice {
    if ([self.bikeid isEqualToString:@"0"] || self.bikeid == nil) {
        self.isBike = NO;
        self.isDevice = NO;
    }else {
        self.isBike = YES;
        if (!self.bikeDomain) {
            self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
        }
        self.bikeid = [NSString stringWithFormat:@"%ld",(long)self.bikeDomain.bike_id];
        if ([self.bikeDomain.gps_devices count]) {
            self.isDevice = YES;
        }else {
            self.isDevice = NO;
        }
    }
}

//自动更新天气
- (void)setWeatherFirstRequest {
    __weak G100CardUserCarViewController2 * wself = self;
    [[G100WeatherManager sharedInstance] getWeatherModelByManual:NO withUpdateCallback:^(NSError *error, G100WeatherModel *weatherModel) {
        if (weatherModel) {
            wself.bikeInfoView.weatherModel = weatherModel;
        }
        
    } complete:^(NSError *error, G100WeatherModel *weatherModel) {
        if (error.code == AMapLocationErrorLocateFailed) {
            wself.bikeInfoView.weatherModel = nil;
            return;
        }
        if (error.code == AMapLocationErrorNotConnectedToInternet) {
            wself.bikeInfoView.weatherModel = nil;
            return;
        }
        
        if (weatherModel) {
            wself.bikeInfoView.weatherModel = weatherModel;
        }else {
            wself.bikeInfoView.weatherModel = nil;
        }
    }];
    self.hasAppear = YES;
}

- (void) updateBikeInfo{
    for (G100BikeRuntimeDomain *runtime in self.bikesRuntimeDomain.runtime) {
        if (self.bikeid.integerValue == runtime.bike_id) {
            //刷新UI
            self.bikeInfoView.setSafeMode = runtime.alertor_status.security;
            self.bikeInfoView.soc = runtime.batt_soc * 100;
            self.bikeInfoView.expecteddistance = runtime.expected_distance;
            self.bikeInfoView.eleDoorState = runtime.acc == 1 ? YES : NO;
            if (self.bikeDomain.bike_type != 1) {
                self.bikeInfoView.isCompute = runtime.compute == 1 ? NO : YES;
                self.bikeInfoView.vol = (NSInteger)runtime.batt_vol;
            }else{
                self.bikeInfoView.isCompute = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bikeInfoView updateSafeState];
            });
            break;
        }
    }
}

#pragma mark - G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.errCode == 0) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
        [self updateBikeInfo];
    }
}

#pragma mark - G100BikeInfoTapDelegate
- (void)buttonClickedToScaleQRCode:(UIButton *)button {
    BikeQRCodeView *qrView = [BikeQRCodeView loadViewFromNibWithTitle:@"扫描车辆二维码绑定"
                                                               qrcode:[NSString stringWithFormat:@"%@", self.bikeDomain.add_url]];
    [qrView showInVc:self.topParentViewController view:self.topParentViewController.view animation:YES];
}

-(void)viewTapToPushBikeDetailWithView:(UIView *)touchedView {
    if (![UserAccount sharedInfo].appfunction.mybikes_bikedetail.enable && IsLogin()) {
        return;
    };
    
    if ([touchedView isKindOfClass:[G100BikeInfoView class]]) {
        if (self.bikeid.integerValue == -9999) {
            if (IsLogin()) {
                [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                    if (viewController && loginSuccess) {
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }];
            }else {
                // 去登录
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }];
            }
        }else {
            __weak typeof(self) wself = self;
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetail:self.userid bikeid:self.bikeid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (viewController && loginSuccess) {
                    [wself.navigationController pushViewController:viewController animated:YES];
                }
            }];
        }
    }
}

- (void)viewTapToPushTestDetailWithView:(UIView *)touchedView {
    if (![UserAccount sharedInfo].appfunction.securityscore.enable && IsLogin()) {
        return;
    };
    
    if ([touchedView isKindOfClass:[G100BikeInfoView class]]) {
        if (self.bikeid.integerValue == -9999) {
            if (IsLogin()) {
                [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                    if (viewController && loginSuccess) {
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }];
            }else {
                // 去登录
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }];
            }
        }else {
            __weak G100CardUserCarViewController2 *wself = self;
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetection:self.userid bikeid:self.bikeid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (viewController && loginSuccess) {
                    G100ScanViewController *scanDetail = (G100ScanViewController *)viewController;
                    scanDetail.testOverAnimter = ^(G100TestResultDomain *testResult){
                        // wself.bikeInfoView.testResultDomin = testResult;
                    };
                    [wself.navigationController pushViewController:scanDetail animated:YES];
                }
            }];
        }
    }
}

//点击刷新天气
-(void)viewTapToRefreshWeather:(UIView *)touchedView {
    __weak G100CardUserCarViewController2 * wself = self;
    [[G100WeatherManager sharedInstance] getWeatherModelByManual:YES withUpdateCallback:nil complete:^(NSError *error, G100WeatherModel *weatherModel) {
        if (error.code == AMapLocationErrorLocateFailed) {
            [self.topParentViewController showWarningHint:@"未打开GPS"];
            //wself.bikeCardView.bikeInfoView.weatherModel = nil;
            return;
        }
        if (error.code == AMapLocationErrorNotConnectedToInternet) {
            [self.topParentViewController showWarningHint:@"未打开网络"];
            //wself.bikeCardView.bikeInfoView.weatherModel = nil;
            return;
        }
        
        if (weatherModel) {
            [self.topParentViewController showHint:@"已更新天气"];
            wself.bikeInfoView.weatherModel = weatherModel;
        }else {
            //wself.bikeCardView.bikeInfoView.weatherModel = nil;
            [self.topParentViewController showWarningHint:@"无法获取数据"];
        }
    }];
}

//电量设置详情
- (void)buttonClickedToPushBattDetail:(UIButton *)button {
    //电池类型
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    NSString *isMaster = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.bikeDomain.isMaster]];
    G100WebViewController *webVc = [[G100WebViewController alloc]init];
    webVc.httpUrl = [[G100UrlManager sharedInstance] getBatteryAndVoltageUrlWithUserid:self.userid
                                                                                bikeid:self.bikeid
                                                                              isMaster:isMaster
                                                                                 devid:[NSString stringWithFormat:@"%ld",(long)self.bikeDomain.mainDevice.device_id]
                                                                              model_id:self.bikeDomain.mainDevice.model_id];
    [self.navigationController pushViewController:webVc animated:YES];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self differIsBikeAndisDevice];
    [self initBikeData];
    
    _dataHandler = [[G100DevDataHandler alloc] initWithUserid:self.userid bikeid:self.bikeid];
    _dataHandler.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) wSelf = self;
    [self.dataHandler concernNow:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            wSelf.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
            [wSelf updateBikeInfo];
            wSelf.hasAppear = YES;
        }else{
            [wSelf showHint:response.errDesc];
        }
    }];
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

#pragma mark - 出现或消失
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
}

- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
}

@end
