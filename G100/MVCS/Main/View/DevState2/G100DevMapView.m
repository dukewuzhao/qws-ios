//
//  G100DevMapView.m
//  G100
//
//  Created by sunjingjing on 16/10/25.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevMapView.h"
#import <MAMapKit/MAMapKit.h>

#import "PositionDomain.h"
#import "CustomMAPointAnnotation.h"
#import "CustomMAAnnotationView.h"
@interface G100DevMapView () <MAMapViewDelegate> {
    MAMapRect fitMapRect;
}

@property (weak, nonatomic) IBOutlet UIView *devNumBgView;
@property (nonatomic, strong) CustomMAPointAnnotation *userAnnotation;
@property (nonatomic, strong) NSMutableArray <CustomMAPointAnnotation *>*annosArray; //!< 标注数组

@property (nonatomic, strong) UIImageView *mapScreenImageView;
@property (nonatomic, strong) UIImage *devMapImage;
@property (nonatomic, assign) BOOL needScreenshot;
@end

@implementation G100DevMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.needScreenshot = YES;
    
    self.devNumBgView.layer.masksToBounds = YES;
    self.devNumBgView.layer.cornerRadius = 4.0;
    
    self.devNumBgView.layer.borderWidth = 1.0;
    self.devNumBgView.layer.borderUIColor = [UIColor colorWithHexString:@"ACACAC"];
    
    self.devNumBgView.hidden = YES;
    
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    fitMapRect = MAMapRectMake(224730414, 109736043, 5589, 2839);
    
    [self showAnnotations:YES];
}

#pragma mark - Getter
- (NSMutableArray <CustomMAPointAnnotation *> *)annosArray {
    if (!_annosArray) {
        _annosArray = [[NSMutableArray alloc] init];
    }
    return _annosArray;
}

- (CustomMAPointAnnotation *)userAnnotation {
    if (!_userAnnotation) {
        _userAnnotation = [[CustomMAPointAnnotation alloc] init];
        _userAnnotation.selected = NO;
        _userAnnotation.type = 2;
    }
    return _userAnnotation;
}

#pragma mark - Setter
- (void)setPositionsArray:(NSArray<PositionDomain *> *)positionsArray {
    _positionsArray = positionsArray;
    
    [self setPositionsArray:positionsArray animated:YES];
}

- (void)setPositionsArray:(NSArray<PositionDomain *> *)positionsArray animated:(BOOL)animated {
    // 刷新标注
    [self.mapView removeAnnotations:self.annosArray];
    [self.annosArray removeAllObjects];
    
    for (PositionDomain *position in positionsArray) {
        if (position.coordinate.latitude == 0 &&  position.coordinate.longitude == 0) {
            continue;
        }
        
        CustomMAPointAnnotation *anno = [[CustomMAPointAnnotation alloc] init];
        anno.selected = NO;
        anno.type = 3;
        anno.index = position.index;
        anno.positionDomain = position;
        
        anno.coordinate = position.coordinate;
        
        [self.annosArray addObject:anno];
    }
    
    if ([self.annosArray count]) {
        [self.mapView addAnnotations:self.annosArray];
        [self showAnnotations:animated];
    }else {
        [self showAnnotations:NO];
        //[self startLocationService];
    }
}

- (void)setDeviceCount:(NSInteger)deviceCount {
    _deviceCount = deviceCount;
    // 更新设备数量
    if (deviceCount > 0) {
        self.devNumBgView.hidden = NO;
        self.bindDevNumLabel.hidden = NO;
        self.bindDevNumLabel.text = [NSString stringWithFormat:@"绑定设备%@台", @(deviceCount)];
    }else{
        self.devNumBgView.hidden = YES;
    }
}

- (void)setupView {
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    [self showAnnotations:NO];
}

#pragma mark - Public Method
+ (instancetype)loadDevStateView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100DevMapView" owner:nil options:nil] firstObject];
}

+ (CGFloat)heightForItem:(id)item width:(CGFloat)width{
    return width * 100/207;
}

#pragma mark - Private Method
- (void)showAnnotations:(BOOL)animated {
    if (self.mapView.annotations.count == 0) {
        if (self.userAnnotation && self.userAnnotation.coordinate.latitude != 0 && self.userAnnotation.coordinate.longitude != 0) {
            [self.mapView setCenterCoordinate:self.userAnnotation.coordinate animated:animated];
            [self.mapView setMaxZoomLevel:17.0];
            [self.mapView setZoomLevel:17.0f animated:animated];
        }else{
            // 默认设置为上海市地图
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView setVisibleMapRect:fitMapRect animated:animated];
            });
        }
        return;
    }
    if (self.mapView.annotations.count == 1) {
        [self.mapView setMaxZoomLevel:17.0];
        [self.mapView setZoomLevel:17.0f animated:animated];
        [self performSelector:@selector(showAnnotations:) withObject:@(YES) afterDelay:1.0];
    }else {
        [self.mapView setMaxZoomLevel:17.0];
    }
    [self.mapView showAnnotations:self.mapView.annotations edgePadding:UIEdgeInsetsMake(60, 50, 60, 50) animated:animated];
}

- (void)startLocationService {
    self.mapView.showsUserLocation = YES;
}

- (void)stopLocationService {
    self.mapView.showsUserLocation = NO;
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation) {
        self.userAnnotation.coordinate = userLocation.location.coordinate;
        
        if (![self.mapView.annotations containsObject:self.userAnnotation]) {
            //[self.mapView addAnnotation:self.userAnnotation];
        }
        
        [self stopLocationService];
        [self showAnnotations:YES];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MACircle class]] ){
        if (self.mapView.userLocationAccuracyCircle == overlay) {
            return nil;
        }
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error  {
    [self stopLocationService];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    fitMapRect = mapView.visibleMapRect;
}

- (MAAnnotationView*)getRouteAnnotationView:(MAMapView *)mapview viewForAnnotation:(CustomMAPointAnnotation *)routeAnnotation {
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
                view.image = [UIImage imageNamed:@"ic_map_loc_mine"];
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
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = false;
                view.userInteractionEnabled = YES;
            }
            view.backgroundColor = [UIColor clearColor];
            view.annotation = routeAnnotation;
            view.positionDomain = routeAnnotation.positionDomain;
            
            if (self.deviceCount > 1) {
                if (routeAnnotation.positionDomain.index == 0) {
                     view.image = [UIImage imageNamed:@"ic_map_dev_only"];
                }else{
                    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_map_dev_%@", @(routeAnnotation.positionDomain.index+1)]];
                }
                
            }else {
                if (self.hasSmartDevice) {
                    view.image = [UIImage imageNamed:@"ic_batt_smart_Dev"];
                }else{
                    view.image = [UIImage imageNamed:@"ic_map_dev_only"];
                }
            }
            view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
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

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[CustomMAPointAnnotation class]]) {
        return [self getRouteAnnotationView:mapView viewForAnnotation:(CustomMAPointAnnotation*)annotation];
    }else if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        // 自定义定位样式的图片
        annotationView.image = [[UIImage alloc] init];
        
        return annotationView;
    }
    
    return nil;
}


#pragma mark - Life Cycle
- (void)mdv_viewWillAppear:(BOOL)animated {
    // 取消延时移除地图模块的 @selector
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(mapViewRemove)
                                               object:nil];
    if (_deviceCount == 0) {
        if ([self.mapView superview]){
            [self mapViewRemove];
        }
        return;
    }
    
    if ([self.mapView superview]) {
        
    }else {
        self.mapView = [[MAMapView alloc] init];
        [self insertSubview:self.mapView atIndex:1];
        
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self setupView];
        
        [self setPositionsArray:_positionsArray animated:NO];
    }
}

- (void)mdv_viewDidAppear:(BOOL)animated {
    
    if (_deviceCount == 0) {
        if ([self.mapView superview]){
            [self mapViewRemove];
        }
        return;
    }
    self.needScreenshot = YES;
    if ([self.mapView superview]) {
        
    }else {
        self.mapView = [[MAMapView alloc] init];
        [self insertSubview:self.mapView atIndex:1];
        
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self setupView];
    }
    
    /* 已经存在人的当前位置就刷新人的位置 */
    if (self.mapView.annotations.count <= 0) {
        [self startLocationService];
    }
    
    [self setPositionsArray:_positionsArray animated:NO];
}

- (void)mdv_viewWillDisappear:(BOOL)animated {
    // 如果还没截图 就截一张图 先判断地图是否存在 否则截图是透明的
    if (self.mapView && self.needScreenshot) {
        self.devMapImage = [self getImageViewWithView:self.mapView];
    }
}

- (void)mdv_viewDidDisappear:(BOOL)animated {
    if (!self.mapScreenImageView) {
        self.mapScreenImageView = [[UIImageView alloc] init];
    }
    
    self.needScreenshot = NO;
    
    if ([self.mapView superview]) {
        if (![self.mapScreenImageView superview]) {
            [self insertSubview:self.mapScreenImageView atIndex:0];
            
            [self.mapScreenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(mapViewRemove)
                                                   object:nil];
        
        [self performSelector:@selector(mapViewRemove)
                   withObject:nil
                   afterDelay:10.0];
    }else {
        
    }
    
    self.mapScreenImageView.image = self.devMapImage;
}

#pragma mark - Utils
- (void)mapViewRemove {
    if ([self.mapView superview]) {
        [self.mapView removeFromSuperview];
    }
    self.mapView = nil;
}

- (UIImage *)getImageViewWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (IBAction)devMapTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushCardDevMapDetailWithView:)]) {
        [self.delegate viewTapToPushCardDevMapDetailWithView:self];
    }
}

@end
