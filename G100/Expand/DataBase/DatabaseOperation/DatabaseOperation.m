//
//  DatabaseOperation.m
//  G100
//
//  Created by yuhanle on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DatabaseOperation.h"
#import <LKDBHelper/LKDBHelper.h>
#import "DBMigration.h"
#import "G100MsgDomain.h"

#define kImageUrl   @"http://ovsmr3xhj.bkt.clouddn.com/%@.jpg<img>"

NSString *const DBFileName         = @"G100Database.sqlite";
@interface DatabaseOperation()

@property (nonatomic, strong, readonly) FMDatabaseQueue *queue;

@end

@implementation DatabaseOperation
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
        NSString *path = [paths firstObject];
        _dbPath = [path stringByAppendingPathComponent:DBFileName];
    }
    return _dbPath;
}

+ (DatabaseOperation *)operation {
    static DatabaseOperation *DBOperation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DBOperation = [[self alloc] init];
    });
    return DBOperation;
}
+ (void)createTable {
    DatabaseOperation *op = [DatabaseOperation operation];
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
    if ([msg isExistsFromDB]) {
        [msg updateToDB];
    }else {
        [msg saveToDB];
    }
    
    if (block) {
        block(YES);
    }
}

- (void)updateDatabaseWithMsg:(G100MsgDomain *)msg success:(void (^)(BOOL))block {
    if ([msg isExistsFromDB]) {
        [msg updateToDB];
    }else {
        [msg saveToDB];
    }
    
    if (block) {
        block(YES);
    }
}

- (void)hasReadMsgWithMsg:(G100MsgDomain *)msg success:(void (^)(BOOL))block {
    G100MsgStatusDomain *status = [[G100MsgStatusDomain alloc] init];
    status.isread = YES;
    status.msgid = msg.msgid;
    status.userid = msg.userid;
    
    if ([status isExistsFromDB]) {
        [status updateToDB];
    }else {
        [status saveToDB];
    }
    
    if (block) {
        block(YES);
    }
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

- (void)deleteDatabaseWithUserid:(NSInteger)userid msgArray:(NSArray <G100MsgDomain *> *)msgArray success:(void (^)(BOOL))block {
    __block BOOL success = NO;
    [msgArray enumerateObjectsUsingBlock:^(G100MsgDomain * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        G100MsgStatusDomain *status = [[G100MsgStatusDomain alloc] init];
        status.msgid = msg.msgid;
        status.userid = msg.userid;
        status.isdelete = YES;
        
        if ([status isExistsFromDB]) {
            success = [status updateToDB];
        }else {
            success = [status saveToDB];
        }
        
        if (!success) {
            *stop = NO;
        }
    }];
    
    if (block) {
        block(success);
    }
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

- (void)setupTestData {
#if DEBUG
    // 添加测试数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //加入耗时操作
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
            
            result = [msg saveToDB];
        }
        if (result) {
            DLog(@"测试数据创建成功");
        }else {
            DLog(@"测试数据创建失败");
        }
    });
#endif
}

@end
