//
//  G100CardCommonViewController.m
//  G100
//
//  Created by sunjingjing on 16/12/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardCommonViewController.h"
#import "G100BattInfoView.h"
#import "G100Mediator+BikeReport.h"
#import "G100Mediator+SecuritySetting.h"
#import "G100DevDataHandler.h"
#import "G100BikesRuntimeDomain.h"
#import "G100BikeManager.h"
#import "G100UrlManager.h"
#import "G100WebViewController.h"
#import "G100MapServiceView.h"
#import "G100WeatherManager.h"
#import "G100SafeAndReportView.h"
#import "G100Mediator+MapService.h"
#import "G100BikeTestView.h"
#import "G100Mediator+BikeDetection.h"
#import "G100Mediator+AddBike.h"
#import "G100ScanViewController.h"
#import "G100FindBikeView.h"
#import "G100Mediator+BikeFinding.h"
#import "G100BikeApi.h"

@interface G100CardCommonViewController () <G100DevDataHandlerDelegate, G100BattNoCountDelegate, G100MapServiceViewDelegate, G100CardSafeSetAndReportViewTapDelegate, G100BikeTestViewTapDelegate, G100FindBikeViewTapDelegate>

@property (strong, nonatomic) G100BattInfoView *battInfoView;
@property (nonatomic, strong) G100DevDataHandler * dataHandler;
@property (nonatomic, strong) G100BikesRuntimeDomain * bikesRuntimeDomain;
@property (strong, nonatomic) G100BikeManager *bikeManager;
@property (strong, nonatomic) G100MapServiceView *mapServiceView;
@property (strong, nonatomic) G100WeatherManager *weatherManager;
@property (strong, nonatomic) G100SafeAndReportView *safeAndReportView;
@property (strong, nonatomic) G100BikeTestView *testView;
@property (strong, nonatomic) G100FindBikeView *findBikeView;

@end

@implementation G100CardCommonViewController

- (void)dealloc {
    DLog(@"通用卡片已释放");
    _dataHandler.delegate = nil;
    _dataHandler = nil;
}

#pragma mark - lazy loading
-(G100BattInfoView *)battInfoView {
    if (!_battInfoView) {
        _battInfoView = [G100BattInfoView showView];
        _battInfoView.needSingleCtrl = YES;
        _battInfoView.delegate = self;
    }
    return _battInfoView;
}
-(G100MapServiceView *)mapServiceView {
    if (!_mapServiceView) {
        _mapServiceView = [G100MapServiceView showView];
        _mapServiceView.needSingleCtrl = YES;
        _mapServiceView.delegate = self;
    }
    return _mapServiceView;
}
-(G100BikeManager *)bikeManager {
    if (!_bikeManager) {
        _bikeManager = [[G100BikeManager alloc] init];
    }
    return _bikeManager;
}
-(G100WeatherManager *)weatherManager {
    if (!_weatherManager) {
        _weatherManager = [G100WeatherManager sharedInstance];
    }
    return _weatherManager;
}

-(G100SafeAndReportView *)safeAndReportView {
    if (!_safeAndReportView) {
        _safeAndReportView = [G100SafeAndReportView showView];
        _safeAndReportView.delegate = self;
    }
    return _safeAndReportView;
}
-(G100BikeTestView *)testView {
    if (!_testView) {
        _testView = [G100BikeTestView showView];
        _testView.delegate = self;
    }
    return _testView;
}

-(G100FindBikeView *)findBikeView {
    if (!_findBikeView) {
        _findBikeView= [G100FindBikeView showView];
        _findBikeView.delegate = self;
    }
    return _findBikeView;
}

#pragma mark - Private Method
- (void)initBikeData {
    [self.bikeManager getBikeModelWithData:_cardModel.bike compete:^(G100BikeModel *bikeModel) {
        _battInfoView.bikeModel = bikeModel;
    }];
}

- (void)loadTestResult {
    self.testView.testResultDomin = [[G100InfoHelper shareInstance] findMyBikeTestResultWithUserid:self.userid bikeid:self.bikeid];
}

- (void)loadLostRecordData {
    G100DevFindLostDomain *devLostModel = [[G100DevFindLostDomain alloc] initWithDictionary:[[G100InfoHelper shareInstance] findMyBikeLastFindRecordWithUserid:self.userid bikeid:self.bikeid]];
    self.findBikeView.latestTime = devLostModel.time;
    
    __weak G100CardCommonViewController * wself = self;
    [[G100BikeApi sharedInstance] getFindLostRecordWithBikeid:self.bikeid lostid:self.bikeDomain.lost_id page:1 size:1 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // 提取丢车记录最新信息
            G100DevFindLostListDomain *findListDomain = [[G100DevFindLostListDomain alloc] initWithDictionary:response.data];
            if (findListDomain.findlost.count > 0) {
                wself.findBikeView.devLostModel = [findListDomain.findlost firstObject];
                if (![wself.findBikeView.latestTime isEqualToString:wself.findBikeView.devLostModel.time]) {
                    wself.findBikeView.redDotImageView.hidden = NO;
                }else {
                    wself.findBikeView.redDotImageView.hidden = YES;
                }
            }
        }else {
            [wself showHint:response.errDesc];
        }
    }];
}

#pragma mark - Public Method
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.bikeDomain = _cardModel.bike;
    
    if ([_cardModel.identifier isEqualToString:@"batt_info"]) {
        [self initBikeData];
    }else if ([_cardModel.identifier isEqualToString:@"test_info"]) {
        self.testView.testResultDomin = [[G100InfoHelper shareInstance] findMyBikeTestResultWithUserid:self.userid bikeid:self.bikeid];
    }else if ([_cardModel.identifier isEqualToString:@"safeAndReport_info"]){
        self.safeAndReportView.safeMode = cardModel.bike.mainDevice.security.mode;
        self.safeAndReportView.unreadMsgCount = 0;
    }else if ([_cardModel.identifier isEqualToString:@"find_record_info"]){
        [self loadLostRecordData];
    }
}

#pragma mark - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"DCDCDC"];
    if ([_cardModel.identifier isEqualToString:@"test_info"]) {
        [self.view addSubview:self.testView];
        [self.testView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        [self loadTestResult];
    }else if ([_cardModel.identifier isEqualToString:@"mapService_info"]){
        [self.view addSubview:self.mapServiceView];
        [self.mapServiceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }else if ([_cardModel.identifier isEqualToString:@"safeAndReport_info"]){
        [self.view addSubview:self.safeAndReportView];
        [self.safeAndReportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }else if ([_cardModel.identifier isEqualToString:@"find_record_info"]){
        [self.view addSubview:self.findBikeView];
        [self.findBikeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        [self loadLostRecordData];
    }
}

#pragma mark - G100CardViewTapDelegate
-(void)viewTapToPushCardReportDetailWithView:(UIView *)touchedView {
    if (![UserAccount sharedInfo].appfunction.bikeusagereport.enable && IsLogin()) {
        return;
    };
    if ([touchedView isKindOfClass:[G100CardBaseView class]]){
        //用车报告
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeReport:self.userid
                                                                                                            bikeid:self.bikeid
                                                                                                             devid:self.devid];
        if ([CURRENTVIEWCONTROLLER isKindOfClass:[viewController class]]) {
            return;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(void)viewTapToPushCardSafeSetDetailWithView:(UIView *)touchedView {
    if (![UserAccount sharedInfo].appfunction.securitysetting.enable && IsLogin()) {
        return;
    };
    if ([touchedView isKindOfClass:[G100CardBaseView class]]) {
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSecuritySetting:self.userid
                                                                                                                 bikeid:self.bikeid
                                                                                                                  devid:self.devid];
        if ([CURRENTVIEWCONTROLLER isKindOfClass:[viewController class]]) {
            return;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(void)viewTapToPushTestDetailWithView:(UIView *)touchedView {
    if (![UserAccount sharedInfo].appfunction.securityscore.enable && IsLogin()) {
        return;
    };
    __weak G100CardCommonViewController * wself = self;
    if ([touchedView isKindOfClass:[G100BikeTestView class]]) {
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetection:self.userid bikeid:self.bikeid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (viewController && loginSuccess) {
                if (wself.bikeid.integerValue == -9999) {
                    UIViewController *addBikeVC = [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:wself.userid];
                    [self.navigationController pushViewController:addBikeVC animated:YES];
                }else {
                    G100ScanViewController *scanDetail = (G100ScanViewController *)viewController;
                    scanDetail.testOverAnimter = ^(G100TestResultDomain *testResult){
                        wself.testView.testResultDomin = testResult;
                    };
                    [self.navigationController pushViewController:scanDetail animated:YES];
                }
            }
        }];
    }
}

- (void)viewTapToPushRecordFindBikeWithView:(UIView *)touchedView {
    if ([touchedView isKindOfClass:[G100FindBikeView class]]) {
        UIViewController *findRecord = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeFinding:self.userid bikeid:self.bikeid lostid:self.bikeDomain.lost_id];
        [self.navigationController pushViewController:findRecord animated:YES];
    }
}

#pragma mark - G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.errCode == 0) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
        for (G100BikeRuntimeDomain *runtime in self.bikesRuntimeDomain.runtime) {
            if (self.bikeid.integerValue == runtime.bike_id) {
                //刷新UI
                self.battInfoView.bikeModel.soc  = runtime.batt_soc * 100;
                self.battInfoView.bikeModel.expecteddistance = runtime.expected_distance;
                self.battInfoView.bikeModel.eleDoorState = runtime.acc == 1 ? YES : NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.battInfoView updateBattDataUI];
                });
                break;
            }
        }
    }
}
#pragma mark - G100BattNoCountDelegate
- (void)buttonClickedToPushBattDetail:(UIButton *)button {
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

#pragma mark - G100MapServiceViewDelegate
- (void)mapServiceView:(UIView *)touchedView buttonClicked:(UIButton *)button {
    switch (button.tag) {
        case 2001:
            [self handleAddEle];
            break;
        case 2002:
            [self handleAddAir];
            break;
        case 2003:
            [self handleRepair];
            break;
        case 2004:
            [self handleSos];
            break;
        default:
            break;
    }
}

- (void)mapServiceView:(UIView *)touchedView viewTaped:(UIView *)view {
    switch (view.tag) {
        case 1001:
            [self handleAddEle];
            break;
        case 1002:
            [self handleAddAir];
            break;
        case 1003:
            [self handleRepair];
            break;
        case 1004:
            [self handleSos];
            break;
        default:
            break;
    }
}

- (void)handleAddEle {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForMapService:self.userid webTitle:@"充电" httpUrl: [[G100UrlManager sharedInstance] getMapServiceDetailWithUserid:self.userid type:@"3"] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)handleAddAir {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForMapService:self.userid webTitle:@"打气" httpUrl: [[G100UrlManager sharedInstance] getMapServiceDetailWithUserid:self.userid type:@"5"] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)handleRepair {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForMapService:self.userid webTitle:@"维修" httpUrl: [[G100UrlManager sharedInstance] getMapServiceDetailWithUserid:self.userid type:@"1"] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)handleSos {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForMapService:self.userid webTitle:@"救援" httpUrl: [[G100UrlManager sharedInstance] getMapServiceDetailWithUserid:self.userid type:@"9"] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册观察者
    _dataHandler = [[G100DevDataHandler alloc] initWithUserid:self.userid bikeid:self.bikeid];
    _dataHandler.delegate = self;
    
    [self setupView];
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

#pragma mark - 出现或消失
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
}

- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
}

@end
