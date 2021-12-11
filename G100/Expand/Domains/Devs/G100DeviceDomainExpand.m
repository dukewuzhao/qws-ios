//
//  G100DeviceDomainExpand.m
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100DeviceDomainExpand.h"

@implementation G100DevAlertorStatus

@end

@implementation G100DeviceDomainExpand

@end

@implementation G100DevBindResultDomain

@end

@implementation G100DevAlarmPushWx

@end

@implementation G100DevAlarmPushPhone

- (NSString *)calleenum {
    if (!_calleenum.length) {
        // 如果不存在该字段 则返回当前帐号的手机号
        return [[CurrentUser sharedInfo] phonenum];
    }
    return _calleenum;
}

@end

@implementation G100DevAlertorSound

- (void)setSounds:(NSArray<G100DevAlertorSoundFunc *> *)sounds {
    if (NOT_NULL(sounds)) {
        _sounds = [sounds mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DevAlertorSoundFunc alloc]initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100DevAlertorSoundFunc)){
                return item;
            }
            return nil;
        }];
    }
}

@end

@implementation G100DevAlertorSoundFunc

- (NSString *)funcName {
    if (self.func == 1) return @"撤防";
    if (self.func == 2) return @"设防";
    if (self.func == 3) return @"寻车";
    if (self.func == 4) return @"轻微报警";
    if (self.func == 5) return @"严重报警";
    return @"";
}
- (NSString *)soundDisplayName {
    if (self.sound == 0) return @"无";
    if (self.sound == 1) return @"舒缓音";
    if (self.sound == 2) return @"普通音";
    return @"";
}
- (NSString *)soundName {
    return [self soundNameWithFunc:self.func sound:self.sound];
}

- (NSString *)soundNameWithFunc:(NSInteger)func sound:(NSInteger)sound {
    if (func == 1) {
        if (sound == 0) return @"";
        if (sound == 1) return @"撤防-小牛音0";
        if (sound == 2) return @"撤防-普通报警音0";
    }
    if (func == 2) {
        if (sound == 0) return @"";
        if (sound == 1) return @"设防-小牛音0";
        if (sound == 2) return @"设防-普通报警音0";
    }
    if (func == 3) {
        if (sound == 0) return @"";
        if (sound == 1) return @"寻车-小牛音0";
        if (sound == 2) return @"寻车-普通报警音0";
    }
    if (func == 4) {
        if (sound == 0) return @"";
        if (sound == 1) return @"报警音-小牛音0";
        if (sound == 2) return @"低报警-普通报警音0";
    }
    if (func == 5) {
        if (sound == 0) return @"";
        if (sound == 1) return @"报警音-小牛音0";
        if (sound == 2) return @"高报警-普通报警音0";
    }
    
    return @"";
}

@end

@implementation G100DevFirmDomain

@end
