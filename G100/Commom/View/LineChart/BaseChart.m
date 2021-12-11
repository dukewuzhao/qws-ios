//
//  BaseChart.m
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import "BaseChart.h"
#define TextColor [UIColor colorWithHexString:@"#bebebe"]
#define IndicateColor [UIColor colorWithHexString:@"#30c100"]
#define IndicateBackColor [UIColor colorWithHexString:@"#30c100"]
#define LabelFont [UIFont boldSystemFontOfSize:12]

@implementation BaseChart
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setDefaultValues];
        
    }
    return self;
}

- (void)setDefaultValues{
    
    _xLabelFont = LabelFont;
    _xLabelColor = TextColor;
    _yLabelFont = [UIFont systemFontOfSize:12.0f];
    _yLabelColor = TextColor;
    _yLabelWidthPadding = 10.0f;
    _signedValue = YES;
    //    _yLabelFormat = @"%.2f";
    _yLabelSuffix = @"km/h";
    _stepCount = 4;
    
    _chartMarginLeft = 20.0f;
    _chartMarginRight = 20.0f;
    _chartMarginTop = 20.0f;
    _chartMarginBottom = 28.0f;
    
    _axisType = ChartAxisTypeBoth | ChartAxisTypeDash;
    _axisWidth = 1.5f;
    _axisColor = TextColor;
    
    _indicateLineType = ChartIndicateLineTypeBoth | ChartIndicateLineTypeDash;
    _indicatePointColor = IndicateColor;
    _indicatePointBackColor = IndicateBackColor;
    _xIndicateLineWidth = 0.6f;
    _xIndicateLineColor = IndicateColor;
    _xIndicateLabelFont = LabelFont;
    _xIndicateLabelTextColor = [UIColor whiteColor];
    _xIndicateLabelBackgroundColor = IndicateColor;
    
    _yIndicateLineWidth = 1.5f;
    _yIndicateLineColor = IndicateColor;
    _yIndicateLabelFont = LabelFont;
    _yIndicateLabelTextColor = [UIColor whiteColor];
    _yIndicateLabelBackgroundColor = IndicateColor;
    
    _displayAnimated = NO;
    _animateDuration = 1.0f;
}

- (void)setAxisType:(ChartAxisType)axisType{
    if (_axisType != axisType) {
        _axisType = axisType;
    }
}

- (void)setAxisWidth:(CGFloat)axisWidth{
    if (_axisWidth != axisWidth) {
        _axisWidth = axisWidth;
    }
}

- (void)setAxisColor:(UIColor *)axisColor{
    if (_axisColor != axisColor) {
        _axisColor = axisColor;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
