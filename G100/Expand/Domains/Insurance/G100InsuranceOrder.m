//
//  G100InsuranceOrder.m
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100InsuranceOrder.h"

@implementation G100InsuranceStatusPacks

- (void)setList:(NSArray<G100InsuranceStatusPack *> *)list {
    if (NOT_NULL(list)) {
        _list = [list mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, G100InsuranceStatusPack)) {
                return item;
            }else {
                return [[G100InsuranceStatusPack alloc] initWithDictionary:item];
            }
        }];
    }
}

@end

@implementation G100InsuranceStatusPack

- (void)setOrderlist:(NSArray<G100InsuranceOrder *> *)orderlist {
    if (NOT_NULL(orderlist)) {
        _orderlist = [orderlist mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, G100InsuranceOrder)) {
                return item;
            }else {
                return [[G100InsuranceOrder alloc] initWithDictionary:item];
            }
        }];
    }
}

@end

@implementation G100InsuranceOrder

@end
