//
//  ExtString.h
//  G100
//
//  Created by Tilink on 15/4/28.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROTOCOL	@"PROTOCOL"
#define HOST		@"HOST"
#define PORT        @"PORT"
#define URI			@"URI"
#define PARAMS		@"PARAMS"
#define FRAGMENT    @"FRAGMENT"

@interface ExtNSString : NSString {
}

@end

@interface NSString (ExtNSString)

/**
 *  @param NSString *URL 需要解析的URL，格式如：http://host.name/testpage/?keyA=valueA&keyB=valueB
 *  @return NSDictionary *params 从URL中解析出的参数表
 *    PROTOCOL 如 http
 *    HOST     如 host.name
 *    PARAMS   如 {keyA:valueA, keyB:valueB}
 *    URI      如 /testpage
 */
- (NSDictionary *)paramsFromURL;

@end
