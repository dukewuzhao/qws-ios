//
//  G100HomeLocViewController.m
//  G100
//
//  Created by sunjingjing on 2017/7/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100HomeLocViewController.h"
#import "G100UserApi.h"
#import "G100PinView.h"
@interface G100HomeLocViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bgButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageiew;
@property (weak, nonatomic) IBOutlet UILabel *currentCity;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) G100PinView *homePinView;

@property (assign, nonatomic) CLLocationCoordinate2D userLoction;
@property (nonatomic, assign) BOOL hasLoadLocationServiceUnknownNotice;
@property (assign, nonatomic) BOOL manuaLoc;
@property (assign, nonatomic) CLLocationCoordinate2D selectLoc;
@property (strong, nonatomic) NSString *selectAddress;
@property (assign, nonatomic) BOOL isloc;
@property (assign, nonatomic) BOOL isAppear;

@end

@implementation G100HomeLocViewController

#pragma mark - 懒加载
- (G100PinView *)homePinView {
    if (!_homePinView) {
        _homePinView = [[G100PinView alloc] init];
        _homePinView.image = @"ic_dev_home";
        _homePinView.userInteractionEnabled = NO;        
    }
    return _homePinView;
}

#pragma mark - setupView
- (void)setupView {
    [self.view addSubview:self.homePinView];
    [self.homePinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).offset(@-40);
    }];
}
- (IBAction)beginLocate:(id)sender {
    self.manuaLoc = YES;
    
    [self startLocationService];
}
- (IBAction)sureSelect:(id)sender {
    if (self.selectLoc.latitude != 0 && self.selectLoc.longitude != 0) {
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:@{@"homelon" : [NSNumber numberWithFloat:self.selectLoc.longitude],
                              @"homelat" : [NSNumber numberWithFloat:self.selectLoc.latitude],
                              @"homeaddr" : EMPTY_IF_NIL(self.selectAddress),
                              }
                     forKey:@"homeinfo"];
        
        [[G100UserApi sharedInstance] sv_addUserHomeWithUserid:self.userid longi:self.selectLoc.longitude lati:self.selectLoc.latitude address:self.selectAddress callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (requestSuccess) {
                if (weakSelf.setHomeBloc) {
                    weakSelf.setHomeBloc(weakSelf.selectAddress, self.selectLoc);
                }
                
                [[G100InfoHelper shareInstance] updateMyUserInfoWithUserid:weakSelf.userid userInfo:userInfo];
                [weakSelf actionClickNavigationBarLeftButton];
            }else{
                if (response) {
                    [weakSelf showHint:response.errDesc];
                }
            }
        }];
    }else{
        [self showHint:@"请先确认已选好位置"];
    }
}

#pragma mark - 位置转换
- (CLLocationCoordinate2D)converttoMapLocationWithLostPinViewFrame:(CGRect)rect {
    CGPoint pinPoint = CGPointMake(rect.origin.x + rect.size.width/2.0, rect.origin.y + rect.size.height);
    CLLocationCoordinate2D tmpLocation = [self.mapView convertPoint:pinPoint toCoordinateFromView:self.contentView];
    DLog(@"\n\n当前选择位置经纬度 \n(latitude: %@, longitude: %@)\n\n", @(tmpLocation.latitude), @(tmpLocation.longitude));
    return tmpLocation;
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
//    CGRect newFrame = self.homePinView.frame;
//    newFrame.origin.y -= 10;
//    _homePinView.frame = newFrame;
}
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
//    CGRect newFrame = _homePinView.frame;
//    newFrame.origin.y += 10;
//    _homePinView.frame = newFrame;
    if (!_isAppear) {
        _isAppear = YES;
        return;
    }
    
    self.selectLoc = [self converttoMapLocationWithLostPinViewFrame:_homePinView.frame];
    [self onClickReverseAMMapGeocode:self.selectLoc];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    self.userLoction = userLocation.location.coordinate;
    if (updatingLocation) {
        // 查询当前位置信息
        self.mapView.centerCoordinate = self.userLoction;
        if (!_isloc) {
            _isloc = YES;
            self.selectLoc = self.userLoction;
            self.mapView.centerCoordinate = self.userLoction;
            [self onClickReverseAMMapGeocode:self.selectLoc];
        }else {
            if (self.manuaLoc) {
                self.mapView.centerCoordinate = self.userLoction;
                self.manuaLoc = NO;
            }
        }
    }
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"%@", error); // kCLErrorDomain error 0.
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

- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    [self removeAnnotions];
    MAPointAnnotation *pointAnn = [[MAPointAnnotation alloc] init];
    pointAnn.coordinate = coordinate;
    [self.mapView addAnnotation:pointAnn];
    [self onClickReverseAMMapGeocode:coordinate];
    self.selectLoc = coordinate;
}

-(void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate {
   // [self addAnnotationWithCoordinate:coordinate];
}
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *selectPointStyleReuseIndetifier = @"selectPonitStyleReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:selectPointStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:selectPointStyleReuseIndetifier];
            annotationView.draggable = NO;
            annotationView.canShowCallout = NO;
            annotationView.pinColor = MAPinAnnotationColorPurple;
            annotationView.animatesDrop = YES;
            annotationView.centerOffset = CGPointMake(0, -annotationView.v_height);
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

- (void)removeAnnotions {
    for (MAPointAnnotation *pointAnn in self.mapView.annotations) {
        if (![pointAnn isKindOfClass:[MAUserLocation class]]) {
            [self.mapView removeAnnotation:pointAnn];
        }
    }
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
    if (response) {
        if (!response.regeocode.addressComponent.city.length) {
            return;
        }
        self.currentCity.text = [NSString stringWithFormat:@"%@%@",response.regeocode.addressComponent.city,response.regeocode.addressComponent.district];
        self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@",response.regeocode.addressComponent.township,response.regeocode.addressComponent.streetNumber.street,response.regeocode.addressComponent.streetNumber.number
                                  ];
        NSLog(@"%@",response.regeocode.formattedAddress);
        self.selectAddress = [NSString stringWithFormat:@"%@&%@", self.currentCity.text, self.addressLabel.text];
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"选择家的地址"];
    self.bgButton.layer.cornerRadius = 6.0;
    self.sureButton.layer.cornerRadius = 6.0;
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(@0);
        make.left.equalTo(self.view.mas_left).offset(@0);
        make.width.equalTo(self.view.mas_width).offset(@0);
    }];
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kNavigationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(@0);
        make.left.equalTo(self.view.mas_left).offset(@0);
        make.width.equalTo(self.view.mas_width).offset(@0);
    }];
    
    [self setupView];
    
    if (self.homeInfo.homelat != 0 && self.homeInfo.homelon != 0) {
        self.selectLoc = CLLocationCoordinate2DMake(self.homeInfo.homelat, self.homeInfo.homelon);
        self.mapView.centerCoordinate = self.selectLoc;
        self.currentCity.text = [[self.homeInfo.homeaddr componentsSeparatedByString:@"&"] safe_objectAtIndex:0];
        self.addressLabel.text = [[self.homeInfo.homeaddr componentsSeparatedByString:@"&"] lastObject];
        self.selectAddress = [NSString stringWithFormat:@"%@&%@",self.currentCity.text,self.addressLabel.text];
        
        [self zoomOut];
        //[self addAnnotationWithCoordinate:self.selectLoc];
    }else {
        [self startLocationService];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
