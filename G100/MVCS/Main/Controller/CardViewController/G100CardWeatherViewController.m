//
//  G100CardWeatherViewController.m
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardWeatherViewController.h"
#import "G100WeatherAndCarView.h"
#import "G100WeatherManager.h"
#import "G100ScanViewController.h"
#import "G100Mediator+AddBike.h"
#import "G100Mediator+BikeDetection.h"
#import "G100Mediator+ScanCode.h"

@interface G100CardWeatherViewController ()<G100TapAnimationDelegate,G100AddCarDelegate> {
    BOOL _hasShowFirstDetection;
}

@property (nonatomic, strong) G100WeatherAndCarView *weatherAndCarView;
@property (nonatomic, strong) G100WeatherAndCarView *weatherAndNoCarView;

@property (strong, nonatomic) G100TestResultDomain *lastTestResult;

@end

@implementation G100CardWeatherViewController

- (void)dealloc {
    DLog(@"WeatherAndCar 已经销毁");
}

- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.bikeDomain = cardModel.bike;
    if (self.bikeDomain) {
        self.bikeid = [NSString stringWithFormat:@"%ld",(long)self.bikeDomain.bike_id];
    }
    self.lastTestResult = [[G100InfoHelper shareInstance] findMyBikeTestResultWithUserid:self.userid bikeid:self.bikeid];
    if (_hasShowFirstDetection && self.lastTestResult) {
        [self.weatherAndCarView.carView beginAnimateWithParameter:_lastTestResult isAnimate:NO];
     }
    if (self.hasAppear) {
        [[G100WeatherManager sharedInstance] getWeatherModelByManual:NO withUpdateCallback:nil complete:nil];
    }
}

#pragma mark - Private method
- (void)setNoDeviceView {
    if (!_weatherAndCarView) {
        _weatherAndCarView = [[G100WeatherAndCarView alloc] initViewWithIsBike:NO andIsDevice:NO];
        _weatherAndCarView.weaView.clickedAniView.delegate = self;
        _weatherAndCarView.noCarView.delegate = self;
        _weatherAndCarView.weatherView.backgroundColor = [UIColor clearColor];
        
        _weatherAndCarView.weatherView.layer.shadowOpacity = 1.0;
        _weatherAndCarView.weatherView.layer.shadowOffset = CGSizeMake(2, 2);
        _weatherAndCarView.weatherView.layer.shadowRadius = 2.0f;
        _weatherAndCarView.weatherView.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3].CGColor;
        
        [self.view addSubview:_weatherAndCarView];
        [_weatherAndCarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
}

- (void)setBikeView {
    if (!self.bikeDomain) {
        self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    }
    if (self.bikeDomain.gps_devices.count > 0) {
        if (!_weatherAndCarView && ![_weatherAndCarView superview]) {
            _weatherAndCarView = [[G100WeatherAndCarView alloc] initViewWithIsBike:YES andIsDevice:YES];
            _weatherAndCarView.weaView.clickedAniView.delegate = self;
            _weatherAndCarView.carView.clickedAniView.delegate = self;
            
            [self.view addSubview:_weatherAndCarView];
            [_weatherAndCarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
        
        if ([_weatherAndNoCarView superview]) {
            [_weatherAndNoCarView removeFromSuperview];
            _weatherAndNoCarView = nil;
        }
        self.lastTestResult = [[G100InfoHelper shareInstance] findMyBikeTestResultWithUserid:self.userid bikeid:self.bikeid];

    }else {
        [self setNoDeviceView];
    }
}

- (void)setupView {
    if (!self.bikeDomain) {
        self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    }
    _weatherAndCarView = [[G100WeatherAndCarView alloc] initViewWithIsBike:YES andIsDevice:YES];
    _weatherAndCarView.weaView.clickedAniView.delegate = self;
    _weatherAndCarView.carView.clickedAniView.delegate = self;
    
    [self.view addSubview:_weatherAndCarView];
    [_weatherAndCarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    _lastTestResult = self.bikeDomain.test_result;
}

- (void)setDetectionFirstShow {
    if (_hasShowFirstDetection) {
        return;
    }
    _hasShowFirstDetection = YES;
    [self.weatherAndCarView.carView beginAnimateWithParameter:_lastTestResult isAnimate:YES];
}

- (void)setWeatherFirstRequest {
    __weak G100CardWeatherViewController * wself = self;
    [[G100WeatherManager sharedInstance] getWeatherModelByManual:NO withUpdateCallback:^(NSError *error, G100WeatherModel *weatherModel) {
        if (error.code == AMapLocationErrorLocateFailed)  {
            [wself.weatherAndCarView.weaView addErrorViewWithErrorInfo:@"无法获取位置"];
            return;
        }
        if (error.code == AMapLocationErrorNotConnectedToInternet) {
            [wself.weatherAndCarView.weaView addErrorViewWithErrorInfo:@"无法获取数据"];
            return;
        }
        if (weatherModel) {
            wself.weatherAndCarView.weaView.weatherModel = weatherModel;
            [wself.weatherAndCarView.weaView updateDataWithWeatherModel:weatherModel];
        }else {
            [wself.weatherAndCarView.weaView addErrorViewWithErrorInfo:@"无法获取数据"];
        }
    } complete:^(NSError *error, G100WeatherModel *weatherModel) {
        if (error.code == AMapLocationErrorLocateFailed) {
            wself.weatherAndCarView.weaView.weatherModel = nil;
            self.weatherAndCarView.weaView.errorInfo = @"无法获取位置";
            return;
        }
        if (error.code == AMapLocationErrorNotConnectedToInternet) {
            //[wself.weatherAndCarView.weaView addErrorView];
            wself.weatherAndCarView.weaView.weatherModel = nil;
            self.weatherAndCarView.weaView.errorInfo = @"无法获取数据";
            return;
        }
        if (weatherModel) {
            wself.weatherAndCarView.weaView.weatherModel = weatherModel;
        }else {
            wself.weatherAndCarView.weaView.weatherModel = nil;
            self.weatherAndCarView.weaView.errorInfo = @"无法获取数据";
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.weatherAndCarView.weaView beginAnimateWithIsInit:YES];
    });
    self.hasAppear = YES;
}

#pragma mark - G100TapAnimationDelegate
- (void)viewTouchedToBeginAnimate:(UIView *)touchedView touchPoint:(CGPoint)point {
    if ([touchedView isKindOfClass:[G100WeatherView class]])  {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.weatherAndCarView.weaView.ErrorView) {
                return;
            }
            [self.weatherAndCarView.weaView beginAnimateWithIsInit:NO];
        });
    }
}

- (void)viewTouchedEndWithView:(UIView *)touchedView touchPoint:(CGPoint)point {
    if ([touchedView isKindOfClass:[G100WeatherView class]]) {
        __weak G100CardWeatherViewController * wself = self;
        [[G100WeatherManager sharedInstance] getWeatherModelByManual:YES withUpdateCallback:nil complete:^(NSError *error, G100WeatherModel *weatherModel) {
            if (error.code == AMapLocationErrorLocateFailed) {
                [self.topParentViewController showWarningHint:@"未打开GPS"];
                wself.weatherAndCarView.weaView.weatherModel = nil;
                self.weatherAndCarView.weaView.errorInfo = @"无法获取位置";
                return;
            }
            if (error.code == AMapLocationErrorNotConnectedToInternet) {
                [self.topParentViewController showWarningHint:@"未打开网络"];
                wself.weatherAndCarView.weaView.weatherModel = nil;
                self.weatherAndCarView.weaView.errorInfo = @"无法获取数据";
                return;
            }
            
            if (weatherModel) {
                [self.topParentViewController showHint:@"已更新天气"];
                wself.weatherAndCarView.weaView.weatherModel = weatherModel;
            }else {
                wself.weatherAndCarView.weaView.weatherModel = nil;
                self.weatherAndCarView.weaView.errorInfo = @"无法获取数据";
                [self.topParentViewController showWarningHint:@"无法获取数据"];
            }
        }];
    }
}

- (void)viewTouchedToPushWithView:(UIView *)touchedView touchPoint:(CGPoint)point {
    if ([touchedView isKindOfClass:[CarDetectionView class]]) {
        // 跳到安全评分
        G100ScanViewController *scanDetail = (G100ScanViewController *)[[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetection:self.userid
                                                                                                                                           bikeid:self.bikeid
                                                                                                                                            devid:self.devid];
        
        __weak G100CardWeatherViewController * wself = self;
        scanDetail.testOverAnimter = ^(G100TestResultDomain *testResult){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.lastTestResult = testResult;
                _hasShowFirstDetection = YES;
                [wself.weatherAndCarView.carView beginAnimateWithParameter:testResult isAnimate:YES];
            });
        };
        [self.navigationController pushViewController:scanDetail animated:YES];
    }
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hasShowFirstDetection = NO;
    if ([self.bikeid isEqualToString:@"0"] || self.bikeid == nil) {
        [self setNoDeviceView];
    }else {
        [self setupView];
    }
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
    if (!self.hasAppear) {
        _hasShowFirstDetection = NO;
        [self performSelector:@selector(setWeatherFirstRequest) withObject:nil afterDelay:0.3];
    }
    if ((!_hasShowFirstDetection) && self.lastTestResult) {
        if ([self.bikeid isEqualToString:@"0"] || self.bikeid == nil) {
            
        }else {
            [self performSelector:@selector(setDetectionFirstShow) withObject:nil afterDelay:0.3];
        }
    }
}

- (void)mdv_viewWillDisappear:(BOOL)animated {
    [super mdv_viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setDetectionFirstShow) object:nil];
}

#pragma mark - Button Event
-(void)buttonClickedToAddCar:(UIButton *)button {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

@end
