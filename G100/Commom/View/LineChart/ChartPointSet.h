//
//  ChartPointSet.h
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartPointItem.h"
typedef NS_ENUM(NSUInteger, ChartPointSetType) {
    LineChartPointSetTypeNone            = 0,
    LineChartPointSetTypeHighSpeed            = 1 << 0,
    LineChartPointSetTypeLowSpeed       = 1 << 1,
};
@interface ChartPointSet : NSObject
@property (nonatomic, assign) ChartPointSetType type;
@property (nonatomic, strong) NSMutableArray <ChartPointItem *> *items;
@property (nonatomic, strong) UIColor *buyPointColor;
@property (nonatomic, strong) UIColor *relocatePointColor;
@property (nonatomic, assign) CGFloat pointRadius;

@end
