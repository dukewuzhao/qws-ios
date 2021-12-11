//
//  CHKeychain.h
//  G100
//
//  Created by Tilink on 15/4/3.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteData:(NSString *)service;

@end
