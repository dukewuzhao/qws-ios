//
//  ChartPointItem.m
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import "ChartPointItem.h"
@interface ChartPointItem()
@property (nonatomic, copy, readwrite) NSString *rawX;
@property (nonatomic, copy, readwrite) NSString *rawY;
@end
@implementation ChartPointItem

+ (instancetype)pointItemWithRawX:(NSString *)rawx andRowY:(NSString *)rowy{
    return [[ChartPointItem alloc]initWithX:rawx andY:rowy];
}

#pragma mark -init
- (id)initWithX:(NSString *)x andY:(NSString *)y{
    if (self = [super init]) {
        self.rawX = x;
        self.rawY = y;
    }
    return self;
}

@end
