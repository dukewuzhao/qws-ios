//
//  NSDictionary+G100Util.h
//  G100
//
//  Created by yuhanle on 16/6/20.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (G100Util)

/**
 *  安全返回字典存储的内容
 *
 *  @param aKey key
 *
 *  @return key对应的数据
 */
- (id)safe_objectForKey:(id)aKey;

@end
