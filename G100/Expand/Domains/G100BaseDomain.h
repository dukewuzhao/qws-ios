//
//  G100BaseDomain.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"
#import "NSArray+Fp.h"
#import "RMMapper.h"

@interface G100BaseDomain : NSObject

/**
 *  通过字典初始化模型
 *
 *  @param dict 字典
 *
 *  @return 模型实例
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 *  通过字典给模型复制
 *
 *  @param dict 字典
 */
- (void)setValuesForKeysWith_MyDict:(NSDictionary *)dict;

@end

@interface NSObject (TLKeyValue)

/**
 *  处理服务器返回的特殊json字符串
 *
 *  @return 对应的字典
 */
- (NSDictionary *)tl_specialJSONObject;

@end
