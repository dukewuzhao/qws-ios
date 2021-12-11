//
//  IDLog.h
//  idlFrame

//  Created by Nick(xuli02) on 15/1/22.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    IDLogTypeError,
    IDLogTypeWarning,
    IDLogTypeDebug,
    IDLogTypeInfo,
} IDLogType;

#ifndef __OPTIMIZE__
#define NSLog(...) printf("%s %s\n",[[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle] UTF8String],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#endif

#define IDLog(type,fmt,...) [IDLog idlLogWithType:type andLogString:[NSString stringWithFormat:fmt,##__VA_ARGS__] andFileName:__FILE__ andLineNumber:__LINE__]

@interface IDLog : NSObject

+ (void)idlLogWithType:(IDLogType)type andLogString:(NSString *)log andFileName:(char *)fileName andLineNumber:(NSInteger)lineNumber;

@end
