//
//  G100BikesRuntimeDomain.m
//  G100
//
//  Created by William on 16/8/19.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikesRuntimeDomain.h"

@implementation G100BikesRuntimeDomain

- (void)setRuntime:(NSArray <G100BikeRuntimeDomain *>*)runtime {
    if (NOT_NULL(runtime)) {
        _runtime = [runtime mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100BikeRuntimeDomain alloc]initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100BikeRuntimeDomain)){
                return item;
            }
            return nil;
        }];
    }
}

@end


@implementation G100BikeRuntimeDomain
/*
- (void)setDevice_runtimes:(NSArray *)device_runtimes {
    if (NOT_NULL(device_runtimes)) {
        _device_runtimes = [device_runtimes mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DeviceRuntimeDomain alloc]initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100DeviceRuntimeDomain)){
                return item;
            }
            return nil;
        }];
    }
}
 */

@end


@implementation G100DeviceRuntimeDomain

@end
