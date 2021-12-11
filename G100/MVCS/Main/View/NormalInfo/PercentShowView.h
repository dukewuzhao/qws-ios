//
//  PercentShowView.h
//  G100
//
//  Created by sunjingjing on 16/7/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PercentShowView : UIView


@property (assign, nonatomic) NSInteger percent;


+ (instancetype)showView;

/**
 *  根据参数改变约束并添加对应数字
 *
 *  @param percent 分数/百分比
 */
-(void)setPercentAnimateWithPercent:(NSInteger)percent;

@end
