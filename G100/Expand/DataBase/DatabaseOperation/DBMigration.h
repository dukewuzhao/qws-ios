//
//  DBMigration.h
//  G100
//
//  Created by yuhanle on 2017/1/6.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDBMigrationManager/FMDBMigrationManager.h>

@interface DBMigration : NSObject <FMDBMigrating>

/**
 自定义方法创建 Migration
 
 @param name 迁移描述
 @param version 迁移版本号
 @param updateArray 执行的sql 语句
 @return Migration Instance
 */
- (instancetype)initWithName:(NSString *)name andVersion:(uint64_t)version andExecuteUpdateArray:(NSArray *)updateArray;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint64_t version;

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

@end
