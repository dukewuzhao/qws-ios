//
//  DBMigration.m
//  G100
//
//  Created by yuhanle on 2017/1/6.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "DBMigration.h"

@interface DBMigration ()

@property (nonatomic, copy) NSString * myName;
@property (nonatomic, assign) uint64_t myVersion;
@property (nonatomic, strong) NSArray * updateArray;

@end

@implementation DBMigration

- (instancetype)initWithName:(NSString *)name andVersion:(uint64_t)version andExecuteUpdateArray:(NSArray *)updateArray
{
    if (self=[super init]) {
        _myName = name;
        _myVersion = version;
        _updateArray = updateArray;
    }
    return self;
}

- (NSString *)name
{
    return _myName;
}

- (uint64_t)version
{
    return _myVersion;
}

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    for(NSString * updateStr in _updateArray)
    {
        [database executeUpdate:updateStr];
    }
    return YES;
}

@end
