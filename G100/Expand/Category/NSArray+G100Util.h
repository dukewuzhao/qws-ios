//
//  NSArray+G100Util.h
//  G100
//
//  Created by yuhanle on 16/5/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (G100Util)

/*!
 @method    objectAtIndexCheck:
 @abstract  检查是否越界和NSNull如果是返回nil
 @result    返回对象
 */
- (id)safe_objectAtIndex:(NSUInteger)index;

@end
