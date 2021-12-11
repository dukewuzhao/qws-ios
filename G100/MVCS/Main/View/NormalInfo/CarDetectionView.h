//
//  CarDetectionView.h
//  G100
//
//  Created by sunjingjing on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "G100CardBaseView.h"

#import "G100GradeView.h"
#import "G100ClickEffectView.h"
@interface CarDetectionView : G100CardBaseView

/**
 *  车辆检测日期
 */
@property (weak, nonatomic) IBOutlet UILabel *detectionDate;


/**
 *  车辆状态描述
 */
@property (weak, nonatomic) IBOutlet UILabel *carState;

/**
 *  上层View
 */
@property (weak, nonatomic) IBOutlet UIView *topView;

/**
 *  下层View
 */
@property (weak, nonatomic) IBOutlet UIView *lowView;

/**
 *  车辆检测分数背景View
 */
@property (weak, nonatomic) IBOutlet UIView *gradeView;

/**
 *  分数动画View
 */
@property (strong, nonatomic) G100GradeView *graView;

/**
 *  背景图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

/**
 *  上层动画View
 */

@property (weak, nonatomic) IBOutlet G100ClickEffectView *clickedAniView;


@property (strong, nonatomic) G100TestResultDomain *tesultDomain;
/**
 *  根据检测分数变化调整背景色
 *
 *  @param temperature 体检分数
 */
- (void)setBackgroundWithGrade:(NSInteger)grade;

/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;

/**
 *  拿到测试结果后开始执行动画
 *
 *  @param tesultDomain 评分结果
 */
- (void)beginAnimateWithParameter:(G100TestResultDomain *)tesultDomain isAnimate:(BOOL)isAnimate;

@end
