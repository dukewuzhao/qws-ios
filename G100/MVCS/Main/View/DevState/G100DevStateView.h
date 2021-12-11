//
//  G100DevStateView.h
//  G100
//
//  Created by William on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardBaseView.h"
#import "DevNormalStateView.h"
#import "DevFindingStateView.h"
#import "DevViceUserStateView.h"

typedef NS_ENUM(NSInteger, DevStateType) {
    DevStateTypeNormal,
    DevStateTypeFinding,
    DevStateTypeViceUser
};

typedef NS_ENUM(NSInteger, PowerStateType) {
    PowerStateTypeRecovering = 3,
    PowerStateTypeRecovered = 0,
    PowerStateTypePowerOffed = 2,
    PowerStateTypePowerOffing = 1
};

typedef NS_ENUM(NSInteger, DevMasterStateType) {
    DevMasterStateTypeIsMaster = 1,
    DevMasterStateTypeNoMaster = 0
};

@class MAMapView;
@interface G100DevStateView : G100CardBaseView

@property (copy, nonatomic) void (^mapTapAction)();

@property (copy, nonatomic) void (^normalFunctionTapAction)(NSInteger index);

@property (copy, nonatomic) void (^findingFunctionTapAction)(NSInteger index, GPSType type);

@property (copy, nonatomic) void (^viceUserFunctionTapActiom)();

@property (strong, nonatomic) IBOutlet MAMapView *mapView;

@property (strong, nonatomic) IBOutlet UILabel *gpsNameLabel;

/* 车辆状态 0:正常状态 1:寻车状态 */
@property (assign, nonatomic) DevStateType stateType;
/* 远程供断电状态 0恢复中 1恢复 2断电 3断电中 */
@property (assign, nonatomic) PowerStateType powerStateType;
/* 主副设备状态 1 主设备 0 副设备*/
@property (assign, nonatomic) DevMasterStateType masterStateType;

/* 寻车中视图 */
@property (strong, nonatomic) DevFindingStateView * findingView;

/* 状态控制视图 */
@property (weak, nonatomic) IBOutlet UIView *stateView;

/* 寻车状态视图 */
@property (weak, nonatomic) IBOutlet UIImageView *findingStateImageView;

/* 电源状态视图 */
@property (weak, nonatomic) IBOutlet UIImageView *powerStateImageView;

/* 更新时间 */
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLabel;

/* 设备号数字十位 */
@property (weak, nonatomic) IBOutlet UIImageView *deviceNumOne;
/* 设备号数字个位 */
@property (weak, nonatomic) IBOutlet UIImageView *deviceNumTwo;

/**
 *  根据状态显示模式
 *
 *  @param type 车辆模式
 */
- (void)configViewWithState:(DevStateType)type;
/**
 *  根据设备主副状态显示模式 1主设备 2副设备
 *
 *  @param type 主副设备 1主设备 2副设备
 */
- (void)configViewWithMasterState:(DevMasterStateType)type;
/**
 *  根据设备的机卡分离状态显示
 *
 *  @param type 3 机卡分离 其他不做处理
 */
- (void)configViewWithSimCardState:(NSInteger)type;

/**
 *  设置视图数据
 *
 *  @param lat      纬度
 *  @param longi    经度
 */
- (void)configDataWithLati:(CGFloat)lati longi:(CGFloat)longi;
/**
 *  设置右上角的设备名称
 *
 *  @param deviceName 顺序
 */
- (void)configDeviceName:(NSString *)deviceName;
/**
 *  设置右上角的顺序
 *
 *  @param index 顺序
 *  @param totalCount 设备总数量
 */
- (void)configDeviceIndex:(NSInteger)index count:(NSInteger)totalCount;
/**
 *  设置设备服务期剩余时间
 *
 *  @param left_days 剩余天数
 */
- (void)configDeviceLeft_dayes:(NSInteger)left_days;
/**
 *  设置设备安防设置模式
 *
 *  @param mode 安防设置模式 1低 2标准 3警戒 8丢车模式 9撤防
 */
- (void)configDeviceSecurityMode:(NSInteger)mode;

+ (CGFloat)heightForItem:(id)item width:(CGFloat)width;

+ (instancetype)loadDevStateView;

- (void)startLocationService;

/**
 *  即将滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillAppear:(BOOL)animated;
/**
 *  已经滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidAppear:(BOOL)animated;
/**
 *  即将离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillDisappear:(BOOL)animated;
/**
 *  已经离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidDisappear:(BOOL)animated;

@end
