//
//  G100DevLostFindResultViewController.m
//  G100
//
//  Created by yuhanle on 16/4/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevLostFindResultViewController.h"
#import "G100PinView.h"
#import "G100DevApi.h"
#import "G100UMSocialHelper.h"
#import "G100BikeApi.h"
#import "G100DevLostListDomain.h"

static NSString * const kFindCarWarmHint = @"您是否已与爱车团聚？";

#define kLostPinUpDistance  10

@interface G100DevLostFindResultViewController ()

@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) G100PinView *lostPinView;
@property (nonatomic, strong) UIView *bottomButtonView;

// 保存用户确认位置经纬度
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, strong) AMapReGeocode *locationReGeocode;

// 要分享的链接
@property (nonatomic, copy) NSString *httpUrl;

@property (nonatomic, strong) G100DevLostDomain *lostDomain;
@property (nonatomic, assign) NSInteger shareid;

@property (nonatomic, strong) UIButton *button0;

@property (nonatomic, assign) BOOL hasUserLocation;
@property (nonatomic, assign) BOOL isLocationSuccess; //!< 定位是否成功

@property (nonatomic, assign) BOOL didAppear;

@end

@implementation G100DevLostFindResultViewController

#pragma mark - 用户移动丢车位置后的回调
- (CLLocationCoordinate2D)converttoMapLocationWithLostPinViewFrame:(CGRect)rect {
    // 丢车的pinView 宽高是 40x40
    CGPoint pinPoint = CGPointMake(rect.origin.x + rect.size.width/2.0, rect.origin.y + rect.size.height);
    CLLocationCoordinate2D tmpLocation = [self.mapView convertPoint:pinPoint toCoordinateFromView:self.contentView];
    DLog(@"\n\n当前选择位置经纬度 \n(latitude: %@, longitude: %@)\n\n", @(tmpLocation.latitude), @(tmpLocation.longitude));
    return tmpLocation;
}

#pragma mark- override
- (void)tl_hasGetDevInfo:(G100DevPositionDomain *)positionDomain {}
- (void)tl_hasGetUserLocationInfo:(MAUserLocation *)userLocation {
    if (!_hasUserLocation) {
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
#pragma mark - 请求用户选择坐标的详情信息
- (void)requestDetailsReGeocodeWithLocation:(CLLocationCoordinate2D)locationCoordinate {
    _button0.enabled = NO;
    
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
        NSString *title = [NSString stringWithFormat:@"找回位置：%@", response.regeocode.formattedAddress];
        [self.lostPinView setInfoWithTitle:title content:nil];
        _button0.enabled = YES;
    }else {
        [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
        _button0.enabled = NO;
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
    _button0.enabled = NO;
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [super mapView:mapView didSingleTappedAtCoordinate:coordinate];
    
    [_lostPinView setSelected:NO animated:YES];
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    [super mapView:mapView didFailToLocateUserWithError:error];
    
    if (!_hasUserLocation) {
        // 如果没有传来坐标点 则使用当前位置
        self.isLocationSuccess = NO;
        if (self.didAppear) {
            self.locationCoordinate = [self converttoMapLocationWithLostPinViewFrame:self.lostPinView.frame];
            [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
            [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
            [self.lostPinView setSelected:YES animated:YES];
        }
    }
    
    _hasUserLocation = YES;
}

- (void)tl_bottomButtonClick:(UIButton *)button {
    __weak G100DevLostFindResultViewController *wself = self;
    [[G100BikeApi sharedInstance] endFindLostWithBikeid:self.bikeid lostid:self.lostid foundlongi:self.locationCoordinate.longitude foundlati:self.locationCoordinate.latitude foundlocdesc:self.locationReGeocode.formattedAddress callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:wself.userid bikeid:wself.bikeid complete:nil];
            [MyAlertView MyAlertWithTitle:nil message:@"恭喜您与爱车重聚！" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    // 取消
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        }else if (response.errDesc.length) {
            [wself showHint:response.errDesc];
        }
    }];
}

- (void)getShareContent:(BOOL)showHUD {
    if (kNetworkNotReachability) {
        return;
    }
    __weak G100DevLostFindResultViewController * wself = self;
    if (showHUD) [self showHudInView:self.contentView hint:@"请稍候"];
    [[G100BikeApi sharedInstance] getBikeLostRecordWithBikeid:self.bikeid lostid:@[[NSNumber numberWithInteger:self.lostid]] callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (showHUD) [wself hideHud];
        if (requestSuccess) {
            G100DevLostListDomain *lostListDomain = [[G100DevLostListDomain alloc]initWithDictionary:response.data];
            if (lostListDomain.lost.count>0) {
                self.lostDomain = [lostListDomain.lost firstObject];
                self.lostid = self.lostDomain.lostid;
                self.shareid = [self.lostDomain shareid];
                G100BikeFeatureDomain *featureDomain = [[G100InfoHelper shareInstance] findMyBikeFeatureWithUserid:wself.userid bikeid:wself.bikeid];
                [[G100UMSocialHelper shareInstance] loadShareWithShareid:[self.lostDomain shareid] shareUrl:self.lostDomain.shareurl sharePic:featureDomain.pictures.firstObject complete:nil];
            }
        }else{
            [self showHint:response.errDesc];
        }
    }];
}


#pragma mark - 懒加载
- (G100PinView *)lostPinView {
    if (!_lostPinView) {
        _lostPinView = [[G100PinView alloc] init];
        [_lostPinView setImage:@"ic_location_dev_pin"];
    }
    return _lostPinView;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = [UIFont boldSystemFontOfSize:20];
        _hintLabel.text = kFindCarWarmHint;
        _hintLabel.numberOfLines = 0;
        _hintLabel.textColor = [UIColor blackColor];
        _hintLabel.backgroundColor = [UIColor whiteColor];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hintLabel;
}
- (UIView *)bottomButtonView {
    if (!_bottomButtonView) {
        _bottomButtonView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomButtonView.backgroundColor = [UIColor whiteColor];
        
        _button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button0.titleLabel.font = [UIFont systemFontOfSize:18];
        [_button0 setTitle:@"找到了" forState:UIControlStateNormal];
        [_button0 setExclusiveTouch:YES];
        _button0.enabled = NO;
        UIEdgeInsets insets = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *normalImage    = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        UIImage *highlitedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        [_button0 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_button0 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_button0 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        [_bottomButtonView addSubview:_button0];
        
        [_button0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
            make.height.equalTo(@40);
            make.top.equalTo(@5);
        }];
    }
    return _bottomButtonView;
}

- (AMapReGeocode *)locationReGeocode {
    if (!_locationReGeocode) {
        _locationReGeocode = [[AMapReGeocode alloc] init];
    }
    return _locationReGeocode;
}

- (void)setupData {
    self.hasUserLocation = NO;
}

- (void)setupView {
    [self.contentView addSubview:self.hintLabel];
    [self.contentView addSubview:self.bottomButtonView];
    [self.contentView addSubview:self.lostPinView];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
        make.height.equalTo(@40);
    }];
    
    [self.bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(@0);
        make.height.equalTo(50+kBottomPadding);
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@40);
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(-50-kBottomPadding);
    }];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mapView.mas_bottom).equalTo(@-20);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@40);
    }];
    
    CGPoint newCenter = self.contentView.center;
    newCenter.y -= 80;
    self.lostPinView.center = newCenter;
    
    // 布局
    self.locationDevBtn.hidden = YES;
    self.locationUserBtn.hidden = YES;
    self.userAnnotation = nil;
    self.devAnnotation = nil;
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"寻车结果"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    
    [self setupView];
    
    // 获取分享的 id
    [self getShareContent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.didAppear) {
        // 等待定位更新
        // 如果没有设置位置 则等待定位更新
        if (!_isLocationSuccess) {
            self.locationCoordinate = [self converttoMapLocationWithLostPinViewFrame:self.lostPinView.frame];
            [self requestDetailsReGeocodeWithLocation:self.locationCoordinate];
            [self.lostPinView setInfoWithTitle:@"正在获取位置信息..." content:nil];
            [self.lostPinView setSelected:YES animated:YES];
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
