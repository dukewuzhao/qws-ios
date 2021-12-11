//
//  NSArray+Fp.h
//  vmcshop
//
//  Created by bigknife on 14/11/3.
//  Copyright (c) 2014年 idongler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Fp)
-(NSArray *) mapWithBlock:(id(^)(id item, NSInteger idx))block;
-(void)initWithBlock:(void(^)(id item, NSInteger idx))block;
-(void)initWithBlock2:(void(^)(id item, NSInteger idx, NSInteger count))block;
@end
