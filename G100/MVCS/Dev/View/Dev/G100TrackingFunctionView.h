//
//  G100TrackingFunctionView.h
//  G100
//
//  Created by William on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Side_Spacing 20*(WIDTH/414.0)
#define ITEM_WIDTH (WIDTH - Side_Spacing * 2 - 1)/4.0
#define ITEM_HEIGHT ITEM_WIDTH * (294.0/282.0)
#define BTN_HEIGHT 48.0+kBottomPadding
#define INFO_HEIGHT 72.0
#define DURATION .3f

typedef NS_ENUM(NSInteger, FlexState) {
    FlexStateClose,
    FlexStateOpen,
    FlexStateAjar
};

typedef enum : NSUInteger {
    DuiMaUnSuoDingMyCarStyle = 0,
    DuiMaSuoDingMyCaringStyle,
    DuiMaSuoDingMyCarStyle,
    DuiMaUnSuoDingMyCaringStyle,
    DuiMaTongxinFaultStyle,
    DuiMaDuiMaFaultStyle,
    caseSolvingNoticeStyle,
    caseClaimingNoticeStyle,
    caseCompensatedNoticeStyle
} MyCarSuoDingStyle;

extern NSString * TFDuiMaTongxinFaultToast;

@class G100TrackingFunctionView, G100RTCommandModel, G100DeviceDomain, G100BikeDomain, G100BikesRuntimeDomain;
@protocol G100TrackingFunctionViewDelegate <NSObject>

- (void)trackingFunctionView:(G100TrackingFunctionView *)functionView didSelected:(G100RTCommandModel *)model;

@end

@interface G100TrackingFunctionView : UIView

@property (nonatomic, weak) id <G100TrackingFunctionViewDelegate> delegate;

/** 视图伸缩状态 */
@property (assign, nonatomic) FlexState flexState;

/** 电量 */
@property (assign, nonatomic) CGFloat battery;
/** 续航里程 */
@property (assign, nonatomic) CGFloat distance;
/** 电门状态 */
@property (assign, nonatomic) BOOL accState;
/** 车辆模型 */
@property (strong, nonatomic) G100BikeDomain * bikeDomain;
/** 设备模型 */
@property (strong, nonatomic) G100DeviceDomain * devDomain;
/** 车辆实时模型 */
@property (strong, nonatomic) G100BikesRuntimeDomain * bikesRuntimeDomain;
/** 车辆对码锁定状态 */
@property (assign, nonatomic) MyCarSuoDingStyle suoDingStyle;

/**
 是否显示底部的车辆信息
 */
@property (assign, nonatomic) BOOL isShowBikeInfo;

/**
 初始化功能区视图

 @param isShowBikeInfo 是否显示车辆信息区域
 @return 视图实例
 */
- (instancetype)initWithShowBikeInfo:(BOOL)isShowBikeInfo;

/**
 隐藏功能区
 */
- (void)hideFunctionView;

/**
 根据车辆设备信息配置功能区域

 @param bikeDomain 车辆模型
 @param devDomain 设备模型
 @param bikesRuntimeDomain 车辆设备实时数据
 */
- (void)configDataWithBikeDomain:(G100BikeDomain *)bikeDomain devDomain:(G100DeviceDomain *)devDomain bikesRuntimeDomain:(G100BikesRuntimeDomain *)bikesRuntimeDomain;

/** 
 辅助view 用于在页面出现后 重新适配
 */
- (void)regulateLayout;

@end
