//
//  G100CardBatteryViewController.m
//  G100
//
//  Created by sunjingjing on 16/12/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBatteryViewController.h"
#import "G100BikesRuntimeDomain.h"
#import "G100DevDataHandler.h"
#import "G100BatteryApi.h"
#import "G100BikeApi.h"

#import "G100BattGPSView.h"
#import "G100Mediator+CSBBatteryDetail.h"

@interface G100CardBatteryViewController () <G100BattGPSTapDelegate> {
    BOOL _battDataComplete;
    BOOL _bikeDataComplete;
}

@property (strong, nonatomic) G100BattGPSView *battGPSView;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation G100CardBatteryViewController

- (void)dealloc {
    DLog(@"电池卡片已释放");
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - Lazy load
-(G100BattGPSView *)battGPSView {
    if (!_battGPSView) {
        _battGPSView = [G100BattGPSView showView];
        _battGPSView.delegate = self;
    }
    return _battGPSView;
}

#pragma mark - Public Method
- (void)setCardModel:(G100CardModel *)cardModel{
    _cardModel = cardModel;
    if (!self.bikeDomain) {
        self.bikeDomain = cardModel.bike;
        self.bikeid = [NSString stringWithFormat:@"%ld",self.bikeDomain.bike_id];
    }
    
    _battDataComplete = YES;
    _bikeDataComplete = YES;
}

#pragma mark - Private Method
- (void)initData {
    if (!IsLogin()) {
        return;
    }
    
    if (!_battDataComplete || !_bikeDataComplete) {
        return;
    }
    
    __weak typeof(self) wself = self;
    [[G100BatteryApi sharedInstance] getBatteryInfoWithBatteryid:self.devid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        _battDataComplete = YES;
        if (requestSuccess) {
            G100BatteryDomain *batt = [[G100BatteryDomain alloc] initWithDictionary:response.data];
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.battGPSView.batteryDomain = batt;
            });
        }else {
            // 不显示错误信息
            // [wself.topParentViewController showHint:response.errDesc];
        }
    }];
    
    _battDataComplete = NO;
    
    if (self.bikeid) {
        [[G100BikeApi sharedInstance] getBikeRuntimeWithBike_ids:@[self.bikeid] traceMode:1 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            _bikeDataComplete = YES;
            if (requestSuccess) {
                G100BikesRuntimeDomain *bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
                for (G100BikeRuntimeDomain *runtime in bikesRuntimeDomain.runtime) {
                    if (self.bikeid.integerValue == runtime.bike_id) {
                        //刷新UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [wself.battGPSView updateEleDoorState:runtime.acc];
                        });
                        break;
                    }
                }
            }
        }];
        
        _bikeDataComplete = NO;
    }else {
        _bikeDataComplete = YES;
    }
}

- (void)startTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(refreshBattData)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)destoryTimer {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)refreshBattData {
    [self initData];
}

#pragma mark -- G100BattGPSTapDelegate
-(void)viewTapToPushBattGPSDetailWithView:(UIView *)touchedView {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForCSBBatteryDetail:self.userid
                                                                           bikeid:self.bikeid
                                                                        batteryid:self.devid
                                                                     loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
                                                                     }];
}

#pragma mark - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"DCDCDC"];
    [self.view addSubview:self.battGPSView];
    [self.battGPSView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _battDataComplete = YES;
    _bikeDataComplete = YES;
    
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self destoryTimer];
}

#pragma mark - 出现/消失
- (void)mdv_viewWillAppear:(BOOL)animated {
    [super mdv_viewWillAppear:animated];
    
}
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
    _battDataComplete = YES;
    _bikeDataComplete = YES;
    
    [self startTimer];
}
- (void)mdv_viewWillDisappear:(BOOL)animated {
    [super mdv_viewWillDisappear:animated];
    
}
- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
