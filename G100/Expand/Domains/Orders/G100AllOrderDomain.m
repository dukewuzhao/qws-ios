//
//  G100AllOrderDomain.m
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100AllOrderDomain.h"

@implementation G100AllOrderDomain

-(void)setOrders:(NSArray *)orders {
    if (NOT_NULL(orders)) {
        _orders = [orders mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100OrderDomain alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100OrderDomain)){
                return item;
            }
            return nil;
        }];
    }
}

@end
