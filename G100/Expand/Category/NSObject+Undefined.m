//
//  NSObject+DHF.m
//  FreeApp
//
//  Created by yuhanle on 14-6-10.
//  Copyright (c) 2014年 tilink. All rights reserved.
//

#import "NSObject+Undefined.h"
#import <objc/runtime.h>

@implementation NSObject (Undefined)

/**
 *  重写setValue:forUndefinedKey: 防止因为设置未定义属性导致错误
 *
 *  @param value id value
 *  @param key   string key
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    IDLog(IDLogTypeWarning, @"Undefined: key %@ is not existed in class or class mapping %@", key, [self class]);
}

/**
 *  重写未定义属性的返回方法
 *
 *  @param key 未定义的key
 *
 *  @return nil
 */
- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end
