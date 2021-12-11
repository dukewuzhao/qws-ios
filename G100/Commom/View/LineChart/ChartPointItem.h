//
//  ChartPointItem.h
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ChartPointItem : NSObject
+ (instancetype)pointItemWithRawX:(NSString *)rawx andRowY:(NSString *)rowy;

@property (nonatomic, copy, readonly) NSString *rawX;
@property (nonatomic, copy, readonly) NSString *rawY;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@end
