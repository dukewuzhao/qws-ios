//
//  DatabaseOperation.m
//  G100
//
//  Created by yuhanle on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DatabaseOperationV1.h"
#import "FMDB.h"
#import "DBMigration.h"
#import "G100MsgDomain.h"

#define kImageUrl   @"http://ovsmr3xhj.bkt.clouddn.com/%@.jpg<img>"

NSString *const DBFileName         = @"G100Database.sqlite";
NSString *const MessageCenterTable = @"t_messageCenter";
NSString *const MessageCenterStatusTable = @"t_messageStatusCenter";

@interface DatabaseOperationV1()

@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, strong, readonly) FMDatabaseQueue *queue;

@end

@implementation DatabaseOperationV1
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
        NSString *path = [paths safe_objectAtIndex:0];
        _dbPath = [path stringByAppendingPathComponent:DBFileName];
    }
    return _dbPath;
}

+ (DatabaseOperationV1 *)operation {
    static DatabaseOperationV1 *DBOperation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DBOperation = [[self alloc] init];
    });
    return DBOperation;
}
+ (void)createTable {
    DatabaseOperationV1 *op = [DatabaseOperationV1 operation];
    [op.queue inDatabase:^(FMDatabase *db) {
        BOOL result = NO;
        if (![db tableExists:MessageCenterTable]) {
            result = [db executeUpdate:@"create table t_messageCenter (msgid TEXT PRIMARY KEY UNIQUE, userid INTEGER, devid TEXT, msgtype INTEGER, mctitle TEXT, mcdesc TEXT, mcurl TEXT, mcts LONG, isread BOOL DEFAULT NO);"];
            if (result) {
                DLog(@"消息中心表 建表成功");
            }else {
                DLog(@"消息中心表 建表失败");
            }
        }
    }];
    
    [op.queue inDatabase:^(FMDatabase *db) {
        BOOL result = NO;
        if (![db tableExists:MessageCenterStatusTable]) {
            result = [db executeUpdate:@"create table t_messageStatusCenter (msgid TEXT, userid INTEGER, isread BOOL DEFAULT NO, isdelete BOOL DEFAULT NO, PRIMARY KEY (msgid, userid));"];
            if (result) {
                DLog(@"消息状态表 建表成功");
            }else {
                DLog(@"消息状态表 建表失败");
            }
            
            // 如果不存在新的状态表 将旧表的数据迁移至新表
            [op.queue inDatabase:^(FMDatabase *db) {
                FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageCenter ORDER BY mcts DESC;"];
                while ([rs next]) {
                    G100MsgDomain * model = [[G100MsgDomain alloc] init];
                    model.msgid   = [rs stringForColumn:@"msgid"];
                    model.userid  = [rs intForColumn:@"userid"];
                    model.hasRead = [rs boolForColumn:@"isread"];
                    
                    FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:model.userid], model.msgid];
                    
                    if (![rs1 next]) {
                        BOOL result1 = [db executeUpdate:@"insert or ignore into t_messageStatusCenter (msgid, userid, isread, isdelete) values (?, ?, ?, ?);", model.msgid, [NSNumber numberWithInteger:model.userid], [NSNumber numberWithBool:model.hasRead], [NSNumber numberWithBool:NO]];
                        
                        if (result && result1) {
                            DLog(@"插入成功");
                        }else {
                            DLog(@"插入失败");
                        }
                    }
                    
                    [rs1 close];
                }
                
                [rs close];
            }];
        }
    }];
    
    // 消息数据库迁移
    [op dbMigration];
    // 测试数据
    //[op setupTestData];
}

#pragma mark - 数据库迁移
- (void)dbMigration {
    FMDBMigrationManager *manager = [FMDBMigrationManager managerWithDatabaseAtPath:self.dbPath migrationsBundle:[NSBundle mainBundle]];
    
    DBMigration *migration_1 = [[DBMigration alloc] initWithName:@"t_messageCenter 表新增字段bikeid"
                                                      andVersion:1
                                           andExecuteUpdateArray:@[@"alter table t_messageCenter add bikeid text"]];
    DBMigration *migration_2 = [[DBMigration alloc] initWithName:@"t_messageCenter 表新增字段deviceid"
                                                      andVersion:2
                                           andExecuteUpdateArray:@[@"alter table t_messageCenter add deviceid text"]];
    
    [manager addMigration:migration_1];
    [manager addMigration:migration_2];
    
    BOOL resultState = NO;
    NSError *error = nil;
    if (!manager.hasMigrationsTable) {
        resultState = [manager createMigrationsTable:&error];
    }
    
    resultState = [manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
}

#pragma mark - 增 删 改 查
- (void)insertDatabaseWithMsg:(G100MsgDomain *)msg success:(void (^)(BOOL))block {
    [self msgIsExistWithMsg:msg complete:^(FMDatabase *db, BOOL exist) {
        if (exist) {
            BOOL result = [db executeUpdate:@"update t_messageCenter set userid = ?, bikeid = ?, deviceid = ?, devid = ?, msgtype = ?, mctitle = ?, mcdesc = ?, mcurl = ?, mcts = ? WHERE msgid = ?;", [NSNumber numberWithInteger:msg.userid], msg.bikeid, msg.deviceid, msg.devid, [NSNumber numberWithInteger:msg.msgtype], msg.mctitle, msg.mcdesc, msg.mcurl, [NSNumber numberWithLong:msg.mcts], msg.msgid];
            if (result) {
                DLog(@"更新成功");
            }else {
                DLog(@"更新失败");
            }
            
            if(block){
                block(result);
            }
        }else {
            BOOL result = [db executeUpdate:@"insert or ignore into t_messageCenter (msgid, userid, bikeid, deviceid, devid, msgtype, mctitle, mcdesc, mcurl, mcts, isread) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", msg.msgid, [NSNumber numberWithInteger:msg.userid], msg.bikeid, msg.deviceid, msg.devid, [NSNumber numberWithInteger:msg.msgtype], msg.mctitle, msg.mcdesc, msg.mcurl, [NSNumber numberWithLong:msg.mcts], [NSNumber numberWithBool:msg.hasRead]];
            
            BOOL result1 = [db executeUpdate:@"insert or ignore into t_messageStatusCenter (msgid, userid, isread, isdelete) values (?, ?, ?, ?);", msg.msgid, [NSNumber numberWithInteger:msg.userid], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO]];
            
            if (result && result1) {
                DLog(@"插入成功");
            }else {
                DLog(@"插入失败");
            }
            
            if (block) {
                block(result);
            }
        }
    }];
}

- (void)updateDatabaseWithMsg:(G100MsgDomain *)msg success:(void (^)(BOOL))block {
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"update t_messageCenter set userid = ?, bikeid = ?, deviceid = ?, devid = ?, msgtype = ?, mctitle = ?, mcdesc = ?, mcurl = ?, mcts = ? WHERE msgid = ?;", [NSNumber numberWithInteger:msg.userid], msg.bikeid, msg.deviceid, msg.devid, [NSNumber numberWithInteger:msg.msgtype], msg.mctitle, msg.mcdesc, msg.mcurl, [NSNumber numberWithLong:msg.mcts], msg.msgid];
        if (result) {
            DLog(@"更新成功");
        }else {
            DLog(@"更新失败");
        }
        
        if(block){
            block(result);
        }
    }];
}

- (void)hasReadMsgWithMsg:(G100MsgDomain *)msg success:(void (^)(BOOL))block {
    [self msgIsExistWithMsg:msg complete:^(FMDatabase *db, BOOL exist) {
        if (exist) {
            BOOL result = [db executeUpdate:@"update t_messageCenter set isread = ? WHERE (msgid = ? AND userid = ?);", [NSNumber numberWithBool:YES], msg.msgid, [NSNumber numberWithInteger:msg.userid]];
            
            // 标记消息为删除状态 并非物理删除
            BOOL result1 = NO;
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:msg.userid], msg.msgid];
            
            if ([rs next]) {
                // 更新
                result1 = [db executeUpdate:@"update t_messageStatusCenter set isread = ? WHERE (msgid = ? AND userid = ?);", [NSNumber numberWithBool:YES], msg.msgid, [NSNumber numberWithInteger:msg.userid]];
            }else {
                // 插入
                result = [db executeUpdate:@"insert or ignore into t_messageStatusCenter (msgid, userid, isread, isdelete) values (?, ?, ?, ?);", msg.msgid, [NSNumber numberWithInteger:msg.userid], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]];
            }
            
            [rs close];
            
            if (result && result1) {
                DLog(@"已读成功");
            }else {
                DLog(@"已读失败");
            }
            if (block) {
                block(result);
            }
        }else {
            BOOL result = [db executeUpdate:@"insert or ignore into t_messageCenter (msgid, userid, bikeid, deviceid, devid, msgtype, mctitle, mcdesc, mcurl, mcts, isread) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", msg.msgid, [NSNumber numberWithInteger:msg.userid], msg.bikeid, msg.deviceid, msg.devid, [NSNumber numberWithInteger:msg.msgtype], msg.mctitle, msg.mcdesc, msg.mcurl, [NSNumber numberWithLong:msg.mcts], [NSNumber numberWithBool:YES]];
            
            BOOL result1 = [db executeUpdate:@"insert or ignore into t_messageStatusCenter (msgid, userid, isread, isdelete) values (?, ?, ?, ?);", msg.msgid, [NSNumber numberWithInteger:msg.userid], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]];
            
            if (result && result1) {
                DLog(@"插入成功");
            }else {
                DLog(@"插入失败");
            }
            
            if (block) {
                block(result);
            }
        }
    }];
}

- (void)fetchAllDataWithUserid:(NSInteger)userid completion:(void (^)(NSMutableArray *, NSMutableArray *))block {
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableArray * arr1 = [NSMutableArray array];
        NSMutableArray * arr2 = [NSMutableArray array];
        
        // 如果userid > 0 则取出userid = 0 的消息
        if (userid > 0) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageCenter WHERE (userid = ? OR userid = ?) ORDER BY mcts DESC;", [NSNumber numberWithInteger:userid], [NSNumber numberWithInteger:0]];
            while ([rs next]) {
                G100MsgDomain * model = [[G100MsgDomain alloc] init];
                model.msgid   = [rs stringForColumn:@"msgid"];
                model.userid  = [rs intForColumn:@"userid"];
                model.bikeid  = [rs stringForColumn:@"bikeid"];
                model.deviceid= [rs stringForColumn:@"deviceid"];
                model.devid   = [rs stringForColumn:@"devid"];
                model.msgtype = [rs intForColumn:@"msgtype"];
                model.mctitle = [rs stringForColumn:@"mctitle"];
                model.mcdesc  = [rs stringForColumn:@"mcdesc"];
                model.mcurl   = [rs stringForColumn:@"mcurl"];
                model.mcts    = [rs longForColumn:@"mcts"];
                model.userid  = userid;
                
                FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:userid], model.msgid];
                
                if ([rs1 next]) {
                    BOOL isread = [rs1 boolForColumn:@"isread"];
                    BOOL isdelete = [rs1 boolForColumn:@"isdelete"];
                    
                    model.hasRead = isread;
                    
                    if (!isdelete) {
                        if (model.msgtype == 1) {
                            [arr1 addObject:model];
                        }else if (model.msgtype == 2) {
                            [arr2 addObject:model];
                        }
                    }
                }else {
                    model.hasRead = NO;
                    if (model.msgtype == 1) {
                        [arr1 addObject:model];
                    }else if (model.msgtype == 2) {
                        [arr2 addObject:model];
                    }
                }
                
                [rs1 close];
            }
            
            [rs close];
        }else {
            // 仅取出userid = 0 的系统消息
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageCenter WHERE userid = ? ORDER BY mcts DESC;", [NSNumber numberWithInteger:0]];
            while ([rs next]) {
                G100MsgDomain * model = [[G100MsgDomain alloc] init];
                model.msgid   = [rs stringForColumn:@"msgid"];
                model.userid  = [rs intForColumn:@"userid"];
                model.bikeid  = [rs stringForColumn:@"bikeid"];
                model.deviceid= [rs stringForColumn:@"deviceid"];
                model.devid   = [rs stringForColumn:@"devid"];
                model.msgtype = [rs intForColumn:@"msgtype"];
                model.mctitle = [rs stringForColumn:@"mctitle"];
                model.mcdesc  = [rs stringForColumn:@"mcdesc"];
                model.mcurl   = [rs stringForColumn:@"mcurl"];
                model.mcts    = [rs longForColumn:@"mcts"];
                model.userid  = userid;
                
                FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:0], model.msgid];
                
                if ([rs1 next]) {
                    BOOL isread = [rs1 boolForColumn:@"isread"];
                    BOOL isdelete = [rs1 boolForColumn:@"isdelete"];
                    
                    model.hasRead = isread;
                    if (!isdelete) {
                        if (model.msgtype == 1) {
                            [arr1 addObject:model];
                        }else if (model.msgtype == 2) {
                            [arr2 addObject:model];
                        }
                    }
                }else {
                    model.hasRead = NO;
                    if (model.msgtype == 1) {
                        [arr1 addObject:model];
                    }else if (model.msgtype == 2) {
                        [arr2 addObject:model];
                    }
                }
                
                [rs1 close];
            }
            
            [rs close];
        }
        
        if (block) {
            block(arr1, arr2);
        }
        
    }];
}

- (void)deleteDatabaseWithUserid:(NSInteger)userid msgArray:(NSArray *)msgArray success:(void (^)(BOOL))block {
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL result = NO;
        for (G100MsgDomain * model in msgArray) {
            // 标记消息为删除状态 并非物理删除
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:userid], model.msgid];
            if ([rs next]) {
                // 更新
                result = [db executeUpdate:@"update t_messageStatusCenter set isdelete = ? WHERE (msgid = ? AND userid = ?);", [NSNumber numberWithBool:YES], model.msgid, [NSNumber numberWithInteger:model.userid]];
            }else {
                // 插入
                result = [db executeUpdate:@"insert or ignore into t_messageStatusCenter (msgid, userid, isread, isdelete) values (?, ?, ?, ?);", model.msgid, [NSNumber numberWithInteger:model.userid], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]];
            }
            
            [rs close];
        }
        if (result) {
            DLog(@"删除成功");
        }else {
            DLog(@"删除失败");
        }
        
        if (block) {
            block(result);
        }
    }];
}

- (void)countUnreadNumberWithUserid:(NSInteger)userid success:(void (^)(NSInteger, NSInteger))block {
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableArray * arr1 = [NSMutableArray array];
        NSMutableArray * arr2 = [NSMutableArray array];
        
        // 如果userid > 0 则取出userid = 0 的消息
        if (userid > 0) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageCenter WHERE (userid = ? OR userid = ?) ORDER BY mcts DESC;", [NSNumber numberWithInteger:userid], [NSNumber numberWithInteger:0]];
            while ([rs next]) {
                G100MsgDomain * model = [[G100MsgDomain alloc] init];
                model.msgid   = [rs stringForColumn:@"msgid"];
                model.userid  = [rs intForColumn:@"userid"];
                model.bikeid  = [rs stringForColumn:@"bikeid"];
                model.deviceid= [rs stringForColumn:@"deviceid"];
                model.devid   = [rs stringForColumn:@"devid"];
                model.msgtype = [rs intForColumn:@"msgtype"];
                model.mctitle = [rs stringForColumn:@"mctitle"];
                model.mcdesc  = [rs stringForColumn:@"mcdesc"];
                model.mcurl   = [rs stringForColumn:@"mcurl"];
                model.mcts    = [rs longForColumn:@"mcts"];
                model.userid  = userid;
                
                FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:userid], model.msgid];
                
                if ([rs1 next]) {
                    BOOL isread = [rs1 boolForColumn:@"isread"];
                    BOOL isdelete = [rs1 boolForColumn:@"isdelete"];
                    
                    model.hasRead = isread;
                    
                    if (!isdelete && !isread) {
                        if (model.msgtype == 1) {
                            [arr1 addObject:model];
                        }else if (model.msgtype == 2) {
                            [arr2 addObject:model];
                        }
                    }
                }else {
                    model.hasRead = NO;
                    if (model.msgtype == 1) {
                        [arr1 addObject:model];
                    }else if (model.msgtype == 2) {
                        [arr2 addObject:model];
                    }
                }
                
                [rs1 close];
            }
            
            [rs close];
        }else {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageCenter WHERE userid = ? ORDER BY mcts DESC;", [NSNumber numberWithInteger:0]];
            while ([rs next]) {
                G100MsgDomain * model = [[G100MsgDomain alloc] init];
                model.msgid   = [rs stringForColumn:@"msgid"];
                model.userid  = [rs intForColumn:@"userid"];
                model.bikeid  = [rs stringForColumn:@"bikeid"];
                model.deviceid= [rs stringForColumn:@"deviceid"];
                model.devid   = [rs stringForColumn:@"devid"];
                model.msgtype = [rs intForColumn:@"msgtype"];
                model.mctitle = [rs stringForColumn:@"mctitle"];
                model.mcdesc  = [rs stringForColumn:@"mcdesc"];
                model.mcurl   = [rs stringForColumn:@"mcurl"];
                model.mcts    = [rs longForColumn:@"mcts"];
                model.userid  = userid;
                
                FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM t_messageStatusCenter WHERE (userid = ? AND msgid = ?);", [NSNumber numberWithInteger:0], model.msgid];
                
                if ([rs1 next]) {
                    BOOL isread = [rs1 boolForColumn:@"isread"];
                    BOOL isdelete = [rs1 boolForColumn:@"isdelete"];
                    
                    model.hasRead = isread;
                    if (!isdelete && !isread) {
                        if (model.msgtype == 1) {
                            [arr1 addObject:model];
                        }else if (model.msgtype == 2) {
                            [arr2 addObject:model];
                        }
                    }
                }else {
                    model.hasRead = NO;
                    if (model.msgtype == 1) {
                        [arr1 addObject:model];
                    }else if (model.msgtype == 2) {
                        [arr2 addObject:model];
                    }
                }
                
                [rs1 close];
            }
            
            [rs close];
        }
        
        if (block) {
            block([arr1 count], [arr2 count]);
        }
        
    }];
    
    /*
    [self.queue inDatabase:^(FMDatabase *db) {
        int num1 = [db intForQuery:@"\
                    SELECT COUNT(*) FROM \
                    t_messageCenter c \
                    inner join t_messageStatusCenter s \
                    on s.msgid = c.msgid \
                    and s.userid = c.userid \
                    and c.userid = ? \
                    and c.msgtype = ? \
                    and s.isread = ? \
                    and s.isdelete = ?;",
                    [NSNumber numberWithInteger:userid],
                    [NSNumber numberWithInteger:1],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO]];
        int num2 = [db intForQuery:@"\
                    SELECT COUNT(*) FROM \
                    t_messageCenter c \
                    inner join t_messageStatusCenter s \
                    on s.msgid = c.msgid \
                    and s.userid = c.userid \
                    and c.userid = ? \
                    and c.msgtype = ? \
                    and s.isread = ? \
                    and s.isdelete = ?;",
                    [NSNumber numberWithInteger:userid],
                    [NSNumber numberWithInteger:2],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO]];
        int num3 = [db intForQuery:@"\
                    SELECT COUNT(*) FROM \
                    t_messageCenter c \
                    inner join t_messageStatusCenter s \
                    on s.msgid = c.msgid \
                    and s.userid = ? \
                    and c.userid = ? \
                    and c.msgtype = ? \
                    and s.isread = ? \
                    and s.isdelete = ?;",
                    [NSNumber numberWithInteger:userid],
                    [NSNumber numberWithInteger:0],
                    [NSNumber numberWithInteger:2],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO]];
        
        if (block) {
            block(num1, num2+num3);
        }
    }];
     */
}

#pragma - mark private
- (void)msgIsExistWithMsg:(G100MsgDomain *)msg complete:(void (^)(FMDatabase *db, BOOL exist))block {
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messageCenter WHERE msgid = ?;", msg.msgid];
        BOOL isExist = NO;
        if (![rs next]) {
            DLog(@"不存在该记录");
            isExist = NO;
        }else {
            DLog(@"存在该记录");
            isExist = YES;
        }
        
        if (block) {
            block(db, isExist);
        }
        
        [rs close];
    }];
}

- (void)setupTestData {
#if DEBUG
    // 添加测试数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //加入耗时操作
        [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL result = NO;
            for (NSInteger i = 0; i < 100; i++) {
                G100MsgDomain * msg = [[G100MsgDomain alloc] init];
                
                msg.msgid   = [NSString stringWithFormat:@"%@", @(i + 1000)];
                msg.userid  = [[[G100InfoHelper shareInstance] buserid].length ? [[G100InfoHelper shareInstance] buserid] : @"0" integerValue];
                msg.bikeid  = @"1234";
                msg.deviceid= @"1234";
                msg.devid   = @"1234";
                msg.msgtype = i > 2 ? 1 : 2;
                msg.mctitle = [NSString stringWithFormat:@"Test %@", @(i)];
                msg.mcdesc  = [NSString stringWithFormat:@"%@Test %@ 这是一个测试这是一个测试数据这是一个测试数据这是一个测试数据数据这是", ((i % 2 == 0) ? @"" : [NSString stringWithFormat:kImageUrl, @(i%5)]), @(i)];
                msg.mcurl   = [NSString stringWithFormat:@"http://www.baidu.com"];
                msg.mcts    = [[NSDate date] timeIntervalSince1970] - random()%60*60*24*3;
                msg.hasRead = i % 2;
                
                if (msg.msgtype == 2) {
                    msg.userid = 0;
                }
                
                result = [db executeUpdate:@"insert or ignore into t_messageCenter (msgid, userid, bikeid, deviceid, devid, msgtype, mctitle, mcdesc, mcurl, mcts, isread) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", msg.msgid, [NSNumber numberWithInteger:msg.userid], msg.bikeid, msg.deviceid, msg.devid, [NSNumber numberWithInteger:msg.msgtype], msg.mctitle, msg.mcdesc, msg.mcurl, [NSNumber numberWithLong:msg.mcts], [NSNumber numberWithBool:msg.hasRead]];
            }
            if (result) {
                DLog(@"测试数据创建成功");
            }else {
                DLog(@"测试数据创建失败");
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI操作
            
        });
    });
#endif
}

@end
