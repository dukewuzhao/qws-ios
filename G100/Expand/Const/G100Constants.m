//
//  G100Constants.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Constants.h"

//############################# API     #############################
const NSInteger kApiPageStart = 1;
const NSInteger kApiPageSize = 10;

//############################# TIME CONSTANT ########################
const NSTimeInterval kVMCToastDuration = 3;
const NSTimeInterval kAnimationDuration = 0.3;
const NSTimeInterval G100VCodeDuration = 60;

//############################# 安全评分  #############################
const NSInteger MAX_COLOR = 120;	//绿色
const NSInteger MIN_COLOR = 0;		//红色
const NSInteger MAX_SCORE = 100;
const NSInteger MIN_SCORE = 50;

const CGFloat mRate = (CGFloat)(MAX_COLOR-MIN_COLOR) / (MAX_SCORE-MIN_SCORE);

//############################# 网络错误提示     #############################
NSString * kError_Network_NotReachable = @"请检查您的网络设置";

@implementation G100Constants

@end
