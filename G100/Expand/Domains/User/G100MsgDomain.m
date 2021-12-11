//
//  G100MsgDomain.m
//  G100
//
//  Created by William on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MsgDomain.h"
#import "DatabaseOperation.h"

@implementation G100MsgStatusDomain

+ (LKDBHelper *)getUsingLKDBHelper
{
    static LKDBHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[LKDBHelper alloc] initWithDBPath:[DatabaseOperation operation].dbPath];
    });
    return helper;
}

+ (NSString *)getTableName {
    return @"t_messageStatusCenter";
}

+ (NSArray *)getPrimaryKeyUnionArray {
    return @[ @"msgid", @"userid" ];
}

@end

@implementation G100MsgDomain

+ (LKDBHelper *)getUsingLKDBHelper
{
    static LKDBHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[LKDBHelper alloc] initWithDBPath:[DatabaseOperation operation].dbPath];
    });
    return helper;
}

- (NSString *)bikeid {
    if (!_bikeid) {
        _bikeid = self.devid;
    }
    return _bikeid;
}

- (NSString *)deviceid {
    if (!_deviceid) {
        _deviceid = self.devid;
    }
    return _deviceid;
}

+ (NSString *)getTableName {
    return @"t_messageCenter";
}

+ (NSString *)getPrimaryKey {
    return @"msgid";
}

@end
