//
//  NSDictionary+G100Util.m
//  G100
//
//  Created by yuhanle on 16/6/20.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "NSDictionary+G100Util.h"

@implementation NSDictionary (G100Util)

- (id)safe_objectForKey:(id)aKey {

    if (!self || !aKey) {
        return nil;
    }
    
    if ([[self allKeys] containsObject:aKey]) {
        return [self objectForKey:aKey];
    }
    return nil;
}

@end
