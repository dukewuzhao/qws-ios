//
//  G100EventDomain.m
//  G100
//
//  Created by William on 16/2/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100EventDomain.h"

@implementation G100EventDetailDomain

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"poster_url" : @"post_url"};
}

- (BOOL)isInValidEvent {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    
    if (self.begintime) {
        NSDate * begintime = [formatter dateFromString:self.begintime];
        NSDate * date = [NSDate date];
        
        if ([begintime isLaterThanDate:date]) {
            return NO;
        }
    }
    
    if (self.endtime) {
        NSDate * endtime = [formatter dateFromString:self.endtime];
        NSDate * date = [NSDate date];
        
        if ([endtime isEarlierThanDate:date]) {
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation G100EventDomain

-(void)setEvents:(NSArray *)events {
    if (NOT_NULL(events)) {
        _events = [events mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100EventDetailDomain alloc] initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100EventDetailDomain)) {
                return item;
            }
            return nil;
        }];
    }
}

- (G100EventDetailDomain *)firstPosterEventDetail {
    for (G100EventDetailDomain *detail in self.events) {
        if (detail.type == 2 && [detail isInValidEvent] && detail.control.poster) {
            return detail;
        }
    }
    return nil;
}

@end

@implementation G100EventControl

@end
