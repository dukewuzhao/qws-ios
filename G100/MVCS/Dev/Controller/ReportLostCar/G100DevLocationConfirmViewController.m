//
//  G100DevLocationConfirmViewController.m
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevLocationConfirmViewController.h"
#import "G100StrokeLabel.h"
#import "BSWSwitchView.h"
#import "G100PinView.h"

#define kLostPinUpDistance  10

static NSString * const kFindCarWarmHint = @"请参考历史行车路线\n拖移地图确定丢车的地点";

@interface G100DevLocationConfirmViewController () <BSWSwitchViewDelegate>

@property (nonatomic, strong) G100StrokeLabel * hintStrokeLabel;
@property (nonatomic, strong) BSWSwitchView * dateSwitchView;
@property (nonatomic, strong) G100PinView * lostPinView;

@property (nonatomic, copy) AMapReGeocode *locationReGeocode;

@property (nonatomic, assign) BOOL hasTakeLocation;
@property (nonatomic, assign) BOOL hasUserLocation;
@property (nonatomic, assign) BOOL hasDevLocation;

@property (nonatomic, assign) BOOL isLocationSuccess; //!< 定位是否成功

@property (nonatomic, copy) UIButton * rightButton;

@property (nonatomic, assign) BOOL didAppear;

@end

@implementation G100DevLocationConfirmViewController

#pragma mark - 用户移动丢车位置后的回调
- (CLLocationCoordinate2D)converttoMapLocationWithLostPinViewFrame:(CGRect)rect {
    // 丢车的pinView 宽高是 40x40
    CGPoint pinPoint = CGPointMake(rect.origin.x + rect.size.width/2.0, rect.origin.y + rect.size.height);
    CLLocationCoordinate2D tmpLocation = [self.mapView convertPoint:pinPoint toCoordinateFromView:self.contentView];
    DLog(@"\n\n当前选择位置经纬度 \n(latitude: %@, longitude: %@)\n\n", @(tmpLocation.latitude), @(tmpLocation.longitude));
    return tmpLocation;
}

#pragma mark - 请求用户选择坐标的详情信息
- (void)requestDetailsReGeocodeWithLocation:(CLLocationCoordinate2D)locationCoordinate {
    self.rightButton.enabled = NO;
    
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:locationCoordinate.latitude
                                                longitude:locationCoordinate.longitude];
    self.search.delegate = self;
    request.requireExtension = NO;
    [self.search AMapReGoecodeSearch:request];
    
    [self.lostPinView setSelected:YES animated:YES];
    [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
}
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    [super onReGeocodeSearchDone:request response:response];
    
    if ((float)request.location.latitude != (float)self.locationCoordinate.latitude ||
        (float)request.location.longitude != (float)self.locationCoordinate.longitude) {
        return;
    }
    
    // 若果不是当前页面的请求 直接return 由父类操作
    if (response) {
        self.locationReGeocode = response.regeocode;
        // 更新丢失地点的UI界面
        if (response.regeocode.formattedAddress.length == 0) {
            [self.lostPinView setInfoWithTitle:@"获取位置失败" content:nil];
            return;
        }
        NSString *title = [NSString stringWithFormat:@"丢车位置：%@", response.regeocode.formattedAddress];
        [self.lostPinView setInfoWithTitle:title content:nil];
        self.rightButton.enabled = YES;
    }else {
        [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
        self.rightButton.enabled = NO;
    }
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    if (!self.didAppear) {
        return;
    }
    if (!wasUserAction) {
        return;
    }
    
    CGRect newFrame = _lostPinView.frame;
    newFrame.origin.y -= kLostPinUpDistance;
    _lostPinView.frame = newFrame;
}
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (!self.didAppear) {
        return;
    }
    if (!wasUserAction) {
        return;
    }
    
    CGRect newFrame = _lostPinView.frame;
    newFrame.origin.y += kLostPinUpDistance;
    _lostPinView.frame = newFrame;
    
    self.locationCoordinate = [self converttoMapLocationWithLostPinViewFrame:_lostPinView.frame];
    [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
    [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
    self.rightButton.enabled = NO;
}
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [super mapView:mapView didSingleTappedAtCoordinate:coordinate];
    
    [_lostPinView setSelected:NO animated:YES];
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    [super mapView:mapView didFailToLocateUserWithError:error];
    
    if (!_hasTakeLocation && !_hasUserLocation) {
        // 如果没有传来坐标点 则使用当前位置
        self.isLocationSuccess = NO;
        if (self.didAppear) {
            self.locationCoordinate = [self converttoMapLocationWithLostPinViewFrame:self.lostPinView.frame];
            [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
            [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
            [self.lostPinView setSelected:YES animated:YES];
            self.rightButton.enabled = NO;
        }
    }
    
    _hasUserLocation = YES;
}

#pragma mark - BSWSwitchViewDelegate
- (void)bswSwitchViewValueChanged:(BSWSwitchView *)switchView index:(NSInteger)index {
    DLog(@"%@", switchView.dataArray[index]);
}

#pragma mark - 导航栏右部按钮跳转
- (void)tl_devLocatoinMapRightBarButtonClick:(id)sender {
    if (_locatinCofirmFinished) {
        self.locatinCofirmFinished(self.locationCoordinate, self.locationReGeocode);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- override
- (void)tl_hasGetDevInfo:(G100DevPositionDomain *)positionDomain {}
- (void)tl_hasGetUserLocationInfo:(MAUserLocation *)userLocation {
    if (!_hasTakeLocation && !_hasUserLocation) {
        // 如果没有传来坐标点 则使用当前位置
        self.locationCoordinate = userLocation.coordinate;
        [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
        [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
        [self.lostPinView setSelected:YES animated:YES];
        
        [self locationInCoordinate:self.locationCoordinate animated:YES];
    }
    
    _isLocationSuccess = YES;
    _hasUserLocation = YES;
}

- (void)locationInCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        NSLog(@"G100 实时追踪- 中心位置(0, 0)");
    }else {
        [self.mapView setCenterCoordinate:coordinate animated:animated];
    }
}

#pragma mark - 懒加载
- (G100PinView *)lostPinView {
    if (!_lostPinView) {
        _lostPinView = [[G100PinView alloc] init];
    }
    return _lostPinView;
}

- (BSWSwitchView *)dateSwitchView {
    if (!_dateSwitchView) {
        _dateSwitchView = [BSWSwitchView switchView];
        _dateSwitchView.delegate = self;
        [_dateSwitchView setTitleLabelText:@"历史路径"];
        [_dateSwitchView setDataArray:@[ @"5天前", @"4天前", @"3天前", @"2天前", @"1天前", @"今天" ]];
    }
    return _dateSwitchView;
}

- (G100StrokeLabel *)hintStrokeLabel {
    if (!_hintStrokeLabel) {
        _hintStrokeLabel = [[G100StrokeLabel alloc] init];
        _hintStrokeLabel.font = [UIFont systemFontOfSize:13];
        _hintStrokeLabel.text = kFindCarWarmHint;
        _hintStrokeLabel.numberOfLines = 0;
        _hintStrokeLabel.textColor = [UIColor colorWithHexString:@"F32E2E"];
        _hintStrokeLabel.outlineColor = [UIColor colorWithHexString:@"FFFFFF"];
        _hintStrokeLabel.outlineWidth = 1.0f;
        _hintStrokeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hintStrokeLabel;
}

- (AMapReGeocode *)locationReGeocode {
    if (!_locationReGeocode) {
        _locationReGeocode = [[AMapReGeocode alloc] init];
    }
    return _locationReGeocode;
}

- (void)setupData {
    _hasUserLocation = NO;
    _hasDevLocation = NO;
    
    self.didAppear = NO;
    self.hasTakeLocation = NO;
}

- (void)setupView {
    [self.contentView addSubview:self.lostPinView];
    CGPoint newCenter = self.contentView.center;
    newCenter.y -= 80;
    self.lostPinView.center = newCenter;
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"请确认丢车地点"];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightButton.frame = CGRectMake(0, 0, 40, 30);
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(tl_devLocatoinMapRightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateDisabled];
    _rightButton.enabled = NO;
    [self setRightNavgationButton:_rightButton];
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    
    [self setupView];
    
    if (self.locationCoordinate.latitude == 0 &&
        self.locationCoordinate.longitude == 0) {
        return;
    }
    self.hasTakeLocation = YES;
    [self locationInCoordinate:self.locationCoordinate animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.didAppear) {
        if (!_hasTakeLocation) {
            // 如果没有设置位置 则等待定位更新
            if (!_isLocationSuccess) {
                self.locationCoordinate = [self converttoMapLocationWithLostPinViewFrame:self.lostPinView.frame];
                [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
                [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
                [self.lostPinView setSelected:YES animated:YES];
                self.rightButton.enabled = NO;
            }
        }else {
            // 如果
            [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
            [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
            [self.lostPinView setSelected:YES animated:YES];
            self.rightButton.enabled = NO;
            
            [self locationInCoordinate:self.locationCoordinate animated:NO];
        }
        
        self.didAppear = YES;
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
