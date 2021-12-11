//
//  ChartPointSet.m
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import "ChartPointSet.h"

@implementation ChartPointSet
- (instancetype)init{
    if (self = [super init]) {
        [self setupDefaultValues];
    }
    return self;
}

- (void)setupDefaultValues{
    _items = @[].mutableCopy;
    _type = LineChartPointSetTypeNone;
    _buyPointColor = [UIColor colorWithRed:238.0f/255.0f green:64.0f/225.0f blue:0.0f alpha:1.0f];
    _relocatePointColor = [UIColor colorWithRed:155.0f/255.0f green:48.0f/225.0f blue:1.0f alpha:1.0f];
    _pointRadius = 2.0f;
}
@end
