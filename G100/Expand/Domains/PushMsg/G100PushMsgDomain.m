//
//  G100PushMsgDomain.m
//  G100
//
//  Created by Tilink on 15/5/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PushMsgDomain.h"

@implementation G100PushMsgDomain

-(void)setAps:(NSDictionary *)aps {
    if (NOT_NULL(aps)) {
        if (!NOT_NULL(_apsdomain)) {
            self.apsdomain = [[G100ApsMsgDomain alloc]initWithDictionary:aps];
        }
    }
}

- (NSString *)bikeid {
    if (!_bikeid) {
        _bikeid = self.devid;
    }
    return _bikeid;
}

@end
