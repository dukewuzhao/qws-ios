//
//  NSArray+G100Util.m
//  G100
//
//  Created by yuhanle on 16/5/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "NSArray+G100Util.h"

@implementation NSArray (G100Util)

- (id)safe_objectAtIndex:(NSUInteger)index
{
    if (index >= [self count]) {
        return nil;
    }
    
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

@end
