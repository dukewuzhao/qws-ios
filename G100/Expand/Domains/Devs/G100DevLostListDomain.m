//
//  G100DevLostListDomain.m
//  G100
//
//  Created by William on 16/4/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevLostListDomain.h"

@implementation G100DevLostDomain

- (NSInteger)shareid {
    NSInteger count = _shareids.count;
    if (!count) {
        return 0;
    }
    if (_status == 1) {
        // 寻车分享
        if (count>0)
            return [_shareids[0] integerValue];
    }else if (_status == 2) {
        // 找到分享
        if (count>1)
            return [_shareids[1] integerValue];
    }else if (_status == 4) {
        // 理赔分享
        if (count>2)
            return [_shareids[2] integerValue];
    }
    return 0;
}

@end

@implementation G100DevLostListDomain

-(void)setLost:(NSArray *)lost {
    if (NOT_NULL(lost)) {
        _lost = [lost mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DevLostDomain alloc]initWithDictionary:item];
            }else{
                return item;
            }
            return nil;
        }];
    }
}

@end
