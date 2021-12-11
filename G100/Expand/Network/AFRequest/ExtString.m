//
//  ExtString.m
//  G100
//
//  Created by Tilink on 15/4/28.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ExtString.h"

@implementation NSString (ExtNSString)

- (NSDictionary *)paramsFromURL {
    if ([self isEqualToString:@"about:blank"]) {
        return @{};
    }
    
    NSURL * tilinkUrl = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    if (0 < [self rangeOfString:@"?"].length) {
        NSString *paramString = [self substringFromIndex:([self rangeOfString:@"?"].location + 1)];
        NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
        NSScanner* scanner = [[NSScanner alloc] initWithString:paramString];
        
        while (![scanner isAtEnd]) {
            NSString* pairString = nil;
            [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
            [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
            NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
            if (kvPair.count == 2) {
                NSString* key = [[kvPair safe_objectAtIndex:0]
                                 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString* value = [[kvPair safe_objectAtIndex:1]
                                   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [pairs setObject:value forKey:key];
            }
        }
    }
    
    // 拼接结果 字典
    return @{PROTOCOL : [tilinkUrl scheme] ? : @"",
             HOST : [tilinkUrl host] ? : @"",
             URI : [tilinkUrl pathComponents] ? : @"",
             PARAMS : pairs ? : @""};
}

@end

@implementation ExtNSString

@end
