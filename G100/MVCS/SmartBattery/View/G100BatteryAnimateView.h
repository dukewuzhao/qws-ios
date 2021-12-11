//
//  G100BatteryAnimateView.h
//  Demobase
//
//  Created by sunjingjing on 16/12/9.
//  Copyright © 2016年 sunjingjing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100BatteryAnimateView : UIView
/**
 *  百分比
 */
@property (nonatomic, readwrite, assign) CGFloat percent;
/**
 *  前波浪颜色
 */
@property (nonatomic, readwrite, retain) UIColor *frontWaterColor;
/**
 *  后波浪颜色
 */
@property (nonatomic, readwrite, retain) UIColor *backWaterColor;
/**
 *  波浪的背景颜色
 */
@property (nonatomic, readwrite, retain) UIColor *waterBgColor;
/**
    是否在充电中
 */
@property (assign, nonatomic) BOOL isCharging;

@end
