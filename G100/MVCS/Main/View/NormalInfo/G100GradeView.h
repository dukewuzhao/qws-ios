//
//  SYCompassView.h
//  SYCompassDemo
//
//  Created by 陈蜜 on 16/6/27.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PercentShowView.h"
@interface G100GradeView : UIView

/**
 *  以上次检测状态初始化View
 *
 *  @param rect   圆外矩形
 *  @param option 上次检测状态模型
 *
 *  @return self
 */
+ (instancetype)sharedWithFrame:(CGRect)rect option:(id)option;

/**
 *  刻度的底层颜色
 */
@property (nonatomic, strong) UIColor *calibrationColor;

/**
 *  刻度的着色（白色）
 */
@property (strong, nonatomic) UIColor *calibrationTinkColor;
/**
 *  车辆检测数据模型
 */
@property (strong, nonatomic) id option;

/**
 *  上次检测分数
 */
@property (assign, nonatomic) NSInteger grade;

/**
 *  分数显示View
 */
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) PercentShowView *percentView;
/**
 *  根据分数改变View
 *
 *  @param percent 检测的分数
 */
- (void)setGradeViewWithGrade:(float)grade isAnimation:(BOOL)animate;

@end
