//
//  G100WeatherView.h
//  G100
//
//  Created by sunjingjing on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardBaseView.h"
#import "G100ClickEffectView.h"
#import "G100NoWeatherView.h"
@class G100WeatherModel,G100WeatherInitErrorView;
@interface G100WeatherView : G100CardBaseView

/**
 *  获取的天气数据模型
 */
@property (strong, nonatomic)  G100WeatherModel *weatherModel;

/**
 *  实时天气对应图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *weathImageView;

/**
 *  当前所在地信息
 */
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

/**
 *  实时天气描述
 */
@property (weak, nonatomic) IBOutlet UILabel *weathLabel;

/**
 *  零下温度“-”
 */
@property (weak, nonatomic) IBOutlet UIImageView *minImageView;

/**
 *  温度十位数
 */
@property (weak, nonatomic) IBOutlet UIImageView *tenImageView;

/**
 *  温度个位数
 */
@property (weak, nonatomic) IBOutlet UIImageView *perImageView;

@property (weak, nonatomic) IBOutlet UIImageView *UnitImageView;

/**
 *  距离上次更新时间间隔
 */
@property (weak, nonatomic) IBOutlet UILabel *timeRefLabel;

/**
 *  上层View
 */
@property (weak, nonatomic) IBOutlet UIView *topView;

/**
 *  下层View
 */
@property (weak, nonatomic) IBOutlet UIView *lowView;

/**
 *  不同温度下View背景
 */
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

/**
 *  上次保存的天气温度
 */
@property (assign, nonatomic) NSInteger lastTemp;

@property (strong, nonatomic) G100NoWeatherView *noWeather;

@property (strong, nonatomic) G100WeatherInitErrorView *ErrorView;

@property (copy, nonatomic) NSString *errorInfo;

@property (weak, nonatomic) IBOutlet G100ClickEffectView *clickedAniView;

@property (assign, nonatomic) BOOL isAnimating;
/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;

-(void)setTempImageWithTemp:(NSInteger)temp;

- (void)beginAnimateWithIsInit:(BOOL)isInit;

- (void)addErrorViewWithErrorInfo:(NSString *)errorInfo;

- (void)updateDataWithWeatherModel:(G100WeatherModel *)weaModel;

/**
 *  根据温度变化调整背景
 *
 *  @param temperature 实时温度
 */
- (void)setBackgroundWithTemperature:(NSInteger)temperature;

@end
