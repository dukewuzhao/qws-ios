//
//  G100BikeHisTrackDomain.m
//  G100
//
//  Created by yuhanle on 2017/8/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeHisTrackDomain.h"

@implementation G100BikeHisTracksDomain

- (void)setLoc:(NSArray<G100BikeHisTrackDomain *> *)loc {
    if (NOT_NULL(loc)) {
        _loc = [loc mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100BikeHisTrackDomain alloc] initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100BikeHisTrackDomain)){
                return item;
            }
            return nil;
        }];
    }
}

@end

@implementation G100BikeHisTrackDomain

@end
@implementation G100BikeHisSummaryDomain
@end
