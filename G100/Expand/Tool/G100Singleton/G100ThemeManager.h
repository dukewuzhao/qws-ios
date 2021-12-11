//
//  G100ThemeManager.h
//  G100
//
//  Created by 温世波 on 15/12/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100ThemeInfoDoamin.h"

@interface G100ThemeManager : NSObject

/**
 *  快速创建主题管理器
 *
 *  @return 主题管理器
 */
+ (instancetype)sharedManager;

/**
 *  根据主题包的url查找主题
 *
 *  @param jsonUrl       主题包的url
 *  @param completeBlock 接口回调
 */
- (void)findThemeInfoDomainWithJsonUrl:(NSString *)jsonUrl completeBlock:(void(^)(G100ThemeInfoDoamin * theme, BOOL success, NSError * error))completeBlock;
/**
 *  根据车辆型号id从指定url的主题包中找到车辆主题
 *
 *  @param modelid       车辆型号id
 *  @param themeUrl      主题包的url
 *  @param completeBlock 接口回调
 */
- (void)findThemeBikeModelWithModelid:(NSInteger )modelid inThemeUrl:(NSString *)themeUrl completeBlock:(void(^)(G100ThemeInfoBikeModel * bikeModel))completeBlock;
/**
 *  根据车辆型号id从主题中找到车辆主题
 *
 *  @param modelid 车辆型号的id
 *  @param theme   主题包
 *
 *  @return 车辆主题
 */
- (G100ThemeInfoBikeModel *)findThemeBikeModelWithModelid:(NSInteger)modelid inTheme:(G100ThemeInfoDoamin *)theme;

@end
