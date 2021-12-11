//
//  G100BaseGroup.h
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100BaseGroup : NSObject
/**
 *  头部标题
 */
@property (nonatomic, copy) NSString * header;
/**
 *  尾部标题
 */
@property (nonatomic, copy) NSString * footer;
/**
 *  存放着这组所有行的模型数据(这个数组中都是MJSettingItem对象)
 */
@property (nonatomic, strong) NSArray * items;

@end
