//
//  G100ActivityDomain.h
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

/**
 *  活动卡片
 *
 */
@interface G100ActivityDomain : G100BaseDomain

/** 活动名称*/
@property (nonatomic, copy) NSString *name;
/** 活动代码*/
@property (nonatomic, copy) NSString *activity_code;
/** 开始时间*/
@property (nonatomic, copy) NSString *begin_time;
/** 结束时间*/
@property (nonatomic, copy) NSString *end_time;
/** 活动图片*/
@property (nonatomic, copy) NSString *picture;
/** 活动链接url*/
@property (nonatomic, copy) NSString *url;
/** 活动id*/
@property (nonatomic, assign) NSInteger activity_id;
/** 活动类型 1保险*/
@property (nonatomic, assign) NSInteger type;

@end

/**
 *  首页活动卡片右上角的提示按钮
 *
 */
@interface G100ActivityPrompt : G100BaseDomain

/** 提示id*/
@property (nonatomic, assign) NSInteger prompt_id;
/** 类型*/
@property (nonatomic, assign) NSInteger type;
/** 提示文案*/
@property (nonatomic, copy) NSString *desc;
/** 点击链接url*/
@property (nonatomic, copy) NSString *url;

@end
