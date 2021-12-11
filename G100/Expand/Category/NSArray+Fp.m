//
//  NSArray+Fp.m
//  vmcshop
//
//  Created by bigknife on 14/11/3.
//  Copyright (c) 2014年 idongler. All rights reserved.
//

#import "NSArray+Fp.h"

@implementation NSArray (Fp)
-(NSArray *) mapWithBlock:(id(^)(id item, NSInteger idx))block {
    if (!block) {
        return [NSArray arrayWithArray:self];
    }
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < [self count]; i ++){
        id val = [self objectAtIndex:i];
        id newVal = block(val,i);
		if (newVal) {
			[arr addObject:newVal];
		}

    }
    return  [NSArray arrayWithArray:arr];
}
-(void)initWithBlock:(void(^)(id item, NSInteger idx))block{
    if (block) {
        for (NSInteger i = 0; i < [self count]; i ++) {
            block([self objectAtIndex:i], i);
        }
    }
}

-(void)initWithBlock2:(void(^)(id item, NSInteger idx, NSInteger count))block{
	if (block) {
		NSInteger count = [self count];
		for (NSInteger i = 0; i < count; i ++) {
			block([self objectAtIndex:i], i, count);
		}
	}
}
@end
