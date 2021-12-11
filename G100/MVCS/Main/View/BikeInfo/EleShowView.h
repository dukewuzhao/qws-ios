//
//  EleShowView.h
//  G100
//
//  Created by sunjingjing on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface EleShowView : UIView


@property (assign, nonatomic) float lastPercnet;
/**
 *  根据电量百分比设置View
 *
 *  @param percent 电量百分数
 */
- (void)setViewWithPercent:(float)percent isAnimate:(BOOL)isAnimate;

/**
 *  初始化一个圆弧
 *
 *  @param frame  frame
 *  @param option 动画参数（电量）
 *
 *  @return self
 */
+(instancetype)sharedViewWithFrame:(CGRect)frame option:(NSInteger)option;

@end
