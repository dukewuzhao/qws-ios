//
//  Defines.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#ifndef G100_DeviceMacro_h
#define G100_DeviceMacro_h

//兼容性
#define IS_IPHONE_5                         ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IOS_VERSION_CODE                    [[[UIDevice currentDevice] systemVersion] intValue]
#define iOS7                                [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define KStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#ifdef DEBUG
#   define AlertLog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define AlertLog(...)
#endif

// 过期提醒
#define G100Deprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#define EMPTY_IF_NIL(str) (str == nil ? @"" : (str == (id)[NSNull null] ? @"" : str))
#define NOT_NULL(v) (v && (v) != (id)[NSNull null])
#define INSTANCE_OF(obj,cls) ([obj isKindOfClass:[cls class]])

#endif
