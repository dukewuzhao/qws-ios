//
//  G100BaseDevMapViewController.h
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100AMapBaseViewController.h"
#import "G100DevPositionDomain.h"
#import "G100LocateButton.h"
#import "UIImage+Rotate.h"
#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "PositionDomain.h"
#import "CustomMAPointAnnotation.h"
#import "CustomMAAnnotationView.h"
#import "G100BikesRuntimeDomain.h"
#import "DevPositionPaoPaoView.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

#import "MAGeoCodeResult.h"
#import "EBOfflineMapService.h"

#import "NSDate+TimeString.h"
#import "G100AMapOfflineMapViewController.h"

@interface G100BaseDevMapViewController : G100AMapBaseViewController <G100LocateButtonDelegate>

@property (nonatomic, copy) NSString * userid;
@property (nonatomic, copy) NSString * bikeid;
@property (nonatomic, copy) NSString * devid;

// 判断是否前来寻车
@property (assign, nonatomic) BOOL isSearchDev;

@property (assign, nonatomic) BOOL unnormalDis;

@property (strong, nonatomic) MAUserLocation          * userLocation;
@property (strong, nonatomic) CustomMAPointAnnotation * userAnnotation;
@property (strong, nonatomic) CustomMAPointAnnotation * devAnnotation;
@property (assign, nonatomic) CLLocationCoordinate2D  devLocation;
@property (assign, nonatomic) CLLocationCoordinate2D  currentUserLocaiton;
@property (strong, nonatomic) UILabel                 * toastLabel;
@property (strong, nonatomic) UILabel                 * distanceLabel;
@property (strong, nonatomic) UILabel                 * scaleLabel;
@property (strong, nonatomic) UIImageView             * rulerView;
@property (strong, nonatomic) UIImageView             * scaleBg;

@property (strong, nonatomic) UILabel                 * suodingStatus;
@property (strong, nonatomic) UIView                  * bottomView;
@property (strong, nonatomic) UIImageView             * userImageView;
@property (strong, nonatomic) G100LocateButton        * locationDevBtn;
@property (strong, nonatomic) G100LocateButton        * locationUserBtn;
@property (strong, nonatomic) UIButton                * suodingBtn;
@property (assign, nonatomic) BOOL                    isFirstLocate;
@property (assign, nonatomic) BOOL                    isFirsGetInfo;

@property (strong, nonatomic) G100DeviceDomain        * deviceDomain;
@property (assign, nonatomic) BOOL                    isFirstGuihua;

@property (strong, nonatomic) NSTimer                 * locationTimer;

@property (strong, nonatomic) EBOfflineMapService *ebservice;

/**
 pickView距离顶端的距离
 */
@property (nonatomic, strong) MASConstraint * scaleBgViewTop;

@property (nonatomic, strong) UIImageView * scaleBgBiew;

/**
 *  导航栏右侧按钮的功能
 *
 *  @param sender button
 */
- (void)tl_devLocatoinMapRightBarButtonClick:(id)sender;
/**
 *  获取车辆信息的回调
 */
- (void)tl_hasGetDevInfo:(G100DevPositionDomain *)positionDomain;
/**
 *  获取用户定位信息的回调
 */
- (void)tl_hasGetUserLocationInfo:(MAUserLocation *)userLocation;
/**
 *  刷新地图数据
 */
- (void)tl_startReloadMapData;

@end
