//
//  G100TrackSpeedView.m
//  G100
//
//  Created by 曹晓雨 on 2017/8/22.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TrackSpeedView.h"

@interface G100TrackSpeedView ()

@end

@implementation G100TrackSpeedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatLineChart];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)setHisTracksDomain:(G100BikeHisTracksDomain *)hisTracksDomain {
    _hisTracksDomain = hisTracksDomain;
    self.lineChart.stepCount = hisTracksDomain.loc.count;
    
    LineChartData *data1 = [[LineChartData alloc]init];
    ChartPointSet *set1 = [[ChartPointSet alloc]init];
    for (G100BikeHisTrackDomain *hisTrackDomain in hisTracksDomain.loc) {
        ChartPointItem *point = [ChartPointItem pointItemWithRawX:[[hisTrackDomain.ts substringFromIndex:11] substringToIndex:8] andRowY:[NSString stringWithFormat:@"%f", hisTrackDomain.speed]];
            [set1.items addObject:point];
    }
    [data1.sets addObject:set1];
    
    //超速曲线叠加
    LineChartData *data2 = [[LineChartData alloc]init];
    if (self.maxSpeed == 0) {
        data2.lineColor = [UIColor colorWithHexString:@"#1fbda8"];
    }else{
        data2.lineColor = [UIColor colorWithHexString:@"#ffa300"];
    }
    
    [data2.sets addObject:set1];
    self.lineChart.chartDatas = @[data1,data2].mutableCopy;
    [self addSubview:self.lineChart];
    
    [self.lineChart strokeChart];
}

- (void)creatLineChart {
    self.lineChart = [[LineChart alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
- (void)setMaxSpeed:(CGFloat)maxSpeed {
    _maxSpeed = maxSpeed;
    self.lineChart.maxSpeed = maxSpeed;
}
- (void)moveLineWithPoint:(CGPoint)point {
    [self.lineChart moveLineWithPoint:point];
}

@end
