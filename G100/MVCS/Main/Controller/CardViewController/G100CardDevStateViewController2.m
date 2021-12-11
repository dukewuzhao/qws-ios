//
//  G100CardDevStateViewController2.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardDevStateViewController2.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "G100Mediator+GPS.h"
#import "G100Mediator+BikeReport.h"
#import "G100Mediator+SecuritySetting.h"
#import "G100Mediator+ScanCode.h"
#import "G100DevDataHandler.h"
#import "G100BikesRuntimeDomain.h"
#import "PositionDomain.h"
#import "G100NoCarView.h"
#import "G100GPSCardView.h"
#import "G100DevMapView.h"

#import "G100MallViewController.h"

@interface G100CardDevStateViewController2 () <G100DevDataHandlerDelegate, G100CardDevMapViewTapDelegate, G100AddCarDelegate>

@property (nonatomic, strong) G100DevDataHandler *dataHandler;
@property (nonatomic, strong) G100BikesRuntimeDomain *bikesRuntimeDomain;

@property (strong, nonatomic) G100GPSCardView *gpsCardView;
@property (strong, nonatomic) G100DevMapView *devMapView;
@property (strong, nonatomic) G100NoCarView *noCarView;

@end

@implementation G100CardDevStateViewController2

- (void)dealloc {
    DLog(@"DeviceState 已经销毁");
    
    _dataHandler.delegate = nil;
    _dataHandler = nil;
}

#pragma mark - Lazy load
- (G100GPSCardView *)gpsCardView {
    if (!_gpsCardView) {
        _gpsCardView = [G100GPSCardView showView];
    }
    return _gpsCardView;
}

#pragma mark - Public Method
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.bikeDomain = cardModel.bike;
    self.bikeid = [NSString stringWithFormat:@"%ld", (long)self.bikeDomain.bike_id];
    self.devid = cardModel.devid;
    self.devMapView.deviceCount = cardModel.bike.gps_devices.count;
    self.devMapView.hasSmartDevice = cardModel.bike.battery_devices.count > 0 ? YES : NO;
    
    [self setupNoCarView];
}

#pragma mark - setupView
- (void)setupNoCarView {
    if (_cardModel.bike.devices.count > 0) {
        if ([self.noCarView superview]) {
            [self.noCarView removeFromSuperview];
            self.noCarView = nil;
        }
    }else {
        if (![self.noCarView superview]) {
            _noCarView = [G100NoCarView showView];
            _noCarView.delegate = self;
            [self.view addSubview:self.noCarView];
            [self.noCarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
    }
}
- (void)configGPSCardView {
    _devMapView = [G100DevMapView loadDevStateView];
    _devMapView.delegate = self;
    [self.view addSubview:self.devMapView];
    [self.devMapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.devMapView.deviceCount = self.bikeDomain.gps_devices.count;
}

#pragma mark G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.success) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc] initWithDictionary:response.data];
        BOOL hasDeviceLocation = NO;
        for (G100BikeRuntimeDomain * bikeRuntimeDomain in self.bikesRuntimeDomain.runtime) {
            if ([bikeid integerValue] == bikeRuntimeDomain.bike_id) {
                NSInteger index = 0;
                NSMutableArray *positionsArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in bikeRuntimeDomain.device_runtimes) {
                    G100DeviceRuntimeDomain *deviceRuntimeDomain = [[G100DeviceRuntimeDomain alloc] initWithDictionary:dict];
                    
                    PositionDomain * positionDomain = [[PositionDomain alloc] init];
                    positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", [NSDate tl_locationTimeParase:deviceRuntimeDomain.loc_time]];
                    positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntimeDomain.loc_desc];
                    
                    G100DeviceDomain *device = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:[NSString stringWithFormat:@"%@", @(deviceRuntimeDomain.device_id)]];
                    if (bikeRuntimeDomain.device_runtimes.count > 1) {
                        positionDomain.name = [NSString stringWithFormat:@"%@ %@", @(index+1), device.name];
                    }else {
                        positionDomain.name = device.name;
                    }
                    
                    positionDomain.isMainDevice = device.isMainDevice;
                    
                    positionDomain.desc = deviceRuntimeDomain.loc_desc;
                    positionDomain.time = [NSDate tl_locationTimeParase:deviceRuntimeDomain.loc_time];
                    
                    positionDomain.gpssvs = deviceRuntimeDomain.gps_level;
                    positionDomain.bssignal = deviceRuntimeDomain.bs_level;
                    
                    CLLocationCoordinate2D coordinate;
                    if (deviceRuntimeDomain.lati == 0 && deviceRuntimeDomain.longi == 0) {
                        coordinate = CLLocationCoordinate2DMake(deviceRuntimeDomain.bs_lati, deviceRuntimeDomain.bs_longi);
                    }else {
                        coordinate = CLLocationCoordinate2DMake(deviceRuntimeDomain.lati, deviceRuntimeDomain.longi);
                        coordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
                    }
                    
                    if (deviceRuntimeDomain.lati == 0 && deviceRuntimeDomain.longi == 0) {
                        NSString * time = [NSDate tl_locationTimeParase:deviceRuntimeDomain.bs_loc_time];
                        positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", time];
                        positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntimeDomain.bs_loc_desc];
                        positionDomain.desc = deviceRuntimeDomain.bs_loc_desc;
                        positionDomain.time = time;
                        positionDomain.coordinate = coordinate;
                    }else
                    {
                        NSString * time = [NSDate tl_locationTimeParase:deviceRuntimeDomain.loc_time];
                        positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", time];
                        positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntimeDomain.loc_desc];
                        positionDomain.desc = deviceRuntimeDomain.loc_desc;
                        positionDomain.time = time;
                        positionDomain.coordinate = coordinate;
                    }
                    
                    positionDomain.devid =[NSString stringWithFormat:@"%ld", deviceRuntimeDomain.device_id];
                    positionDomain.index = index;
                    
                    G100DeviceDomain *domain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid
                                                                                            bikeid:self.bikeid
                                                                                             devid:positionDomain.devid];
                    
                    // 如果用户设置显示这个设备的位置信息 则添加进去
                    if (domain.location_display) {
                        [positionsArray addObject:positionDomain];
                    }
                    
                    if ([device isGPSDevice]) {
                        index++;
                    }
                }
                
                [self.devMapView setPositionsArray:positionsArray.copy];
                hasDeviceLocation = YES;
                
                break;
            }
        }
        
        if (!hasDeviceLocation) {
            [self.devMapView setPositionsArray:nil];
        }
    }
}

#pragma mark - G100CardDevMapViewTapDelegate
- (void)viewTapToPushCardDevMapDetailWithView:(UIView *)touchedView{
    if (![UserAccount sharedInfo].appfunction.biketrace.enable && IsLogin()) {
        return;
    };
    if ([touchedView isKindOfClass:[G100DevMapView class]]) {
        // 实时追踪
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:self.userid
                                                                                                     bikeid:self.bikeid
                                                                                                      devid:self.devid];
        if ([CURRENTVIEWCONTROLLER isKindOfClass:[viewController class]]) {
            return;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - G100AddCarDelegate
- (void)buttonClickedToAddCar:(UIButton *)button {
    if (button.tag == 200) {
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForScanCode:self.userid
                                                                     bindMode:1
                                                                    operation:0
                                                                 loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (viewController && loginSuccess) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
    }else {
        G100MallViewController *mallVC = [G100MallViewController loadXibViewControllerWithType:QWSMallTypeOther];
        mallVC.userid = self.userid;
        mallVC.bikeid = self.bikeid;
        mallVC.webTitle = @"骑卫士智能定位器";
        mallVC.pageUrl = @"https://www.qiweishi.com/shop/buydevice?from=appmain";
        [self.navigationController pushViewController:mallVC animated:YES];
    }
}

- (void)viewTouchedToPushWithView:(UIView *)touchedView {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForScanCode:self.userid
                                                                 bindMode:1
                                                                operation:0
                                                             loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册观察者
    _dataHandler = [[G100DevDataHandler alloc] initWithUserid:self.userid bikeid:self.bikeid];
    _dataHandler.delegate = self;
    
    [self configGPSCardView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.devMapView mdv_viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.devMapView mdv_viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.devMapView mdv_viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.devMapView mdv_viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 出现/消失
- (void)mdv_viewWillAppear:(BOOL)animated {
    [super mdv_viewWillAppear:animated];
    
    [self.devMapView mdv_viewWillAppear:animated];
}
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
    [self.devMapView mdv_viewDidAppear:animated];
}
- (void)mdv_viewWillDisappear:(BOOL)animated {
    [super mdv_viewWillDisappear:animated];
    
    [self.devMapView mdv_viewWillDisappear:animated];
}
- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
    [self.devMapView mdv_viewDidDisappear:animated];
}

@end
