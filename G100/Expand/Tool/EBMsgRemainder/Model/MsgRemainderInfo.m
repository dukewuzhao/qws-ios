//
//  MsgRemainderInfo.m
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/5.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "MsgRemainderInfo.h"

@implementation MsgRemainderInfo

- (id)copyWithZone:(NSZone *)zone {
    MsgRemainderInfo *msginfo = [[[self class] allocWithZone:zone] init];
    msginfo.msgid = self.msgid;
    msginfo.userid = self.userid;
    msginfo.bikeid = self.bikeid;
    msginfo.devid = self.devid;
    msginfo.text = self.text;
    msginfo.icon = self.icon;
    msginfo.count = self.count;
    msginfo.style = self.style;
    msginfo.extra = self.extra;
    msginfo.lastupdatetime = self.lastupdatetime;
    msginfo.actiontime = self.actiontime;
    msginfo.concern = self.concern;
    msginfo.isread = self.isread;
    
    return msginfo;
}

@end
