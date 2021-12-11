//
//  LIneChartData.h
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChartPointSet.h"
@interface LineChartData : NSObject

//data
@property (nonatomic, strong) NSMutableArray <ChartPointSet *> *sets;

//line
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;

//fillColor
@property (nonatomic, strong) UIColor *fillColor;

//smooth
@property (nonatomic, assign, getter=isShowSmooth) BOOL showSmooth;

@end
