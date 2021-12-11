//
//  G100AppApi.m
//  G100
//
//  Created by yuhanle on 2017/3/16.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100AppApi.h"

@implementation G100AppApi

+ (instancetype) sharedInstance {
    static G100AppApi *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ApiRequest *)checkUpdateWithPlatform:(NSString *)platform channel:(NSString *)channel version:(NSString *)version callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"platform" : EMPTY_IF_NIL(platform),
                                                            @"channel" : EMPTY_IF_NIL(channel),
                                                            @"version" : EMPTY_IF_NIL(version) }];
    return [G100ApiHelper postApi:@"app/checkupdate" andRequest:request token:NO callback:callback];
}

@end
