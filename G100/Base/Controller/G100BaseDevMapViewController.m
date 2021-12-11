//
//  G100BaseDevMapViewController.m
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDevMapViewController.h"

#define kMapEdgeInset UIEdgeInsetsMake(80, 20, 40, 20)

@interface G100BaseDevMapViewController () <EBOfflineMapServiceDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL hasLoadLocationServiceUnknownNotice;
@property (strong, nonatomic) G100BikesRuntimeDomain *bikesRuntimeDomain;
@property (nonatomic, copy) NSString *adcode;

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

@end

@implementation G100BaseDevMapViewController

-(void)dealloc {
    DLog(@"地图Base已释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNRemoteLoginMsg object:nil];
    
    _ebservice.delegate = nil;
}

#pragma mark - Lazy Load
- (EBOfflineMapService *)ebservice {
    if (!_ebservice) {
        _ebservice = [[EBOfflineMapService alloc] init];
        _ebservice.delegate = self;
    }
    return _ebservice;
}

#pragma mark - 右上角按钮操作
- (void)tl_devLocatoinMapRightBarButtonClick:(id)sender {
    
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

#pragma mark - 地图页面初始化
-(void)configMapMainView {
    // 缩放按钮
    self.scaleBg = [[UIImageView alloc]init];
    self.scaleBg.userInteractionEnabled = YES;
    self.scaleBg.image = [UIImage imageNamed:@"ic_location_suofang_bg"];
    [self.view addSubview:self.scaleBg];
    
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
    
    // 锁定button
    self.suodingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _suodingBtn.tag = 200;
    [_suodingBtn setImage:[UIImage imageNamed:@"ic_location_jiechu_button"] forState:UIControlStateNormal];
    [_suodingBtn setImage:[UIImage imageNamed:@"ic_location_shangsuo_button"] forState:UIControlStateSelected];
    [_suodingBtn addTarget:self action:@selector(suodingMyCar:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_suodingBtn];
    
    self.suodingStatus = [[UILabel alloc]init];
    _suodingStatus.userInteractionEnabled = NO;
    _suodingStatus.font = [UIFont systemFontOfSize:14];
    _suodingStatus.backgroundColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:0.8];
    _suodingStatus.layer.borderWidth = 0.6f;
    _suodingStatus.layer.masksToBounds = YES;
    _suodingStatus.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _suodingStatus.layer.cornerRadius = 10.0f;
    _suodingStatus.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_suodingStatus];
    
    // 默认状态
    _suodingBtn.selected = YES;
    _suodingStatus.text = @"远程断电";
    
    /** 判断remotepower隐藏加解锁按钮以及状态toast
    if (self.deviceDomain.remotepower == 0) {
        _suodingBtn.hidden = YES;
        _suodingStatus.hidden = YES;
    }else if (self.deviceDomain.isMaster == 0) {
        _suodingBtn.hidden = YES;
        _suodingStatus.hidden = YES;
    }
     */
    
    _suodingBtn.hidden = YES;
    _suodingStatus.hidden = YES;
    _suodingBtn.enabled = NO;
    
    // 定位button
    self.locationDevBtn = [G100LocateButton buttonWithType:UIButtonTypeCustom];
    self.locationDevBtn.delegate = self;
    self.locationDevBtn.tag = 201;
    [self.locationDevBtn setImage:[UIImage imageNamed:@"ic_location_dev_button_normal"] forState:UIControlStateNormal];
    [self.locationDevBtn setImage:[UIImage imageNamed:@"ic_location_dev_button"] forState:UIControlStateSelected];
    [self.locationDevBtn addTarget:self action:@selector(locationPosition:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationDevBtn setExclusiveTouch:YES];
    [self.view addSubview:self.locationDevBtn];
    
    self.locationUserBtn = [G100LocateButton buttonWithType:UIButtonTypeCustom];
    self.locationUserBtn.delegate = self;
    self.locationUserBtn.tag = 202;
    [self.locationUserBtn setImage:[UIImage imageNamed:@"ic_location_user_button_normal"] forState:UIControlStateNormal];
    [self.locationUserBtn setImage:[UIImage imageNamed:@"ic_location_user_button"] forState:UIControlStateSelected];
    [self.locationUserBtn addTarget:self action:@selector(locationPosition:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationUserBtn setExclusiveTouch:YES];
    [self.view addSubview:self.locationUserBtn];
    
    // 底部view
    self.bottomView = [[UIView alloc]init];
    self.bottomView.userInteractionEnabled = NO;
    _bottomView.backgroundColor = [UIColor clearColor];
    //    self.bottomView .layer.masksToBounds = YES;
    //    self.bottomView .layer.borderWidth = 0.6f;
    //    self.bottomView .layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    self.bottomView .layer.cornerRadius = 6.0f;
    //    self.bottomView .backgroundColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:0.8];
    self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    //scaleLabel
    self.scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 60, 21)];
    _scaleLabel.textAlignment = NSTextAlignmentCenter;
    _scaleLabel.adjustsFontSizeToFitWidth = YES;
    
    _scaleLabel.text = @"--米";
    [self.bottomView addSubview:_scaleLabel];
    
    // 比例尺
    self.rulerView = [[UIImageView alloc]initWithFrame:CGRectMake(10, _scaleLabel.v_bottom, 60, 8)];
    self.rulerView.image = [UIImage imageNamed:@"ic_location_scale_ruler"];
    [self.bottomView addSubview:self.rulerView];
    
    // 我距离车label
    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bottomView.v_width - 150, 0, 120, 40)];
    _distanceLabel.userInteractionEnabled = YES;
    _distanceLabel.textColor = [UIColor darkGrayColor];
    _distanceLabel.textAlignment = NSTextAlignmentRight;
    _distanceLabel.text = @"我与车的直线距离为--米";
    [self adjustDistanceLabel];
    
    self.userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_distanceLabel.v_left - 15, 10, 16, 20)];
    self.userImageView.image = [UIImage imageNamed:@"ic_location_user_distance"];
    
    //    [self.bottomView addSubview:self.userImageView];
    //    [self.bottomView addSubview:_distanceLabel];
    [self.view addSubview:self.bottomView];
    
    [self.scaleBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        self.scaleBgViewTop = make.top.equalTo(self.navigationBarView.mas_bottom).with.offset(@60);
        make.width.equalTo(@45);
        make.height.equalTo(@90);
    }];
    
    [bigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.width.and.height.equalTo(@45);
    }];
    
    [smallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.equalTo(@0);
        make.width.and.height.equalTo(@45);
    }];
    
    [self.suodingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(60, 60));
        make.left.equalTo(@30);
        make.bottom.equalTo(self.suodingStatus.mas_top).with.offset(@-10);
    }];
    
    [self.suodingStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(80, 30));
        make.left.equalTo(@20);
        make.bottom.equalTo(self.bottomView.mas_top).with.offset(@-10);
    }];
    
    [self.locationDevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.size.equalTo(CGSizeMake(0, 0));
        make.bottom.equalTo(self.locationUserBtn.mas_top).with.offset(@-10);
    }];
    
    [self.locationUserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.size.equalTo(CGSizeMake(0, 0));
        make.bottom.equalTo(self.bottomView.mas_top).with.offset(@-10);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-20);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@40);
    }];
    
    self.scaleBgBiew = self.scaleBg;
    self.suodingBtn.hidden = YES;
    self.suodingStatus.hidden = YES;
}

#pragma mark - 自定义操作方法
-(NSString *)scaleConverttoRule:(CGFloat)distance {
    NSString * str = nil;
    static NSInteger SCALE[] = {5, 10, 25, 50, 100, 200, 500, 1000, 2000,
        5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000,
        2000000, 5000000, 10000000};
    NSInteger d = (NSInteger)distance;
    NSInteger zoom = (NSInteger)[self.mapView zoomLevel];
    
    d = SCALE[19-zoom];
    
    if (d == 0) {
        return @"--米";
    }
    
    if (d / 1000) {
        str = [NSString stringWithFormat:@"%ld公里", (long)(long)d / 1000];
    }else {
        str = [NSString stringWithFormat:@"%ld米", (long)(long)d];
    }
    
    return str;
}

-(void)suodingMyCar:(UIButton *)button {
    
}

-(void)adjustDistanceLabel {
    _distanceLabel.adjustsFontSizeToFitWidth = NO;
    [_distanceLabel sizeToFit];
    
    if (_distanceLabel.v_width >= _bottomView.v_width - 20 - 100) {
        _distanceLabel.v_width = _bottomView.v_width - 10 - 100;
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
    }
    _distanceLabel.v_left = _bottomView.v_width - _distanceLabel.v_width - 10;
    
    _distanceLabel.v_centerY = _bottomView.v_height / 2.0f;
    _userImageView.v_left = _distanceLabel.v_left - 16;
}

-(void)scaleMap:(UIButton *)button {
    if (button.tag == 100) {
        [self zoomIn];
    }else {
        [self zoomOut];
    }
}

-(void)distanceFromDevtoUser {
    //1.将两个经纬度点转成投影点
    MAMapPoint point1 = MAMapPointForCoordinate(_devLocation);
    MAMapPoint point2 = MAMapPointForCoordinate(_currentUserLocaiton);
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    
    NSMutableString * result = [[NSMutableString alloc]init];
    if (distance <= 1000) {
        [result appendString:[NSString stringWithFormat:@"%.1lf米", distance]];
    }else if (distance >= 1000) {
        [result appendString:[NSString stringWithFormat:@"%.1lf公里", distance / 1000]];
    }
    
    if ((_devLocation.latitude == 0 && _devLocation.longitude == 0) || (_currentUserLocaiton.latitude == 0 && _currentUserLocaiton.longitude == 0)) {
        result = [NSMutableString stringWithFormat:@"--米"];
    }
    _distanceLabel.text = [NSString stringWithFormat:@"我与车的直线距离为%@", result];
    [self adjustDistanceLabel];
}

#pragma mark - 定位按钮事件
-(void)locationPosition:(UIButton *)button {
    switch (button.tag) {
        case 201:
        {
            _locationDevBtn.selected = YES;
            _locationUserBtn.selected = NO;
            [_locationDevBtn startAnimation];
            
            [self startAnimationWithButton:self.locationDevBtn];
            __weak G100BaseDevMapViewController * wself = self;
            [self getDevCarLocationWithShowHUD:YES manully:YES backBlock:^(CLLocationCoordinate2D coordinate, BOOL success){
                if (!success) {
                    return;
                }
                
                [wself locationInCoordinate:coordinate];
                
                [wself showAnnotationDetailWithAnnotation:wself.devAnnotation];
                if (wself.userLocation.location.coordinate.latitude != 0) {
                    [wself stopAnimationWithButton:wself.locationUserBtn];
                    [wself distanceFromDevtoUser];
                    
                    // 判断是寻车还是追踪
                    if (wself.isSearchDev) {
                        
                    }else {
                        [wself startMakePolyline];
                    }
                }
            }];
        }
            break;
        case 202:
        {
            [self showHint:@"正在定位"];
            _locationDevBtn.selected = NO;
            _locationUserBtn.selected = YES;
            
            [self startAnimationWithButton:self.locationUserBtn];
            if (_currentUserLocaiton.latitude == 0 && _currentUserLocaiton.longitude == 0) {
                NSLog(@"G100 实时追踪- 中心位置(0, 0)");
            }else {
                [self locationInCoordinate:_currentUserLocaiton];
                if (!self.userLocationAnnotationHidden) {
                    [self.mapView addAnnotation:self.userAnnotation];
                }
                [self showAnnotationDetailWithAnnotation:self.userAnnotation];
            }
            [self.mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
            
            double delayInSeconds = 6.0f;
            __weak G100BaseDevMapViewController * wself = self;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [wself stopAnimationWithButton:self.locationUserBtn];
            });
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - 获取车辆当前位置
-(void)getDevCarLocationWithShowHUD:(BOOL)showHUD manully:(BOOL)manully backBlock:(void (^)(CLLocationCoordinate2D coordinate, BOOL success))backBlock {
    
    if (kNetworkNotReachability) {
        if (showHUD) {
            [self showHint:kError_Network_NotReachable];
        }
        
        if (backBlock) {
            backBlock(CLLocationCoordinate2DMake(0, 0), NO);
        }
        
        return;
    }
    
    __weak G100BaseDevMapViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces) {
        if (showHUD) {
            [wself hideHud];
        }
        if (requestSucces) {
            G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
            _bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc]initWithDictionary:response.data];
            G100DeviceRuntimeDomain *deviceRuntime;
            for (G100BikeRuntimeDomain *runtime in _bikesRuntimeDomain.runtime) {
                for (NSDictionary *dict in runtime.device_runtimes) {
                    G100DeviceRuntimeDomain *devRuntimeDomain = [[G100DeviceRuntimeDomain alloc] initWithDictionary:dict];
                    if (bikeDomain.mainDevice.device_id == devRuntimeDomain.device_id) {
                        deviceRuntime = devRuntimeDomain;
                        break;
                    }
                }
            }
            PositionDomain * positionDomain = [[PositionDomain alloc]init];
            positionDomain.name = bikeDomain.name;
            positionDomain.gpssvs = deviceRuntime.gps_level;
            positionDomain.bssignal = deviceRuntime.bs_level;
            positionDomain.devid =[NSString stringWithFormat:@"%ld", deviceRuntime.device_id];
            positionDomain.longi = [NSString stringWithFormat:@"%@", @(deviceRuntime.longi)];
            positionDomain.lati = [NSString stringWithFormat:@"%@", @(deviceRuntime.lati)];
            if (deviceRuntime.lati == 0 && deviceRuntime.longi == 0) {
                NSString * time = [self locationTimeParase:deviceRuntime.bs_loc_time];
                positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", time];
                positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntime.bs_loc_desc];
                positionDomain.desc = deviceRuntime.bs_loc_desc;
                positionDomain.time = time;
            }else
            {
                NSString * time = [self locationTimeParase:deviceRuntime.loc_time];
                positionDomain.topTitle = [NSString stringWithFormat:@"最后定位时间：%@", time];
                positionDomain.bottomContent = [NSString stringWithFormat:@"位置：%@", deviceRuntime.loc_desc];
                positionDomain.desc = deviceRuntime.loc_desc;
                positionDomain.time = time;
            };
            
            CLLocationCoordinate2D coordinate;
            if (deviceRuntime.lati == 0 && deviceRuntime.longi == 0) {
                coordinate = CLLocationCoordinate2DMake(deviceRuntime.bs_lati, deviceRuntime.bs_longi);
            }else {
                coordinate = CLLocationCoordinate2DMake(deviceRuntime.lati, deviceRuntime.longi);
                coordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
            }
            
            if (coordinate.latitude == 0 && coordinate.longitude == 0) {
                if (manully) {
                    [self showHint:@"没有找到设备"];
                }
            } else {
                positionDomain.coordinate = coordinate;
                wself.devAnnotation.positionDomain = positionDomain;
                wself.devAnnotation.coordinate = coordinate;
                [wself.mapView addAnnotation:wself.devAnnotation];
            }
            
            if (backBlock) {
                backBlock(coordinate, YES);
            }
        }else {
            if (manully) {
                [self showHint:@"没有找到设备"];
            }
        }
    };
    [[G100BikeApi sharedInstance] getBikeRuntimeWithBike_ids:@[self.bikeid] traceMode:1 callback:callback];
}

- (void)tl_hasGetDevInfo:(G100DevPositionDomain *)positionDomain {}
- (void)tl_hasGetUserLocationInfo:(MAUserLocation *)userLocation {}

-(void)locationInCoordinate:(CLLocationCoordinate2D)coordinate {
    if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        NSLog(@"G100 实时追踪- 中心位置(0, 0)");
    }else {
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    }
}
-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [super mapView:mapView regionDidChangeAnimated:animated];
    
    //通过getDistance函数得出两点间的真实距离
    CLLocationCoordinate2D coordinate1 = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D coordinate2 = [self.mapView convertPoint:CGPointMake(0, 60) toCoordinateFromView:self.mapView];
    
    //1.将两个经纬度点转成投影点
    MAMapPoint point1 = MAMapPointForCoordinate(coordinate1);
    MAMapPoint point2 = MAMapPointForCoordinate(coordinate2);
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    
    _scaleLabel.text = [self scaleConverttoRule:distance];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 当touch point是在_btn上，则hitTest返回_btn
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    CGPoint btnPointInA = [self.mapView convertPoint:point fromView:self.view];
    if ([self.mapView pointInside:btnPointInA withEvent:event]) {
        if (_locationDevBtn.selected == YES) {
            _locationDevBtn.selected = NO;
        }
        if (_locationUserBtn.selected == YES) {
            _locationUserBtn.selected = NO;
        }
    }
}

#pragma mark-  定位位置更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (!_userLocation) {
        _userLocation = [[MAUserLocation alloc]init];
    }
    
    _userLocation = userLocation;    //以下_mapView为BMKMapView对象
    _currentUserLocaiton = _userLocation.location.coordinate;
    [self stopAnimationWithButton:self.locationUserBtn];
    
    self.userAnnotation.coordinate = userLocation.location.coordinate;
    
    [self distanceFromDevtoUser];
    
    /** 车辆随动
    if (_locationDevBtn.selected == YES && !updatingLocation) {
        // 更改地图方向
        self.mapView.rotationDegree = userLocation.heading.trueHeading;
    }
     */
    
    if (updatingLocation) {
        // 查询当前位置信息
        [self onClickReverseAMMapGeocode:_userLocation.location.coordinate];
        
        if (!_isSearchDev) {
            if (!self.userLocationAnnotationHidden) {
                [self.mapView addAnnotation:self.userAnnotation];
            }
        }
    }
    
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
        }];
    }
    
    if (_isFirstLocate) {
        [self showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
        _isFirstLocate = NO;
    }
    
    [self tl_hasGetUserLocationInfo:userLocation];
    
    // 没有找到车辆
    if (_devLocation.latitude == _devLocation.longitude && [[NSString stringWithFormat:@"%lf", _devLocation.latitude] hasPrefix:@"0.00"]) {
        return;
    }
    
    // 判断是寻车还是追踪
    if (self.isSearchDev) {
        
    }else if (updatingLocation) {
        [self startMakePolyline];
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

// 获取数据成功后开始划线
-(void)startMakePolyline {
    /** 停止人与车辆中间的划线功能
    [self.mapView removeOverlays:self.mapView.overlays];
    CLLocationCoordinate2D commonPolylineCoords[2];
    commonPolylineCoords[0] = _currentUserLocaiton;
    commonPolylineCoords[1] = _devLocation;
    if (!self.userAnnotation || !self.devAnnotation) {
        return;
    }
    //构造折线对象
    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:2];
    //在地图上添加折线对象
    [self.mapView addOverlay:commonPolyline];
     */
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:(MAPolyline *)overlay];
        
        if (_isSearchDev) {
            polylineView.lineWidth = 6.0f;
            polylineView.strokeColor = MyGreenColor;
            
            return polylineView;
        }else {
            polylineView.lineWidth = 3.0f;
            polylineView.strokeColor = MyGreenColor;
        }
        
        return polylineView;
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
    
    if ((float)request.location.latitude != (float)self.currentUserLocaiton.latitude ||
        (float)request.location.longitude != (float)self.currentUserLocaiton.longitude) {
        return;
    }
    
    if (response) {
        
        MAGeoCodeResult *geo = [MAGeoCodeResult instance];
        
        NSString * adcode = response.regeocode.addressComponent.adcode;
        geo.result = response;
        
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
            }
            
            [EBOfflineMapTool sharedManager].hasShowedNotice = YES;
        }
        
        [self.mapView removeAnnotation:_userAnnotation];
        
        CLLocationAccuracy horizontalAccuracy = _userLocation.location.horizontalAccuracy;
        
        PositionDomain * positionDomain = [[PositionDomain alloc] init];
        positionDomain.topTitle = [NSString stringWithFormat:@"位置：%@", response.regeocode.formattedAddress];
        positionDomain.bottomContent = [NSString stringWithFormat:@"精度：约%.lf米", horizontalAccuracy];
        
        _userAnnotation.positionDomain = positionDomain;
        _userAnnotation.title = [NSString stringWithFormat:@"位置：%@", response.regeocode.formattedAddress];
        _userAnnotation.subtitle = [NSString stringWithFormat:@"精度：约%.lf米", horizontalAccuracy];
        
        self.userAnnotation.positionDomain = positionDomain;
        
        if (!self.userLocationAnnotationHidden) {
            [self.mapView addAnnotation:self.userAnnotation];
        }
        
        if (self.userAnnotation.selected) {
            [self showAnnotationDetailWithAnnotation:self.userAnnotation isCenter:NO];
        }
    }
}

-(void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    //通过getDistance函数得出两点间的真实距离
    CLLocationCoordinate2D coordinate1 = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D coordinate2 = [self.mapView convertPoint:CGPointMake(0, 60) toCoordinateFromView:self.mapView];
    
    //1.将两个经纬度点转成投影点
    MAMapPoint point1 = MAMapPointForCoordinate(coordinate1);
    MAMapPoint point2 = MAMapPointForCoordinate(coordinate2);
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    
    _scaleLabel.text = [self scaleConverttoRule:distance];
}
-(void)mapViewDidFinishLoading:(MAMapView *)mapView {
    //通过getDistance函数得出两点间的真实距离
    CLLocationCoordinate2D coordinate1 = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D coordinate2 = [self.mapView convertPoint:CGPointMake(0, 60) toCoordinateFromView:self.mapView];
    
    //1.将两个经纬度点转成投影点
    MAMapPoint point1 = MAMapPointForCoordinate(coordinate1);
    MAMapPoint point2 = MAMapPointForCoordinate(coordinate2);
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    
    _scaleLabel.text = [self scaleConverttoRule:distance];
}

#pragma mark - UIAlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2001) {
        if (buttonIndex == 1) {
            [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:self.adcode downloadType:EBOfflineItemDownloadTypeWWAN];
        } else if (buttonIndex == 2){
            [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:self.adcode downloadType:EBOfflineItemDownloadTypeWIFI];
        } else {
            
        }
    }
}

#pragma mark - 路径规划 提示用户寻车路线
-(void)searchBestRoadToSearchDev {
    if ((_currentUserLocaiton.latitude == 0 && _currentUserLocaiton.longitude == 0)
        || (_devLocation.latitude == 0 && _devLocation.longitude == 0)) {
        
        return;
    }
    
    if (!self.search) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    
    AMapGeoPoint * from = [AMapGeoPoint locationWithLatitude:_currentUserLocaiton.latitude longitude:_currentUserLocaiton.longitude];
    AMapGeoPoint * to = [AMapGeoPoint locationWithLatitude:_devLocation.latitude longitude:_devLocation.longitude];
    
    AMapWalkingRouteSearchRequest * request = [[AMapWalkingRouteSearchRequest alloc] init];
    request.origin = from;
    request.destination = to;
    
    [self.search AMapWalkingRouteSearch:request];
}


#pragma mark - 路径规划
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    DLog(@"error =%@", error);
}

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    [self hideHud];
    
    if (response.route == nil) {
        return;
    }
    
    NSArray* array = [NSArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:self.mapView.overlays];
    [self.mapView removeOverlays:array];
    
    AMapRoute * route = response.route;
    AMapPath * path = [route.paths safe_objectAtIndex:0];
    
    NSInteger size = path.steps.count;
    int planPointCounts = 0;
    
    // 添加起点标注
    [self.mapView addAnnotation:_userAnnotation];
    
    for (int i = 0; i < size; i++) {
        AMapStep * step = [path.steps safe_objectAtIndex:i];
        NSArray * polylines = [step.polyline componentsSeparatedByString:@";"]; //多个坐标点
        NSArray * point = [polylines[0] componentsSeparatedByString:@","];  // 第一个点
        
        CustomMAPointAnnotation *item = [[CustomMAPointAnnotation alloc] init];
        item.coordinate = CLLocationCoordinate2DMake([point[1] floatValue], [point[0] floatValue]);
        item.title = step.instruction;
        item.degree = [step.orientation intValue];
        item.type = 4;
        [self.mapView addAnnotation:item];
        
        planPointCounts += polylines.count;
    }
    
    // 添加终点标注
    [self.mapView addAnnotation:_devAnnotation];
    
    CLLocationCoordinate2D commonPolylineCoords[planPointCounts + 2];
    // 加上起点
    commonPolylineCoords[0] = _currentUserLocaiton;
    
    int i = 1;
    for (int j = 0; j < size; j++) {
        AMapStep* transitStep = [path.steps safe_objectAtIndex:j];
        NSArray * polylines = [transitStep.polyline componentsSeparatedByString:@";"]; //多个坐标点
        
        int k=0;
        for(k=0; k < polylines.count; k++) {
            NSArray * point = [polylines[k] componentsSeparatedByString:@","];  // 第一个点
            commonPolylineCoords[i] = CLLocationCoordinate2DMake([point[1] floatValue], [point[0] floatValue]);
            
            i++;
        }
    }
    // 加上终点
    commonPolylineCoords[i] = _devLocation;
    
    // 通过points构建BMKPolyline
    MAPolyline * polyLine =[MAPolyline polylineWithCoordinates:commonPolylineCoords count:planPointCounts + 2];
    if (nil != polyLine) {
        [self.mapView addOverlay:polyLine]; // 添加路线overlay
    }
    
    if (_isFirstGuihua) {
        [self zoomMapViewToFitAnnotations:self.mapView animated:YES];
        _isFirstGuihua = NO;
    }
}

- (MAAnnotationView*)getRouteAnnotationView:(MAMapView *)mapview viewForAnnotation:(CustomMAPointAnnotation *)routeAnnotation
{
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
                view.image = [UIImage imageNamed:@"ic_location_user_pin"];
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
                view.image = [UIImage imageNamed:@"ic_location_dev_pin"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
                view.userInteractionEnabled = YES;
            }
            view.backgroundColor = [UIColor clearColor];
            view.annotation = routeAnnotation;
            view.positionDomain = routeAnnotation.positionDomain;
            
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

-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[CustomMAPointAnnotation class]]) {
        return [self getRouteAnnotationView:mapView viewForAnnotation:(CustomMAPointAnnotation*)annotation];
    } else if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        if (self.userLocationViewHidden) {
            annotationView.image = [[UIImage alloc] init];
            return annotationView;
        } else {
            annotationView.image = [UIImage imageNamed:@"icon_user_position"];
            self.userLocationAnnotationView = annotationView;
            return annotationView;
        }
    }
    
    return nil;
}

#pragma mark - 选中某一个标注
-(void)showAnnotationDetailWithAnnotation:(CustomMAPointAnnotation *)annotation {
    [self showAnnotationDetailWithAnnotation:annotation isCenter:YES];
}

- (void)showAnnotationDetailWithAnnotation:(CustomMAPointAnnotation *)annotation isCenter:(BOOL)isCenter {
    annotation.isCenter = isCenter;
    [self.mapView selectAnnotation:annotation animated:YES];
}

#pragma mark - 选中标注时弹出paopaoView
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    MAPointAnnotation *anno = (MAPointAnnotation *)[view annotation];
    if (![anno isKindOfClass:[CustomMAPointAnnotation class]]) {
        return;
    }
    
    CustomMAPointAnnotation * annotation = (CustomMAPointAnnotation *)anno;
    
    // 如果在中央，则显示在中央
    if (annotation.isCenter) {
        [self locationInCoordinate:annotation.coordinate];
    }
    
    if ([view isKindOfClass:[CustomMAAnnotationView class]]) {
        CustomMAAnnotationView *cusView = (CustomMAAnnotationView *)view;
        
        if (annotation.type == 3) {
            __weak G100BaseDevMapViewController * wself = self;
            cusView.calloutView.navigationButtonBlock = ^(){
                // 调用第三方地图
                [wself callThirdMapForNavigationWithStartCoor:wself.currentUserLocaiton endCoor:wself.devLocation startName:wself.userAnnotation.positionDomain.desc endName:wself.devAnnotation.positionDomain.desc];
            };
        }
    }
    
    if (annotation == self.userAnnotation) {
        annotation.selected = YES;
        self.devAnnotation.selected = NO;
    }else if (annotation == self.devAnnotation) {
        annotation.selected = YES;
        self.userAnnotation.selected = NO;
    }
}

// 单击取消标注的选择
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CustomMAPointAnnotation * cusAnn = self.mapView.selectedAnnotations[0];
    if (cusAnn) {
        cusAnn.selected = NO;
        [self.mapView deselectAnnotation:self.mapView.selectedAnnotations[0] animated:YES];
    }
    
    self.devAnnotation.selected = NO;
    self.userAnnotation.selected = NO;
}

#pragma mark - 闪烁toast
-(void)startAnimationWithButton:(G100LocateButton *)button {
    if (button.selected) {
        
    }else {
        
    }
    
    [button startAnimation];
}

-(void)showMessage:(NSString *)hint button:(G100LocateButton *)button {
    UILabel * hintLabel = [[UILabel alloc]initWithFrame:button.bounds];
    hintLabel.text = hint;
    hintLabel.textColor = MyAlphaColor;
}

-(void)stopAnimationWithButton:(G100LocateButton *)button {
    [button stopAnimation];
}

#pragma mark - Public Method
- (void)tl_startReloadMapData {
    self.isFirstLocate = YES;
    self.isFirsGetInfo = YES;
    self.isFirstGuihua = YES;
    
    __weak typeof(self) wself = self;
    [self getDevCarLocationWithShowHUD:NO manully:YES backBlock:^(CLLocationCoordinate2D coordinate, BOOL success) {
        [wself.locationTimer setFireDate:[NSDate distantPast]];
        
        if (!success) {
            return;
        }
        
        // 判断是寻车还是追踪
        if (wself.isSearchDev) {
            [wself searchBestRoadToSearchDev];
        }else {
            [wself startMakePolyline];
        }
        
        [wself distanceFromDevtoUser];
        
        if (wself.isFirsGetInfo) {
            [wself showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
            wself.isFirsGetInfo = NO;
        }
    }];
    
}

#pragma mark - 通知监听动作
-(void)currentAMapLocationBecomeActive {
    if (![UserManager shareManager].remoteLogin && !_locationTimer/* && !_isSearchDev*/) {
        // 5秒更新一次位置信息
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [self.locationTimer setFireDate:[NSDate distantPast]];
    }
    
    if (_locationDevBtn.animating) {
        [self startAnimationWithButton:_locationDevBtn];
    }
    
    if (_locationUserBtn.animating) {
        [self startAnimationWithButton:_locationUserBtn];
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.userLocationServiceEnabled) {
            [self startLocationService];
        }
    }
    
    [self tl_startReloadMapData];
}

#pragma mark - 定时器操作
-(void)timerAction {
    [self getDevCarLocationWithShowHUD:NO manully:NO backBlock:^(CLLocationCoordinate2D coordinate, BOOL success){
        if (!success) {
            return;
        }
    }];
}
-(void)closeTimer {
    if (_locationTimer) {
        [_locationTimer invalidate];
        _locationTimer = nil;
    }
}

#pragma mark - 自定义导航栏
- (void)setupNavigationBarView {
    [self setNavigationTitle:@"实时追踪"];
    
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rightButton.frame = CGRectMake(0, 0, 100, 30);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitle:@"我要寻车" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationBarView addSubview:rightButton];
    
    [self setRightNavgationButton:rightButton];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加进入后台的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTimer) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAMapLocationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTimer) name:kGNRemoteLoginMsg object:nil];
    
    self.deviceDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    
    if (_isSearchDev) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
        self.isFirstGuihua = YES;
    }else {
        
    }
    
    self.userAnnotation = [[CustomMAPointAnnotation alloc]init];
    _userAnnotation.type = 2;
    self.devAnnotation = [[CustomMAPointAnnotation alloc]init];
    _devAnnotation.type = 3;
    
    self.isFirstLocate = YES;
    self.isFirsGetInfo = YES;
    
    [self configMapMainView];
    
    // 5秒更新一次位置信息
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [self.locationTimer setFireDate:[NSDate distantFuture]];
    
    __weak G100BaseDevMapViewController * wself = self;
    [self getDevCarLocationWithShowHUD:YES manully:YES backBlock:^(CLLocationCoordinate2D coordinate, BOOL success){
        
        [wself.locationTimer setFireDate:[NSDate distantPast]];
        
        if (!success) {
            return;
        }
        
        if (wself.userLocation.location.coordinate.latitude != 0) {
            // 判断是寻车还是追踪
            if (wself.isSearchDev) {
                [wself searchBestRoadToSearchDev];
            }else {
                [wself startMakePolyline];
            }
            
            [wself distanceFromDevtoUser];
            
            if (wself.isFirsGetInfo) {
                [wself showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
                wself.isFirsGetInfo = NO;
            }
        }else {
            [wself locationInCoordinate:coordinate];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
        
    if (self.userLocationServiceEnabled) {
        [self startLocationService];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasAppear) {
        //通过getDistance函数得出两点间的真实距离
        CLLocationCoordinate2D coordinate1 = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
        CLLocationCoordinate2D coordinate2 = [self.mapView convertPoint:CGPointMake(0, 60) toCoordinateFromView:self.mapView];
        
        //1.将两个经纬度点转成投影点
        MAMapPoint point1 = MAMapPointForCoordinate(coordinate1);
        MAMapPoint point2 = MAMapPointForCoordinate(coordinate2);
        //2.计算距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        
        _scaleLabel.text = [self scaleConverttoRule:distance];
    }
    self.hasAppear = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self stopLocationService];
    
    [self closeTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
