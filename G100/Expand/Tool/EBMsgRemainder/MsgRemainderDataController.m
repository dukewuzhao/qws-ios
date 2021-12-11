//
//  MsgRemainderDataController.m
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/5.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "MsgRemainderDataController.h"
#import "FMDB.h"
#import "MsgRemainderInfo.h"

NSString *const DBMsgFileName         = @"G100Database.sqlite";
NSString *const MessageRemainderTable = @"t_messageRemainder";
NSString *const MessageRemainderStatusTable = @"t_messageRemainderStatus";

@interface MsgRemainderDataController ()

@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, strong, readonly) FMDatabaseQueue *queue;

@end

@implementation MsgRemainderDataController
@synthesize queue = _queue;
@synthesize dbPath = _dbPath;

#pragma mark - Lazy load
- (FMDatabaseQueue *)queue {
    if (_queue) {
        return _queue;
    }
    return [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
}

- (NSString *)dbPath {
    if (!_dbPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        _dbPath = [path stringByAppendingPathComponent:DBMsgFileName];
    }
    return _dbPath;
}

+ (MsgRemainderDataController *)controller {
    static MsgRemainderDataController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
        [controller createTable];
    });
    return controller;
}

- (void)createTable {
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:MessageRemainderTable]) {
            BOOL result = [db executeUpdate:@"create table if not exists t_messageRemainder (msgid text, userid text, bikeid text, text text, icon text, count integer, style integer, extra blob, lastupdatetime long, actiontime long, isread bool default no, devid text, primary key (msgid, userid, bikeid, devid));"];
            if (result) {
                NSLog(@"消息提醒表创建成功");
            } else {
                NSLog(@"消息提醒表创建失败");
            }
        }
    }];
}

#pragma mark - Public method
- (void)updateDataWithMessageList:(NSArray *)msglist complete:(MsgRemainderComplete)complete {
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL result = NO;
        for (MsgRemainderInfo *msginfo in msglist) {
            FMResultSet *rs = [db executeQuery:@"select * from t_messageRemainder where msgid = ? and userid = ? and bikeid = ? and devid = ?;", msginfo.msgid ? msginfo.msgid : @"0", msginfo.userid ? msginfo.userid : @"0", msginfo.bikeid ? msginfo.bikeid : @"0", msginfo.devid ? msginfo.devid : @"0"];
            
            if (![rs next]) {
                // 不存在则插入
                result = [db executeUpdate:@"insert or ignore into t_messageRemainder (msgid, userid, bikeid, text, icon, count, style, extra, lastupdatetime, actiontime, devid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", msginfo.msgid ? msginfo.msgid : @"0", msginfo.userid ? msginfo.userid : @"0", msginfo.bikeid ? msginfo.bikeid : @"0", msginfo.text, msginfo.icon, [NSNumber numberWithInteger:msginfo.count], [NSNumber numberWithInteger:msginfo.style], msginfo.extra ? [NSJSONSerialization dataWithJSONObject:msginfo.extra options:0 error:nil] : [NSNull null], [NSNumber numberWithLong:msginfo.lastupdatetime], [NSNumber numberWithLong:msginfo.actiontime], msginfo.devid ? msginfo.devid : @"0"];
            } else {
                result = [db executeUpdate:@"update t_messageRemainder set text = ?, icon = ?, count = ?, style = ?, extra = ?, lastupdatetime = ?, actiontime = ? where (msgid = ? and userid = ? and bikeid = ? and devid = ?);", msginfo.text, msginfo.icon, [NSNumber numberWithInteger:msginfo.count], [NSNumber numberWithInteger:msginfo.style], msginfo.extra ? [NSJSONSerialization dataWithJSONObject:msginfo.extra options:0 error:nil] : [NSNull null], [NSNumber numberWithLong:msginfo.lastupdatetime], [NSNumber numberWithLong:msginfo.actiontime], msginfo.msgid ? msginfo.msgid : @"0", msginfo.userid ? msginfo.userid : @"0", msginfo.bikeid ? msginfo.bikeid : @"0", msginfo.devid ? msginfo.devid : @"0"];
            }
            
            [rs close];
        }
        
        if (result) {
            NSLog(@"更新数据成功");
        } else {
            NSLog(@"更新数据失败");
        }
        
        if (complete) {
            complete(result);
        }
    }];
}

- (void)updateDataItemWithMesssge:(MsgRemainderInfo *)msginfo complete:(MsgRemainderComplete)complete {
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = NO;
        FMResultSet *rs = [db executeQuery:@"select * from t_messageRemainder where msgid = ? and userid = ? and bikeid = ? and devid = ?;", msginfo.msgid ? msginfo.msgid : @"0", msginfo.userid ? msginfo.userid : @"0", msginfo.bikeid ? msginfo.bikeid : @"0", msginfo.devid ? msginfo.devid : @"0"];
        
        if (![rs next]) {
            // 不存在则插入
            result = [db executeUpdate:@"insert or ignore into t_messageRemainder (msgid, userid, bikeid, text, icon, count, style, extra, lastupdatetime, actiontime, devid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", msginfo.msgid ? msginfo.msgid : @"0", msginfo.userid ? msginfo.userid : @"0", msginfo.bikeid ? msginfo.bikeid : @"0", msginfo.text, msginfo.icon, [NSNumber numberWithInteger:msginfo.count], [NSNumber numberWithInteger:msginfo.style], msginfo.extra ? [NSJSONSerialization dataWithJSONObject:msginfo.extra options:0 error:nil] : [NSNull null], [NSNumber numberWithLong:msginfo.lastupdatetime], [NSNumber numberWithLong:msginfo.actiontime], msginfo.devid];
        } else {
            result = [db executeUpdate:@"update t_messageRemainder set text = ?, icon = ?, count = ?, style = ?, extra = ?, lastupdatetime = ?, actiontime = ? where (msgid = ? and userid = ? and bikeid = ? and devid = ?);", msginfo.text, msginfo.icon, [NSNumber numberWithInteger:msginfo.count], [NSNumber numberWithInteger:msginfo.style], msginfo.extra ? [NSJSONSerialization dataWithJSONObject:msginfo.extra options:0 error:nil] : [NSNull null], [NSNumber numberWithLong:msginfo.lastupdatetime], [NSNumber numberWithLong:msginfo.actiontime], msginfo.msgid ? msginfo.msgid : @"0", msginfo.userid ? msginfo.userid : @"0", msginfo.bikeid ? msginfo.bikeid : @"0", msginfo.devid ? msginfo.devid : @"0"];
        }
        
        [rs close];
        
        if (result) {
            NSLog(@"更新数据成功");
        } else {
            NSLog(@"更新数据失败");
        }
        
        if (complete) {
            complete(result);
        }
    }];
}

- (void)featchAllDataItemsWithUserid:(NSString *)userid complete:(MsgRemainderFeatchFinishsed)featchFinished {
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select * from t_messageRemainder where userid = ?", userid ? userid : @"0"];
        
        NSMutableArray *msglist = [[NSMutableArray alloc] init];
        while ([rs next]) {
            MsgRemainderInfo *msginfo = [[MsgRemainderInfo alloc] init];
            msginfo.msgid = [rs stringForColumn:@"msgid"];
            msginfo.userid = [rs stringForColumn:@"userid"];
            msginfo.bikeid = [rs stringForColumn:@"bikeid"];
            msginfo.text = [rs stringForColumn:@"text"];
            msginfo.icon = [rs stringForColumn:@"icon"];
            msginfo.count = [rs intForColumn:@"count"];
            msginfo.style = [rs intForColumn:@"style"];
            msginfo.devid = [rs stringForColumn:@"devid"];
            msginfo.extra = [NSJSONSerialization JSONObjectWithData:[rs dataForColumn:@"extra"] options:0 error:nil];
            msginfo.lastupdatetime = [rs longForColumn:@"lastupdatetime"];
            msginfo.actiontime = [rs longForColumn:@"actiontime"];
            
            if (msginfo.lastupdatetime <= msginfo.actiontime) {
                msginfo.isread = YES;
            } else {
                msginfo.isread = NO;
            }
            
            [msglist addObject:msginfo];
        }
        
        if (featchFinished) {
            featchFinished(rs ? YES : NO, userid, msglist, nil);
        }
        
        [rs close];
    }];
}

- (void)searchDataItemWithMsgid:(NSString *)msgid dict:(NSDictionary *)dict complete:(MsgRemainderFeatchFinishsed)featchFinished {
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableString *condition = [NSString stringWithFormat:@"select * from t_messageRemainder where msgid = '%@'", msgid ? msgid : @"0"].mutableCopy;
        for (NSString *key in dict) {
            [condition appendFormat:@" and %@ = '%@'", key, dict[key]];
        }
        
        FMResultSet *rs = [db executeQuery:condition];
        
        NSMutableArray *msglist = [[NSMutableArray alloc] init];
        while ([rs next]) {
            MsgRemainderInfo *msginfo = [[MsgRemainderInfo alloc] init];
            msginfo.msgid = [rs stringForColumn:@"msgid"];
            msginfo.userid = [rs stringForColumn:@"userid"];
            msginfo.bikeid = [rs stringForColumn:@"bikeid"];
            msginfo.text = [rs stringForColumn:@"text"];
            msginfo.icon = [rs stringForColumn:@"icon"];
            msginfo.count = [rs intForColumn:@"count"];
            msginfo.style = [rs intForColumn:@"style"];
            msginfo.devid = [rs stringForColumn:@"devid"];
            msginfo.extra = [NSJSONSerialization JSONObjectWithData:[rs dataForColumn:@"extra"] options:0 error:nil];
            msginfo.lastupdatetime = [rs longForColumn:@"lastupdatetime"];
            msginfo.actiontime = [rs longForColumn:@"actiontime"];
            
            if (msginfo.lastupdatetime <= msginfo.actiontime) {
                msginfo.isread = YES;
            } else {
                msginfo.isread = NO;
            }
            
            [msglist addObject:msginfo];
        }
        
        if (featchFinished) {
            featchFinished(rs ? YES : NO, dict[@"userid"], msglist, nil);
        }
        
        [rs close];
    }];
}

- (void)searchDataItemWithMsgids:(NSArray *)msgids dict:(NSDictionary *)dict complete:(MsgRemainderFeatchFinishsed)featchFinished {
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableString *condition = [NSString stringWithFormat:@"select * from t_messageRemainder where msgid = '%@'", [msgids firstObject] ? [msgids firstObject] : @"0"].mutableCopy;
        
        for (NSString *msgid in msgids) {
            [condition appendFormat:@" or msgid = '%@'", msgid];
        }
        for (NSString *key in dict) {
            [condition appendFormat:@" and %@ = '%@'", key, dict[key]];
        }
        
        FMResultSet *rs = [db executeQuery:condition];
        
        NSMutableArray *msglist = [[NSMutableArray alloc] init];
        while ([rs next]) {
            MsgRemainderInfo *msginfo = [[MsgRemainderInfo alloc] init];
            msginfo.msgid = [rs stringForColumn:@"msgid"];
            msginfo.userid = [rs stringForColumn:@"userid"];
            msginfo.bikeid = [rs stringForColumn:@"bikeid"];
            msginfo.text = [rs stringForColumn:@"text"];
            msginfo.icon = [rs stringForColumn:@"icon"];
            msginfo.count = [rs intForColumn:@"count"];
            msginfo.style = [rs intForColumn:@"style"];
            msginfo.devid = [rs stringForColumn:@"devid"];
            msginfo.extra = [NSJSONSerialization JSONObjectWithData:[rs dataForColumn:@"extra"] options:0 error:nil];
            msginfo.lastupdatetime = [rs longForColumn:@"lastupdatetime"];
            msginfo.actiontime = [rs longForColumn:@"actiontime"];
            
            if (msginfo.lastupdatetime <= msginfo.actiontime) {
                msginfo.isread = YES;
            } else {
                msginfo.isread = NO;
            }
            
            [msglist addObject:msginfo];
        }
        
        if (featchFinished) {
            featchFinished(rs ? YES : NO, dict[@"userid"], msglist, nil);
        }
        
        [rs close];
    }];
}

- (void)deleteDataItemWithMessage:(MsgRemainderInfo *)msg complete:(MsgRemainderComplete)complete {
    //TODO: 待优化
    
}

@end
