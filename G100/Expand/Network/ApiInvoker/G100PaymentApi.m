//
//  G100PaymentApi.m
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PaymentApi.h"

@implementation G100PaymentApi

+(instancetype)sharedInstance {
    static G100PaymentApi * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(ApiRequest *)paymentByPingppWith:(NSDictionary *)pingpp callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"pingpp" : EMPTY_IF_NIL(pingpp)}];
    return [G100ApiHelper postApi:@"pay/pingpppay" andRequest:request callback:callback];
}

@end
