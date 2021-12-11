//
//  G100WeatherInitErrorView.h
//  G100
//
//  Created by sunjingjing on 16/7/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100WeatherInitErrorView : UIView

/**
 *  无定位文案
 */
@property (weak, nonatomic) IBOutlet UILabel *noLocAllow;

/**
 *  无天气信息文案
 */
@property (weak, nonatomic) IBOutlet UILabel *noWeatherInfo;

+ (instancetype)showView;


@end
