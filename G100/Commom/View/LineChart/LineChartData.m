//
//  LIneChartData.m
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import "LineChartData.h"
#define TextColor [UIColor lightGrayColor]
#define LineColor  [UIColor colorWithHexString:@"#1fbda8"]
#define FillColor [UIColor colorWithRed:0.0f green:191.0f/225.0f blue:1.0f alpha:0.5f];
#define LabelFont [UIFont systemFontOfSize:12.0f]

@implementation LineChartData
- (instancetype)init{
    if (self = [super init]) {
        [self setupDefaultValues];
    }
    return self;
}

- (void)setupDefaultValues{
    _sets = @[].mutableCopy;
    
    _lineColor = LineColor;
    _lineWidth = 2.0f;
    _fillColor = nil;
}
@end
