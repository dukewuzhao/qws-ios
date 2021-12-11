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
 点击刷新天气

 @param touchedView 天气
 */
- (void)viewTapToRefreshWeather:(UIView *)touchedView;

/**
 点击进入电池设置界面
 
 @param button 电量无法计算按钮
 */
- (void)buttonClickedToPushBattDetail:(UIButton *)button;

@end

@class G100TestResultDomain;
@interface G100BikeInfoView : G100CardBaseView

@property (strong, nonatomic) G100BikeModel *bikeModel;

@property (nonatomic, assign) CGFloat    soc;//电量
@property (nonatomic, assign) CGFloat    expecteddistance;// 续航里程
@property (assign, nonatomic) BOOL      eleDoorState;//电门开关状态
@property (assign, nonatomic) NSInteger setSafeMode;  //主设备设防模式
@property (assign,nonatomic) BOOL isCompute; //是否计算电量
@property (assign,nonatomic) NSInteger vol;//电压
/**
 *  获取的天气数据模型
 */
@property (strong, nonatomic)  G100WeatherModel *weatherModel;

@property (weak, nonatomic) IBOutlet UIView *rightBattView;

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


/**
 *  更新电量和安防设置状态
 */
- (void)updateSafeState;

@end
