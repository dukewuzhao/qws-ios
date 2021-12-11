//
//  LineChart.h
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import "BaseChart.h"
#import "LineChartData.h"
typedef void(^valueChanged)(NSInteger);
typedef void(^draggingComplete)();
@interface LineChart : BaseChart
@property (nonatomic, strong) NSMutableArray <LineChartData *> *chartDatas;

- (void)strokeChart;

- (void)updateChartWithChartData:(NSMutableArray <LineChartData *> *)chartData;

- (void)moveLineWithPoint:(CGPoint)point;

@property (nonatomic, assign) CGFloat maxSpeed;

@property (nonatomic, copy) valueChanged valueChanged;

@property (nonatomic, copy)draggingComplete draggingComplete;

@end
