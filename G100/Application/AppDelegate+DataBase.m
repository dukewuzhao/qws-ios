//
//  AppDelegate+DataBase.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+DataBase.h"
#import "DatabaseOperation.h"

@implementation AppDelegate (DataBase)

- (void)xks_dataBaseConfigConfiguration {
    // 修复iOS 7 崩溃的问题 https://github.com/magicalpanda/MagicalRecord/issues/1046
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    // 自定义数据库名，需要自动升级
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"CoreDataDemo.sqlite"];
    // 创建消息中心表
    [DatabaseOperation createTable];
}

@end
