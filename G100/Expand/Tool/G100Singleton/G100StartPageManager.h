//
//  G100StartPageManager.h
//  G100
//
//  Created by 温世波 on 15/12/15.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100StartPageDomain.h"

@interface G100StartPageManager : NSObject

@property (nonatomic, strong) NSArray * pageList; //!< 启动图列表

+ (instancetype)sharedInstance;

/**
 *  本次启动需要展示的界面 若返回nil 则跳过 否则展示
 *
 *  @return 本次启动需要展示的启动页模型
 */
- (G100StartPageDomain *)loadStartPageDomain;

/**
 更新广告图

 @param location 用户定位
 */
- (void)updateAdPageList:(NSString *)location;

@end
