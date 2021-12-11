//
//  G100BikeUsersDomain.m
//  G100
//
//  Created by yuhanle on 16/9/19.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeUsersDomain.h"
#import "G100UserDomain.h"

@implementation G100BikeUsersDomain

- (void)setBikeusers:(NSArray<G100UserDomain *> *)bikeusers {
    if (NOT_NULL(bikeusers)) {
        _bikeusers = [bikeusers mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100UserDomain alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100UserDomain)){
                return item;
            }
            return nil;
        }];
    }
}

- (void)setAuditing:(NSArray<G100UserDomain *> *)auditing {
    if (NOT_NULL(auditing)) {
        _auditing = [auditing mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100UserDomain alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100UserDomain)){
                return item;
            }
            return nil;
        }];
    }
}

@end
