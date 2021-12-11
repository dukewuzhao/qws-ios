//
//  G100DevFindLostListDomain.m
//  G100
//
//  Created by William on 16/4/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevFindLostListDomain.h"

@implementation G100DevFindLostDomain

@end

@implementation G100DevFindLostListDomain

-(void)setFindlost:(NSArray *)findlost {
    if (NOT_NULL(findlost)) {
        _findlost = [findlost mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DevFindLostDomain alloc]initWithDictionary:item];
            }else{
                return item;
            }
            return nil;
        }];
    }
}

@end
