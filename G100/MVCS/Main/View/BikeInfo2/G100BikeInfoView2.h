//
//  G100BikeInfoView.h
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100BikeManager.h"
#import "G100WeatherManager.h"


@protocol G100BikeInfoTapDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushBikeDetailWithView:(UIView *)touchedView;


/**
 点击跳转评分页面

 @param touchedView 被点击的View
 */
- (void)viewTapToPushTestDetailWithView:(UIView *)touchedView;

/**
 点击放大车辆二维码

 @param button 二维码
 */
- (void)buttonClickedToScaleQRCode:(UIButton *)button;


/**
 点击刷新天气

 @param touchedView 天气
 */
- (void)viewTapToRefreshWeather:(UIView *)touchedView;

@end

@class G100TestResultDomain;
@interface G100BikeInfoView2 : G100CardBaseView

@property (strong, nonatomic) G100BikeModel *bikeModel;

@property (strong, nonatomic) G100TestResultDomain *testResultDomin;
/**
 *  获取的天气数据模型
 */
@property (strong, nonatomic)  G100WeatherModel *weatherModel;


@property(nonatomic,weak) id<G100BikeInfoTapDelegate> delegate;

/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)loadBikeInfoView;

/**
 *  根据View的宽度算出View的高
 *
 *  @param width
 *
 *  @return View的高
 */
+ (float)heightWithWidth:(float)width;


- (void)updateSafeState;

@end
