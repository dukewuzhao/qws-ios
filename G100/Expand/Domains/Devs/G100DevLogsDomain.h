//
//  G100DevLogsDomain.h
//  G100
//
//  Created by Tilink on 15/5/17.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevLogsDomain : G100BaseDomain

/** 日志内容 */
@property (copy, nonatomic) NSString * msg;
/** 日志标题 */
@property (copy, nonatomic) NSString * title;
/** 日志类型 */
@property (assign, nonatomic) NSInteger type;
/** 日志时间 */
@property (copy, nonatomic) NSString * ts;

@end
