//
//  G100NoWeatherView.m
//  G100
//
//  Created by sunjingjing on 16/7/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100NoWeatherView.h"

@interface G100NoWeatherView ()


@end
@implementation G100NoWeatherView

+ (instancetype)showView
{

    return [[[NSBundle mainBundle] loadNibNamed:@"G100NoWeatherView" owner:nil options:nil] firstObject];;
}


@end
