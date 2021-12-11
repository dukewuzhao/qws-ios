//
//  G100SearchHelper.h
//  G100
//
//  Created by 天奕 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Max_Search_Result_Num 10

extern NSString * const kGXSearchResult;

@interface G100SearchHelper : NSObject

/**
 *  本地数据 统一单例
 *
 *  @return 单例对象
 */
+(instancetype)shareInstance;

-(void)setSearchResultArray:(NSArray *)searchResultArray key:(NSString *)key;

- (NSArray *)searchResultArrayWithKey:(NSString *)key;

/**
 *  更新搜索历史记录
 *
 *  @param key    key
 *  @param result 搜索结果
 */
- (void)updateSearchResultWithKey:(NSString *)key andResult:(NSString *)result;

/**
 *  清除搜索结果
 *
 *  @param key key
 */
- (void)removeSearchResultWithKey:(NSString *)key;

@end
