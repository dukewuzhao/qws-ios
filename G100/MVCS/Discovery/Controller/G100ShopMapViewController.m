//
//  G100ShopMapViewController.m
//  G100
//
//  Created by 温世波 on 15/12/29.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
#import "G100ShopMapViewController.h"

#import "G100ShopDomain.h"
#import "G100CustomShopAnnotationView.h"
#import "G100LocationResultManager.h"

@interface G100ShopAnnotation : MAPointAnnotation

@property (nonatomic, assign) NSInteger type;

@end

@implementation G100ShopAnnotation

@end

@interface G100ShopMapViewController () <MAMapViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet MAMapView * mapView;

@property (nonatomic, strong) NSMutableArray *availableMaps;
@property (nonatomic, copy) NSString * endLocationName;
@property (nonatomic, assign) CLLocationCoordinate2D endLocationCoor;

@end

@implementation G100ShopMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    [self.mapView setZoomLevel:18.0f];
    
    if (_shopPlaceDomain.longi && _shopPlaceDomain.lati) {
        G100ShopAnnotation * annotation = [[G100ShopAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(_shopPlaceDomain.lati, _shopPlaceDomain.longi);
        annotation.type = 1;
        
        [self.mapView addAnnotation:annotation];
        
        [self.mapView selectAnnotation:annotation animated:YES];
        
        [self.mapView showAnnotations:@[annotation] animated:YES];
    } // 否则不添加标注
    
    if (_shopPlaceDomain.name.length) {
        [self setNavigationTitle:_shopPlaceDomain.name];
    }else {
        [self setNavigationTitle:@"店家位置"];
    }
}

#pragma mark - 地图代理相关
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[G100ShopAnnotation class]]) {
        static NSString *shopLocationStyleReuseIndetifier = @"shopLocationStyleReuseIndetifier";
        G100CustomShopAnnotationView *annotationView = (G100CustomShopAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:shopLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[G100CustomShopAnnotationView alloc] initWithAnnotation:annotation
                                                                      reuseIdentifier:shopLocationStyleReuseIndetifier];
        }
        // 自定义定位样式的图片
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.canShowCallout = FALSE;
        annotationView.userInteractionEnabled = YES;
        annotationView.shopPlaceDomain = _shopPlaceDomain.copy;
        annotationView.image = [UIImage imageNamed:@"ic_location_dev_pin"];
        
        return annotationView;
        
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
/*
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    // 自定义定位精度对应的MACircleView.
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        return nil;
    }
    return nil;
}
*/

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        return nil;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    G100ShopAnnotation * annotation = (G100ShopAnnotation *)view.annotation;
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
    G100CustomShopAnnotationView *cusView = (G100CustomShopAnnotationView *)view;
    
    if (annotation.type == 1) {
        __weak G100ShopMapViewController * wself = self;
        cusView.calloutView.navigationButtonBlock = ^(){
            // 调用第三方地图
            CGFloat lng = [[G100LocationResultManager sharedInstance].locationResult.coordinate[0] floatValue];
            CGFloat lat = [[G100LocationResultManager sharedInstance].locationResult.coordinate[1] floatValue];
            [wself callThirdMapForNavigationWithStartCoor:CLLocationCoordinate2DMake(lat, lng) endCoor:CLLocationCoordinate2DMake(_shopPlaceDomain.lati, _shopPlaceDomain.longi) startName:@"当前位置" endName:_shopPlaceDomain.name];
        };
    }
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
