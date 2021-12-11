//
//  G100AMapBaseViewController.h
//  G100
//
//  Created by Tilink on 15/10/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface G100AMapBaseViewController : G100BaseVC <MAMapViewDelegate, AMapSearchDelegate>

/**
 地图实例
 */
@property (nonatomic, strong) MAMapView * mapView;

/**
 高德搜索实例
 */
@property (nonatomic, strong) AMapSearchAPI * search;

/**
 是否开启定位功能
 */
@property (nonatomic, assign) BOOL userLocationServiceEnabled;

/**
 是否显示用户默认位置
 */
@property (nonatomic, assign) BOOL userLocationViewHidden;

/**
 是否添加显示用户位置
 */
@property (nonatomic, assign) BOOL userLocationAnnotationHidden;

/**
 *  @brief  GPS坐标转高德坐标系
 *
 *  @param test GPS坐标点
 *
 *  @return 高德坐标点
 */
- (CLLocationCoordinate2D)transformGPS2Gaode:(CLLocationCoordinate2D)test;

/**
 *  @brief  完全显示mapView上的所有标注
 *
 *  @param mapView  地图view
 *  @param animated 动画是否开启
 */
- (void)zoomMapViewToFitAnnotations:(MAMapView *)mapView animated:(BOOL)animated;
/**
 *  @brief  完全显示mapView上的所有标注
 *
 *  @param mapView  地图view
 *  @param animated 动画是否开启
 */
- (void)zoomMapViewToFitAnnotations:(MAMapView *)mapView edgeInset:(UIEdgeInsets)edgeInset animated:(BOOL)animated;

/**
 开始定位
 */
- (void)startLocationService;

/**
 停止定位
 */
- (void)stopLocationService;

/**
 缩小显示区域
 */
- (void)zoomIn;

/**
 放大显示区域
 */
- (void)zoomOut;

/**
 *  调用第三方地图导航
 *
 *  @param startCoor 起点
 *  @param endCoor   终点
 *  @param startName 起点名称
 *  @param endName   终点名称
 */
- (void)callThirdMapForNavigationWithStartCoor:(CLLocationCoordinate2D)startCoor
                                       endCoor:(CLLocationCoordinate2D)endCoor
                                     startName:(NSString *)startName
                                       endName:(NSString *)endName;

/**
 *  显示默认地图区域
 */
- (void)showDefaultMapViewRect:(BOOL)animated;
/**
 *  设置显示标注区域
 *
 *  @param edgeInset 距离边距
 *  @param animated  是否动画
 */
- (void)showAllAnnotationsWithEdgeInset:(UIEdgeInsets)edgeInset animated:(BOOL)animated;

@end
