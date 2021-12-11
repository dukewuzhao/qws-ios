//
//  MMAppBadgeMonitor.m
//  Msg_remainder
//
//  Created by yuhanle on 2017/5/4.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "MMAppBadgeMonitor.h"

@implementation MMAppBadgeMonitor

- (NSArray *)concernObjects {
    return @[MMMonitorID_WaitPay, MMMonitorID_WaitShenhe, MMMonitorID_History];
}

- (void)setupData {
    [super setupData];
    
    self.monitorid = MMMonitorID_APP;
}

@end
