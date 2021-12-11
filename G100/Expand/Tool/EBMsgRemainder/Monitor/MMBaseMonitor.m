//
//  MMBaseMonitor.m
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/17.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "MMBaseMonitor.h"
#import "MsgRemainderDataController.h"

@interface MMBaseMonitor () {
    BOOL _runFinished;
}

@property (nonatomic, strong) NSMutableArray *msglist;
@property (nonatomic, strong) MsgRemainderDataController *mrdc;

@end

@implementation MMBaseMonitor

- (instancetype)initWithUserid:(NSString *)userid {
    if (self = [super init]) {
        self.userid = userid;
        
        [self setupData];
        [self setupObserver];
    }
    return self;
}

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (self = [super init]) {
        self.userid = userid;
        self.bikeid = bikeid;
        
        [self setupData];
        [self setupObserver];
    }
    return self;
}

#pragma mark - setter
- (void)setMonitorid:(NSString *)monitorid {
    _monitorid = monitorid;
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"MMMonitor" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *config = [NSJSONSerialization JSONObjectWithData:configData options:0 error:nil];
    
    _concernObjects = config[monitorid];
}

- (NSDictionary *)queryParams {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (_userid) {
        [dict setObject:_userid forKey:@"userid"];
    }
    
    if (_bikeid) {
        [dict setObject:_bikeid forKey:@"bikeid"];
    }
    
    if (_devid) {
        [dict setObject:_devid forKey:@"devid"];
    }
    
    return dict.copy;
}

- (void)setupData {
    _runFinished = YES;
    _mrdc = [[MsgRemainderDataController alloc] init];
}

/**
 配置通知中心监听
 */
- (void)setupObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(runMonitor)
                                                 name:kMsgRemainderCenterMsgHandleFinished
                                               object:nil];
}

- (void)runMonitor {
    NSAssert(_monitorid, @"_monitorid 不能为空！！！");
    
    if (!_msglist) {
        _msglist = [[NSMutableArray alloc] init];
    }
    
    if (!_runFinished) {
        return;
    }
    
    _runFinished = NO;
    [self.msglist removeAllObjects];
    
    // 创建组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.tilink.firstConcurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, concurrentQueue, ^{
        // 创建信号量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        // 首先查找到属于自己的 monitorid 的消息
        [[MsgRemainderCenter defaultCenter] searchMsgDataWithMonitorid:self.monitorid data:self.queryParams complete:^(BOOL success, NSArray<MsgRemainderInfo *> *msglist) {
            MsgRemainderInfo *first = [msglist firstObject];
            self.orinalMsg = first.copy;
            [self.msglist addObjectsFromArray:msglist];
            dispatch_semaphore_signal(semaphore);
        }];
        
        // 在任务成功之前，信号量等待中
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_notify(group, concurrentQueue, ^{
        [self finished];
    });
}

- (void)finished {
    // 判断原始消息是否存在关注的其他消息
    if (self.concernObjects.count) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.tilink.twoConcurrent", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_group_async(group, concurrentQueue, ^{
            // 创建信号量
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            [self.mrdc searchDataItemWithMsgids:self.concernObjects dict:self.queryParams complete:^(BOOL success, NSString *userid, NSArray *msglist, NSError *error) {
                [self.msglist addObjectsFromArray:msglist];
                dispatch_semaphore_signal(semaphore);
            }];
            // 在任务成功之前，信号量等待中
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
        
        dispatch_group_notify(group, concurrentQueue, ^{
            MsgRemainderInfo *msginfo = [[MsgRemainderInfo alloc] init];
            if (self.orinalMsg) {
                msginfo = self.orinalMsg.copy;
            } else {
                MsgRemainderInfo *first = [self.msglist firstObject];
                self.orinalMsg = first.copy;
                if (self.orinalMsg) {
                    msginfo = self.orinalMsg.copy;
                }
            }
            
            msginfo.count = 0;
            
            for (MsgRemainderInfo *reslut in self.msglist) {
                /** 等待处理以后清零
                if (reslut.lastupdatetime > msginfo.actiontime || msginfo.actiontime == 0) {
                    msginfo.count += reslut.count;
                }
                 */
                
                msginfo.count += reslut.count;
            }
            
            self.msginfo = msginfo.copy;
            if (self.monitorRes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.monitorRes(msginfo.count, msginfo);
                });
            }
            
            _runFinished = YES;
        });
    } else {
        self.msginfo = self.orinalMsg.copy;
        if (self.monitorRes) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.monitorRes(self.msginfo.count, self.msginfo);
            });
        }
        
        _runFinished = YES;
    }
}

@end
