//
//  G100TestResultDomain.h
//  G100
//
//  Created by Tilink on 15/5/23.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100TestResultDomain : G100BaseDomain

/** 检测结果所属用户id */
@property (copy, nonatomic) NSString * userid;
/** 检测车辆id */
@property (copy, nonatomic) NSString * devid;
/** 最后一次检测时间 */
@property (copy, nonatomic) NSString * lastTestTime;
/** 最后一次检测分数 */
@property (assign, nonatomic) NSInteger score;
/** 最后一次检测待优化项 */
@property (strong, nonatomic) NSArray * waitSetBetter;
/** 测试结果显示文案 */
@property (strong, nonatomic) NSString * testResultHint;
/** 测试结果问题文案类型 */
@property (assign, nonatomic) NSInteger showType;

@end
