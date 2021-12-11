//
//  ZEEBarChart.h
//  ZFChartView
//
//  Created by apple on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZEEGenericChart.h"
#import "ZFBar.h"
#import "ZFLabel.h"
#import "ZFConst.h"
@class ZEEBarChart;

/*********************  ZEEBarChartDelegate(ZEEBarChart协议方法)  *********************/
@protocol ZEEBarChartDelegate <NSObject>

@optional
/**
 *  bar宽度(若不设置，默认为25.f)
 */
- (CGFloat)barWidthInBarChart:(ZEEBarChart *)barChart;

/**
 *  组与组之间的间距(若不设置,默认为20.f)
 */
- (CGFloat)paddingForGroupsInBarChart:(ZEEBarChart *)barChart;

/**
 *  每组里面，bar与bar之间的间距(若不设置，默认为5.f)(当只有一组数组时，此方法无效)
 */
- (CGFloat)paddingForBarInBarChart:(ZEEBarChart *)barChart;

/**
 *  x轴value文本颜色数组(若不设置，则全部返回黑色)
 *
 *  @return 返回UIColor或者NSArray
 *          eg: ①return ZFRed;  若返回UIColor,则全部value文本颜色为红色,当只有一组数据时,只允许返回UIColor
 *              ②return @[ZFRed, ZFOrange, ZFBlue];  若返回数组,则不同类别的bar上的value文本颜色为数组对应下标的颜色
 *
 *          样式看Github文档
 *
 */
- (id)valueTextColorArrayInBarChart:(ZEEBarChart *)barChart;

/**
 *  bar渐变色
 *
 *  (PS: 此方法 与 父类代理方法 - (NSArray *)colorArrayInGenericChart:(ZEEGenericChart *)chart 二选一。若同时实现了这两个方法，则会优先执行渐变色)
 *
 *  @return NSArray必须存储ZFGradientAttribute类型
 */
- (NSArray<ZFGradientAttribute *> *)gradientColorArrayInBarChart:(ZEEBarChart *)barChart;

/**
 *  用于编写点击bar后需要执行后续代码
 *
 *  @param groupIndex   点击的bar在第几组
 *  @param barIndex     点击的bar在该组的下标
 *  @param bar          当前点击的bar对象
 */
- (void)barChart:(ZEEBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex bar:(ZFBar *)bar;

/**
 *  柱状图顶部显示数据
 *
 *  @return NSArray必须存储NSString类型
 *          eg: ①当只有1组数据时，NSArray存储 @[@"1", @"2", @"3", @"4"]
 *              ②当有多组数据时，NSArray存储 @[@[@"1", @"2", @"3", @"4"], @[@"1", @"2", @"3", @"4"]]
 */
- (NSArray *)topTitleArrayInZEEBarChart:(ZEEBarChart *)chart;

@end





@interface ZEEBarChart : ZEEGenericChart

@property (nonatomic, weak) id<ZEEBarChartDelegate> delegate;
/** 是否带阴影效果(默认为YES) */
@property (nonatomic, assign) BOOL isShadow;
/** 超过y轴显示最大值时柱状条bar颜色(默认为红色) */
@property (nonatomic, strong) UIColor * overMaxValueBarColor;


#pragma mark - public method

/**
 *  重绘(每次更新数据后都需要再调一次此方法)
 */
- (void)strokePath;

@end
