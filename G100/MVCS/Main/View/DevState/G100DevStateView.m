//
//  G100DevStateView.m
//  G100
//
//  Created by William on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevStateView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

#import "G100ClickEffectView.h"

@interface G100DevStateView () <MAMapViewDelegate, G100TapAnimationDelegate>

@property (strong, nonatomic) DevNormalStateView * normalView;

@property (strong, nonatomic) DevViceUserStateView * viceUserView;

@property (strong, nonatomic) MAPointAnnotation * userAnnotation;

@property (strong, nonatomic) MAPointAnnotation * devAnnotation;

@property (weak, nonatomic) IBOutlet UIView *mapBaseView;
@property (weak, nonatomic) IBOutlet UIView *functionBaseView;
@property (weak, nonatomic) IBOutlet UIView *stateBaseView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapBaseViewConstranitTrailing;

@property (weak, nonatomic) IBOutlet UIImageView *menuBackgroundImageView;
@property (weak, nonatomic) IBOutlet G100ClickEffectView *clickEffectView;

@property (strong, nonatomic) NSDate * lastDate;
@property (assign, nonatomic) CLLocationCoordinate2D devCoordinate;

/** 地图区域截图*/
@property (strong, nonatomic) UIImageView *mapScreenImageView;

@end

@implementation G100DevStateView

+ (instancetype)loadDevStateView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100DevStateView"
                                          owner:self
                                        options:nil] lastObject];
}

#pragma mark - lazy loading
- (MAPointAnnotation *)userAnnotation {
    if (!_userAnnotation) {
        _userAnnotation = [[MAPointAnnotation alloc]init];
    }
    return _userAnnotation;
}

- (MAPointAnnotation *)devAnnotation {
    if (!_devAnnotation) {
        _devAnnotation = [[MAPointAnnotation alloc]init];
    }
    return _devAnnotation;
}

- (DevNormalStateView *)normalView {
    if (!_normalView) {
        _normalView = [DevNormalStateView loadDevNormalStateView];
        __weak G100DevStateView * wself = self;
        _normalView.functionTap = ^(NSInteger index){
            if (wself.normalFunctionTapAction) {
                wself.normalFunctionTapAction(index);
            }
        };
    }
    return _normalView;
}

- (DevFindingStateView *)findingView {
    if (!_findingView) {
        _findingView = [DevFindingStateView loadDevFindingStateView];
        __weak G100DevStateView * wself = self;
        _findingView.functionTap = ^(NSInteger index, GPSType type){
            if (wself.findingFunctionTapAction) {
                wself.findingFunctionTapAction(index, type);
            }
            /*
            if (index == 1) {
                wself.powerStateType = arc4random()%3;
            }
             */
        };
    }
    return _findingView;
}

- (DevViceUserStateView *)viceUserView {
    if (!_viceUserView) {
        _viceUserView = [DevViceUserStateView loadDevViceUserStateView];
        __weak G100DevStateView * wself = self;
        _viceUserView.functionTap = ^(){
            if (wself.viceUserFunctionTapActiom) {
                wself.viceUserFunctionTapActiom();
            }
        };
    }
    return _viceUserView;
}

#pragma mark - setter
- (void)setPowerStateType:(PowerStateType)powerStateType {
    if (powerStateType == PowerStateTypeRecovered || powerStateType == PowerStateTypePowerOffing) {
        self.findingView.secondView.powerRemoteState = GPSPowerRemoteStateOff;
    }else {
        self.findingView.secondView.powerRemoteState = GPSPowerRemoteStateOn;
    }
    
    if (_powerStateType == PowerStateTypeRecovered && powerStateType == PowerStateTypeRecovered) {
        return;
    }
    
    _powerStateType = powerStateType;
    [self.powerStateImageView.layer removeAnimationForKey:@"psTrans"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.powerStateImageView.layer addAnimation:transition forKey:@"psTrans"];
    self.powerStateImageView.alpha = 1;
    switch (powerStateType) {
        case PowerStateTypeRecovering:
        {
            self.powerStateImageView.image = [UIImage imageNamed:@"ic_recovering"];
        }
            break;
        case PowerStateTypeRecovered:
        {
            self.powerStateImageView.image = [UIImage imageNamed:@"ic_recovered"];
            [UIView animateWithDuration:3.0f animations:^{
                self.powerStateImageView.alpha = 0;
            }];
        }
            break;
        case PowerStateTypePowerOffed:
        {
            self.powerStateImageView.image = [UIImage imageNamed:@"ic_poweroff"];
        }
            break;
        case PowerStateTypePowerOffing:
        {
            self.powerStateImageView.image = [UIImage imageNamed:@"ic_offing"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
    
    _powerStateType = -1;
    
    self.powerStateImageView.alpha = 0;
    
    [self.stateView addSubview:self.findingView];
    [self.findingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self.stateView addSubview:self.normalView];
    [self.normalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self.stateView addSubview:self.viceUserView];
    [self.viceUserView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.clickEffectView.delegate = self;
    [self showAnnotations:NO];
}

#pragma mark - setup view
- (void)setupView {
    self.needSingleCtrl = YES;
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    [self startLocationService];
    
    /*
    UITapGestureRecognizer * mapTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapTapAction:)];
    [self addGestureRecognizer:mapTap];
     */
}

- (void)configViewWithState:(DevStateType)type {
    _stateType = type;
    switch (type) {
        case DevStateTypeNormal:
        {
            self.menuBackgroundImageView.image = [UIImage imageNamed:@"ic_gps_green"];
            self.normalView.hidden = NO;
            self.findingView.hidden = YES;
            self.viceUserView.hidden = YES;
            self.findingStateImageView.hidden = YES;
            self.powerStateImageView.hidden = YES;
            self.clickEffectView.effect_enabled = YES;
        }
            break;
        case DevStateTypeFinding:
        {
            self.menuBackgroundImageView.image = [UIImage imageNamed:@"ic_gps_red"];
            self.normalView.hidden = YES;
            self.findingView.hidden = NO;
            self.viceUserView.hidden = YES;
            self.findingStateImageView.hidden = NO;
            self.powerStateImageView.hidden = NO;
            self.clickEffectView.effect_enabled = YES;
        }
            break;
        case DevStateTypeViceUser:
        {
            self.menuBackgroundImageView.image = [UIImage imageNamed:@"ic_gps_green_noline"];
            self.normalView.hidden = YES;
            self.findingView.hidden = YES;
            self.viceUserView.hidden = NO;
            self.findingStateImageView.hidden = YES;
            self.powerStateImageView.hidden = YES;
            self.clickEffectView.effect_enabled = NO;
        }
            break;
        default:
        {
            self.menuBackgroundImageView.image = [UIImage imageNamed:@"ic_gps_green"];
            self.normalView.hidden = NO;
            self.findingView.hidden = YES;
            self.viceUserView.hidden = YES;
            self.findingStateImageView.hidden = YES;
            self.powerStateImageView.hidden = YES;
            self.clickEffectView.effect_enabled = YES;
        }
            break;
    }
}

- (void)configViewWithMasterState:(DevMasterStateType)type {
    _masterStateType = type;
    switch (type) {
        case DevMasterStateTypeIsMaster:
        {
            self.mapBaseViewConstranitTrailing.constant = 132;
            self.functionBaseView.hidden = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.mapBaseView.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            break;
        }
        case DevMasterStateTypeNoMaster:
        {
            self.mapBaseViewConstranitTrailing.constant = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.mapBaseView.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (finished) {
                    self.functionBaseView.hidden = YES;
                }else {
                    self.functionBaseView.hidden = NO;
                }
            }];
            break;
        }
        default:
        {
            self.mapBaseViewConstranitTrailing.constant = 132;
            self.functionBaseView.hidden = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.mapBaseView.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            break;
        }
    }
}

- (void)configViewWithSimCardState:(NSInteger)type {
    if (type == 3) {
        self.normalView.serviceView.hidden = NO;
        self.normalView.gprsServiceView.hidden = YES;
        
        self.viceUserView.serviceView.hidden = NO;
        self.viceUserView.gprsServiceView.hidden = YES;
    }else {
        self.normalView.serviceView.hidden = YES;
        self.normalView.gprsServiceView.hidden = NO;
        
        self.viceUserView.serviceView.hidden = YES;
        self.viceUserView.gprsServiceView.hidden = NO;
    }
}

- (void)configDataWithLati:(CGFloat)lati longi:(CGFloat)longi {
    if (lati == 0 && longi == 0) {
        MAMapRect rect = MAMapRectMake(224449596, 109281583, 567088, 911860);
        [self.mapView setVisibleMapRect:rect animated:NO];
        [self.mapView removeAnnotation:self.devAnnotation];
        return;
    }
    CLLocationCoordinate2D devCoordinate = AMapCoordinateConvert(CLLocationCoordinate2DMake(lati, longi), AMapCoordinateTypeGPS);
    self.devCoordinate = devCoordinate;
    self.devAnnotation.coordinate = devCoordinate;
    
    if (self.mapView) {
        [self.mapView addAnnotation:self.devAnnotation];
        [self showAnnotations:YES];
        /* 已经存在人的当前位置就刷新人的位置 */
        if (self.mapView.annotations.count > 1) {
            [self startLocationService];
        }
    }else {
        ;
    }
}

- (void)configDeviceName:(NSString *)deviceName {
    self.gpsNameLabel.text = deviceName;
}

- (void)configDeviceIndex:(NSInteger)index count:(NSInteger)totalCount {
    if (totalCount <= 1) {
        // 不多于一个设备 隐藏索引
        self.deviceNumOne.hidden = YES;
        self.deviceNumTwo.hidden = YES;
    }else {
        self.deviceNumOne.hidden = NO;
        self.deviceNumTwo.hidden = NO;
    }
    
    if (index >=0 && index <= 9) {
        self.deviceNumOne.image = [UIImage imageNamed:@"gps_num0"];
        self.deviceNumTwo.image = [UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@", @(index)]];
    }
    
    if (index >= 10 && index <= 99) {
        self.deviceNumOne.image = [UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@", @(index/10)]];
        self.deviceNumTwo.image = [UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@", @(index%10)]];
    }
}

- (void)configDeviceLeft_dayes:(NSInteger)left_days {
    [self.normalView.gprsServiceView setLeft_days:left_days];
    [self.viceUserView.gprsServiceView setLeft_days:left_days];
}

- (void)configDeviceSecurityMode:(NSInteger)mode {
    [self.findingView setSecurityMode:mode];
    [self.normalView.securityView setSecurityModeType:mode];
}

+ (CGFloat)heightForItem:(id)item width:(CGFloat)width {
    return 200;
}

#pragma mark - action
/*
- (void)mapTapAction:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.mapView];
    if (CGRectContainsPoint(self.mapView.frame, location) ) {
        
    }
}
*/

#pragma mark - locate
- (void)startLocationService {
    //self.mapView.showsUserLocation = YES;
}

- (void)stopLocationService {
    self.mapView.showsUserLocation = NO;
}

- (void)showAnnotations:(BOOL)animated {
    if (self.mapView.annotations.count == 0) {
        // 默认设置为上海市地图
        MAMapRect rect = MAMapRectMake(224449596, 109281583, 567088, 911860);
        [self.mapView setVisibleMapRect:rect animated:animated];
        return;
    }
    
    if (self.mapView.annotations.count == 1) {
        [self.mapView setZoomLevel:17.5f];
        [self performSelector:@selector(showAnnotations:) withObject:@(YES) afterDelay:1.0];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:animated];
    if (self.mapView.annotations.count > 1) {
        [self makePolyline];
    }
}

#pragma mark - G100TapAnimationDelegate
- (void)viewTouchedToPushWithView:(UIView *)touchedView touchPoint:(CGPoint)point{
    if (self.mapTapAction) {
        self.mapTapAction();
    }
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation) {
        self.userAnnotation.coordinate = userLocation.location.coordinate;
        [self.mapView addAnnotation:self.userAnnotation];
        [self stopLocationService];
        [self showAnnotations:YES];
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error  {
    [self stopLocationService];
}

-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    static NSString *trackingReuseIndetifier = @"annotationReuseIndetifier";
    MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:trackingReuseIndetifier];
    annotationView.canShowCallout = NO;
    
    if (annotation == self.devAnnotation) {
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.image = [UIImage imageNamed:@"ic_callout_bike"];
        return annotationView;
        
    }else if (annotation == self.userAnnotation) {
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.image = [UIImage imageNamed:@"ic_callout_user"];
        return annotationView;
        
    }else if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }

        annotationView.image = [[UIImage alloc]init];
        return annotationView;
    }
    
    return nil;
}
/*
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView * polylineView = [[MAPolylineView alloc] initWithPolyline:(MAPolyline *)overlay];
        polylineView.lineDash = YES;
        polylineView.lineWidth = 4.f;
        polylineView.strokeColor = [UIColor colorWithHexString:@"33CC00"];
        polylineView.lineJoinType = kMALineJoinRound;//连接类型
        polylineView.lineCapType = kMALineCapRound;//端点类型
        
        return polylineView;
    }
    return nil;
}
 */

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
    }
    return nil;
}

#pragma mark - draw lines
- (void)makePolyline{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    CLLocationCoordinate2D commonPolylineCoords[2];
    commonPolylineCoords[0].latitude = self.devAnnotation.coordinate.latitude;
    commonPolylineCoords[0].longitude = self.devAnnotation.coordinate.longitude;
    commonPolylineCoords[1].latitude = self.userAnnotation.coordinate.latitude;
    commonPolylineCoords[1].longitude = self.userAnnotation.coordinate.longitude;
    
    //构造折线对象 (只是折线的数据类)
    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:2];
    //在地图上添加折线对象
    [self.mapView addOverlay:commonPolyline];
}

#pragma mark - Life Cycle
- (void)mdv_viewWillAppear:(BOOL)animated {
    if ([self.mapView superview]) {
        [self showAnnotations:NO];
    }else {
        self.mapView = [[MAMapView alloc] init];
        [self.mapBaseView insertSubview:self.mapView atIndex:0];
        
        [self setupView];
        
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.mapBaseView);
        }];
        
        if (self.devCoordinate.latitude != 0 && self.devCoordinate.longitude != 0) {
            self.devAnnotation.coordinate = self.devCoordinate;
            [self.mapView addAnnotation:self.devAnnotation];
        }
        
        [self showAnnotations:NO];
        /* 已经存在人的当前位置就刷新人的位置 */
        if (self.mapView.annotations.count > 1) {
            [self startLocationService];
        }
        
        if ([self.mapScreenImageView superview]) {
            [self performSelector:@selector(screenMapViewRemove) withObject:nil afterDelay:1.0];
        }
    }
}

- (void)mdv_viewDidAppear:(BOOL)animated {
    if ([self.mapView superview]) {
        [self showAnnotations:NO];
    }else {
        self.mapView = [[MAMapView alloc] init];
        [self.mapBaseView insertSubview:self.mapView atIndex:0];
        
        [self setupView];
        
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.mapBaseView);
        }];
        
        if (self.devCoordinate.latitude != 0 && self.devCoordinate.longitude != 0) {
            self.devAnnotation.coordinate = self.devCoordinate;
            [self.mapView addAnnotation:self.devAnnotation];
        }
        
        [self showAnnotations:NO];
        /* 已经存在人的当前位置就刷新人的位置 */
        if (self.mapView.annotations.count > 1) {
            [self startLocationService];
        }
        
        if ([self.mapScreenImageView superview]) {
            [self performSelector:@selector(screenMapViewRemove) withObject:nil afterDelay:1.0];
        }
    }
}

- (void)mdv_viewWillDisappear:(BOOL)animated {
    if (!self.mapScreenImageView) {
        // 如果还没截图 就截一张图
        self.mapScreenImageView = [[UIImageView alloc] init];
    }
    self.mapScreenImageView.image = [self getImageViewWithView:self.mapView];
}

- (void)mdv_viewDidDisappear:(BOOL)animated {
    if (!self.mapScreenImageView) {
        // 如果还没截图 就截一张图
        self.mapScreenImageView = [[UIImageView alloc] init];
        self.mapScreenImageView.image = [self getImageViewWithView:self.mapView];
    }
    
    if ([self.mapView superview]) {
        if (![self.mapScreenImageView superview]) {
            [self.mapBaseView insertSubview:self.mapScreenImageView atIndex:1];
            
            [self.mapScreenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.mapBaseView);
            }];
        }
        
        if ([self.mapView superview]) {
            [self.mapView removeFromSuperview];
        }
        self.mapView = nil;
    }else {
        
    }
}
- (void)screenMapViewRemove {
    if ([self.mapScreenImageView superview]) {
        [self.mapScreenImageView removeFromSuperview];
    }
    
    self.mapScreenImageView = nil;
}

- (UIImage *)getImageViewWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
