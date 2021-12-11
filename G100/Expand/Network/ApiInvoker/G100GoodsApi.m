//
//  G100GoodsApi.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100GoodsApi.h"

@implementation G100GoodsApi

+(instancetype)sharedInstance {
    static G100GoodsApi *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(ApiRequest *)loadProductListWithType:(NSString *)type callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"type" : EMPTY_IF_NIL(type)}];
    return [G100ApiHelper postApi:@"product/listprod" andRequest:request callback:callback];
}

-(ApiRequest *)loadProductListWithType:(NSString *)type devid:(NSInteger)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"type" : EMPTY_IF_NIL(type),
                                                           @"device_id": EMPTY_IF_NIL([NSNumber numberWithInteger:devid]) }];
    return [G100ApiHelper postApi:@"product/listprod" andRequest:request callback:callback];
}

-(ApiRequest *)loadProductListWithType:(NSString *)type productid:(NSInteger)productid devid:(NSInteger)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"type" : EMPTY_IF_NIL(type),
                                                           @"productid" : [NSNumber numberWithInteger:productid],
                                                           @"device_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:devid])
                                                           }];
    return [G100ApiHelper postApi:@"product/listprod" andRequest:request callback:callback];
}

@end
