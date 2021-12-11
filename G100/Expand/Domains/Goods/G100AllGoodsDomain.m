//
//  G100AllGoodsDomain.m
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100AllGoodsDomain.h"

@implementation G100AllGoodsDomain

-(void)setProds:(NSArray *)prods {
    if (NOT_NULL(prods)) {
        _prods = [prods mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100GoodDomain alloc]initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100GoodDomain)){
                return item;
        }
            return nil;
        }];
    }
}

@end
