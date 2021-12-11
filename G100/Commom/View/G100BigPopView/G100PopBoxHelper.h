//
//  G100PopBoxHelper.h
//  G100
//
//  Created by Tilink on 15/8/13.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

/**
 *  管理pop框  
 *  用户点击忽略或查看时  同步移除其他类似信息
 */

#import <Foundation/Foundation.h>

@class G100PopView;
@interface G100PopBoxHelper : NSObject

+ (instancetype)sharedInstance;

 /**
 *  开始启动 pop框管理器
 */
- (void)startupPopBoxService;

/**
 *  停止pop 框管理器
 */
- (void)stopPopBoxService;

/**
 *  新增一个新弹出的 pop框
 *
 *  @param popView popView 实例
 */
- (void)addNewPopView:(G100PopView *)popView;

/**
 *  移除当前显示的 pop框 同时移除相同类型的
 *
 *  @param popView popView 实例
 */
- (void)removeOldPopView:(G100PopView *)popView;

/**
 移除显示的所有 pop 框
 */
- (void)removeAllPopView;

@end
