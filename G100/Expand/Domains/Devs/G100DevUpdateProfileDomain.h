//
//  G100DevUpdateProfileDomain.h
//  G100
//
//  Created by William on 16/4/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevUpdateProfileDomain : G100BaseDomain
/** 车辆图片 */
@property (nonatomic, copy) NSArray * picture;
/** 完整度 */
@property (nonatomic, assign) NSInteger featureintegrity;

@end
