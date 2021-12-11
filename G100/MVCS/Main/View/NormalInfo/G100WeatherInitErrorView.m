//
//  G100WeatherInitErrorView.m
//  G100
//
//  Created by sunjingjing on 16/7/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100WeatherInitErrorView.h"

@implementation G100WeatherInitErrorView

+(instancetype)showView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100WeatherInitErrorView" owner:nil options:nil] firstObject];;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    if (ISIPHONE_4 || ISIPHONE_5) {
        self.noWeatherInfo.font = [UIFont systemFontOfSize:14];
    }

}

@end
