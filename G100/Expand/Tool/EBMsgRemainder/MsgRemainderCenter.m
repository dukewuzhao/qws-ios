//
//  MsgRemainderCenter.m
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/5.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "MsgRemainderCenter.h"
#import "MJExtension.h"
#import "MsgRemainderDataController.h"

NSString * const kMsgRemainderCenterMsgHandleFinished = @"com.tilink.MsgRemainderCenterMsgHandleFinished";

@interface MsgRemainderCenter ()

@property (nonatomic, strong) NSDictionary *map_forRelation;
@property (nonatomic, strong) NSMutableDictionary *map_formsgs;
@property (nonatomic, strong) MsgRemainderDataController *mrdc;

@end

@implementation MsgRemainderCenter

+ (instancetype)defaultCenter {
    static MsgRemainderCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MsgRemainderCenter alloc] init];
        [instance setup];
        [instance prepareData];
    });
    return instance;
}

- (NSMutableDictionary *)map_formsgs {
    if (!_map_formsgs) {
        _map_formsgs = [[NSMutableDictionary alloc] init];
    }
    return _map_formsgs;
}

- (void)setup {
    self.mrdc = [MsgRemainderDataController controller];
}

/**
 准备初始化数据
 */
- (void)prepareData {
    NSString *bundleDemoPath = [[NSBundle mainBundle] pathForResource:@"msgremainder" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:bundleDemoPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    // 生成消息模型
    [self generateModelsWithDict:dict];
}

/**
 生成消息模型
 */
- (void)generateModelsWithDict:(NSDictionary *)dict {
    NSArray *msglist = [dict objectForKey:@"msglist"];
    NSMutableArray *msgs = [[NSMutableArray alloc] initWithCapacity:msglist.count];
    
    // 将其中的数据剥离出来 整理成为我们所需要的结构
    for (NSDictionary *msginfo in msglist) {
        MsgRemainderInfo *rminfo = [[MsgRemainderInfo alloc] init];
        [rminfo mj_setKeyValues:msginfo];
        [rminfo mj_setKeyValues:msginfo[@"msg"]];
        rminfo.lastupdatetime = [msginfo[@"lastupdatetime"] integerValue];
        rminfo.userid = dict[@"userid"];
        [msgs addObject:rminfo];
    }
    
    // 将消息更新或写入数据库
    [self.mrdc updateDataWithMessageList:msgs complete:^(BOOL success) {
        NSLog(@"写入结果");
    }];
}

- (void)searchMsgDataWithMonitorid:(NSString *)monitorid data:(NSDictionary *)data complete:(MsgRemainderCenterSearchComplete)complete {
    [self.mrdc searchDataItemWithMsgid:monitorid dict:data complete:^(BOOL success, NSString *userid, NSArray *msglist, NSError *error) {
        if (complete) {
            complete(success, msglist);
        }
    }];
}

- (void)newMsgDataWithMonitor:(NSString *)monitorid msginfo:(MsgRemainderInfo *)msginfo {
    if (!msginfo) {
        return;
    }
    
    msginfo.msgid = monitorid;
    msginfo.count++;
    msginfo.lastupdatetime = [[NSDate date] timeIntervalSince1970];
    
    [self.mrdc updateDataItemWithMesssge:msginfo complete:^(BOOL success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgRemainderCenterMsgHandleFinished object:nil];
    }];
}

- (void)readMsgDataWithMonitor:(NSString *)monitorid msginfo:(MsgRemainderInfo *)msginfo {
    if (!msginfo) {
        return;
    }
    
    msginfo.msgid = monitorid;
    msginfo.count = 0;
    msginfo.actiontime = [[NSDate date] timeIntervalSince1970];
    
    [self.mrdc updateDataItemWithMesssge:msginfo complete:^(BOOL success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgRemainderCenterMsgHandleFinished object:nil];
    }];
}

@end
