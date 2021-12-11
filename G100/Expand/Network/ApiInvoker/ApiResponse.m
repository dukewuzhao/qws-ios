//
//  ApiResponse.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ApiResponse.h"
#import "G100Macros.h"

@implementation ApiResponse
@synthesize errCode = _errCode;
@synthesize errDesc = _errDesc;
@synthesize data = _data;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (!self) {
        self = [[ApiResponse alloc] init];
    }
    
	if([[dictionary allKeys] containsObject:@"state"]){
		NSString *errCode = [dictionary objectForKey:@"state"];
		if(errCode != (id) [NSNull null]){
			self.errCode = [errCode integerValue];
		}

        if (self.errCode == 0) {
            self.success = YES;
        }else {
            self.success = NO;
        }
	}

	if ([[dictionary allKeys] containsObject:@"state_info"]) {
		self.errDesc = [dictionary objectForKey:@"state_info"];
	}

	if ([[dictionary allKeys] containsObject:@"data"]) {
		self.data = [dictionary objectForKey:@"data"];
	}
    
    if ([[dictionary allKeys] containsObject:@"cust_info"]) {
        self.custDesc = [dictionary objectForKey:@"cust_info"];
    }
    
    if ([[dictionary allKeys] containsObject:@"total"]) {
        self.total = [[dictionary objectForKey:@"total"] integerValue];
    }
    
    if ([[dictionary allKeys] containsObject:@"subtotal"]) {
        self.subtotal = [[dictionary objectForKey:@"subtotal"] integerValue];
    }
    
    // 解析picvcurl 附带的其他参数
    if ([[dictionary allKeys] containsObject:@"picture_captcha"]) {
        self.picvcurl = [[dictionary objectForKey:@"picture_captcha"] objectForKey:@"url"];
        self.sessionid = [[dictionary objectForKey:@"picture_captcha"] objectForKey:@"session_id"];
    }
    
	return self;
}

- (NSString *)errDesc {
	if(_errDesc == (id) [NSNull null]){
		return nil;
	}
    
	return _errDesc;
}

- (NSString *)custDesc {
    if(_custDesc == (id) [NSNull null]){
        return nil;
    }
    
    return _custDesc;
}

- (BOOL)needPicvcVerified {
    NSString *result = nil;
    NSDictionary *dict = (NSDictionary *)[self data];
    if ([[dict allKeys] containsObject:@"picture_captcha"]) {
        result = [[dict objectForKey:@"picture_captcha"] objectForKey:@"url"];
    }
    if (result.length) {
        return YES;
    }
    
    return NO;
}

@end
