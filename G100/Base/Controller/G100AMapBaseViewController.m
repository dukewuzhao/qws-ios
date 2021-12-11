//
//  G100AMapBaseViewController.m
//  G100
//
//  Created by Tilink on 15/10/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100AMapBaseViewController.h"
#import <MapKit/MapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

#define VISIBLEMAPRECT               @"visiblemaprect"
#define MyZOOMLEVEL                  @"zoomLevel"
#define ANNOTATION_REGION_PAD_FACTOR 40
#define MAX_DEGREES_ARC              19
#define MINIMUM_ZOOM_ARC             3

@interface G100AMapBaseViewController () <UIActionSheetDelegate> {
    BOOL _hasMapDidAppear;
}

@property (nonatomic, strong) NSMutableArray *availableMaps;
@property (nonatomic, copy) NSString * endLocationName;
@property (nonatomic, assign) CLLocationCoordinate2D endLocationCoor;

@end

@implementation G100AMapBaseViewController

@synthesize mapView = _mapView;

#pragma mark - Initialization 

- (void)initMapView {
    self.mapView = [[MAMapView alloc] initWithFrame:self.contentView.bounds];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.mapView.delegate = self;
    
    [self.mapView setShowsCompass:YES];
    
    [self.mapView setShowsScale:NO];
    
    [self.mapView setCompassOrigin:CGPointMake(20, 60)];
    
    [self.contentView addSubview:self.mapView];
    
    /*
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBarView.bottom);
        make.bottom.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
     */
    
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    
    MAMapRect rect = MAMapRectMake(224449596, 109281583, 567088, 911860);
    if ([[UserManager shareManager] getAsynchronousWithKey:VISIBLEMAPRECT]) {
        NSDictionary * visibleMapRect = [[UserManager shareManager] getAsynchronousWithKey:VISIBLEMAPRECT];
        
        rect = MAMapRectMake(
                             [[visibleMapRect objectForKey:@"x"] doubleValue],
                             [[visibleMapRect objectForKey:@"y"] doubleValue],
                             [[visibleMapRect objectForKey:@"w"] doubleValue],
                             [[visibleMapRect objectForKey:@"h"] doubleValue]
                             );
    }
    
    [self.mapView setVisibleMapRect:rect animated:NO];
    
    CGFloat zoomLevel = 15.4;
    if ([[UserManager shareManager] getAsynchronousWithKey:MyZOOMLEVEL]) {
        zoomLevel = [[[UserManager shareManager] getAsynchronousWithKey:MyZOOMLEVEL] floatValue];
    }
    
    [self.mapView setZoomLevel:zoomLevel animated:NO];
}

- (void)initSearch {
    self.search = [[AMapSearchAPI alloc] init];
}

#pragma mark - 自定义操作方法
- (void)zoomMapViewToFitAnnotations:(MAMapView *)mapView animated:(BOOL)animated {
    UIEdgeInsets edgInsets = UIEdgeInsetsMake(100, 80, 120, 80);
    [self zoomMapViewToFitAnnotations:mapView edgeInset:edgInsets animated:animated];
}

- (void)zoomMapViewToFitAnnotations:(MAMapView *)mapView edgeInset:(UIEdgeInsets)edgeInset animated:(BOOL)animated {
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (id result in mapView.annotations) {
        // 产品需求 要去掉用户定位的标注 如果是定位 且 不显示用户位置
        if ([result isKindOfClass:[MAUserLocation class]]) {
            if (self.userLocationAnnotationHidden) {
                // 如果隐藏用户信息 则不包括用户位置
                if (!self.userLocationViewHidden) {
                    [annotations addObject:result];
                }
            } else {
                [annotations addObject:result];
            }
            
        } else {
            [annotations addObject:result];
        }
    }
    
    NSInteger count = [annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    MAMapPoint points[count]; //C array of MKMapPoint struct
    for( int i = 0; i < count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MAAnnotation>)[annotations safe_objectAtIndex:i] coordinate];
        points[i] = MAMapPointForCoordinate(coordinate);
    }

//    MAMapRect mapRect = [[MAPolygon polygonWithPoints:points count:count] boundingMapRect];
//    [mapView setVisibleMapRect:mapRect edgePadding:edgeInset animated:animated];
    [mapView showAnnotations:annotations edgePadding:edgeInset animated:animated];
}

- (CLLocationCoordinate2D)transformGPS2Gaode:(CLLocationCoordinate2D)test {
    CLLocationCoordinate2D amapcoord = AMapCoordinateConvert(test, AMapCoordinateTypeGPS);
    return amapcoord;
}

#pragma mark - 开始定位
- (void)startLocationService {
    self.mapView.distanceFilter = 50;
    self.mapView.showsUserLocation = YES;
}

- (void)stopLocationService {
    self.mapView.showsUserLocation = NO;
}

- (void)zoomIn {
    CGFloat zoomLevel = self.mapView.zoomLevel;
    zoomLevel += 1;
    [self.mapView setZoomLevel:zoomLevel animated:YES];
}

- (void)zoomOut {
    CGFloat zoomLevel = self.mapView.zoomLevel;
    zoomLevel -= 1;
    [self.mapView setZoomLevel:zoomLevel animated:YES];
}

-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (!_hasMapDidAppear) {
        return;
    }
    // 保存用户设置的缩放比例
    [[UserManager shareManager] setAsynchronous:[NSNumber numberWithFloat:mapView.zoomLevel] withKey:MyZOOMLEVEL];
    
    MAMapRect rect = self.mapView.visibleMapRect;
    
    NSDictionary * visibleMapRect = @{ @"x" : [NSNumber numberWithDouble:rect.origin.x],
                                       @"y" : [NSNumber numberWithDouble:rect.origin.y],
                                       @"w" : [NSNumber numberWithDouble:rect.size.width],
                                       @"h" : [NSNumber numberWithDouble:rect.size.height] };
    
    [[UserManager shareManager] setAsynchronous:visibleMapRect withKey:VISIBLEMAPRECT];
}

#pragma mark - 调用三方地图进行导航
- (void)callThirdMapForNavigationWithStartCoor:(CLLocationCoordinate2D)startCoor
                                       endCoor:(CLLocationCoordinate2D)endCoor
                                     startName:(NSString *)startName
                                       endName:(NSString *)endName {
    
    if (!_availableMaps) {
        self.availableMaps = [[NSMutableArray alloc] init];
    }
    
    [self.availableMaps removeAllObjects];
    
    self.endLocationCoor = endCoor;
    self.endLocationName = endName;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map"]]){
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=riding&coord_type=gcj02",
                               startCoor.latitude, startCoor.longitude, endCoor.latitude, endCoor.longitude, endName];
        
        NSDictionary *dic = @{@"name": @"百度地图",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
                               startName, endCoor.latitude, endCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"高德地图",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    
    UIActionSheet *action = [[UIActionSheet alloc] init];
    
    [action addButtonWithTitle:@"使用系统自带地图导航"];
    for (NSDictionary *dic in self.availableMaps) {
        [action addButtonWithTitle:[NSString stringWithFormat:@"使用%@导航", dic[@"name"]]];
    }
    [action addButtonWithTitle:@"取消"];
    action.cancelButtonIndex = self.availableMaps.count + 1;
    action.delegate = self;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.endLocationCoor addressDictionary:nil]];
        toLocation.name = self.endLocationName;
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        
    }else if (buttonIndex < self.availableMaps.count+1) {
        NSDictionary *mapDic = self.availableMaps[buttonIndex-1];
        NSString *urlString = mapDic[@"url"];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showDefaultMapViewRect:(BOOL)animated {
    // 默认设置为上海市地图
    MAMapRect rect = MAMapRectMake(224449596, 109281583, 567088, 911860);
    [self.mapView setVisibleMapRect:rect animated:animated];
}

- (void)showAllAnnotationsWithEdgeInset:(UIEdgeInsets)edgeInset animated:(BOOL)animated {
    if (self.mapView.annotations.count == 0) {
        // 没有标注
        MAMapRect rect = MAMapRectMake(224449596, 109281583, 567088, 911860);
        [self.mapView setVisibleMapRect:rect animated:NO];
        [self.mapView setZoomLevel:15.0];
    }else if (self.mapView.annotations.count == 1) {
        [self zoomMapViewToFitAnnotations:self.mapView edgeInset:edgeInset animated:animated];
        [self.mapView setZoomLevel:17.0 animated:animated];
    }else {
        [self zoomMapViewToFitAnnotations:self.mapView edgeInset:edgeInset animated:animated];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initMapView];
    
    [self initSearch];
    
    _hasMapDidAppear = NO;
    _userLocationViewHidden = YES;
    _userLocationServiceEnabled = YES;
    _userLocationAnnotationHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.mapView.delegate = self;
    self.search.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.mapView.delegate = nil;
    self.search.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _hasMapDidAppear = YES;
}

@end
