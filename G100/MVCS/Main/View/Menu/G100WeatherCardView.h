//
//  G100WeatherCardView.h
//  G100
//
//  Created by sunjingjing on 2017/6/2.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100WeatherManager.h"

@interface G100WeatherCardView : UIView

/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;
/**
 加载天气预报

 @param callback 接口回调
 */
- (void)loadForecastWeatherModeComplete:(G100ForecastWeatherRequestCallback)callback;

@end
