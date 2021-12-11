//
//  G100OrderApi.m
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100OrderApi.h"

@implementation G100OrderApi

+(instancetype)sharedInstance {
    static G100OrderApi * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(ApiRequest *)loadMyorderWithCallback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"order/listorder" andRequest:request callback:callback];
}

-(ApiRequest *)submitOrderWithDevid:(NSString *)devid
                  productid:(NSInteger)productid
                  unitprice:(CGFloat)unitprice
                     amount:(NSInteger)amount
                   discount:(CGFloat)discount
                     coupon:(NSString *)coupon
                      price:(CGFloat)price
                  insurance:(NSDictionary *)insurance
                   callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(devid),
                                                           @"productid" : [NSNumber numberWithInteger:productid],
                                                           @"unitprice" : [NSNumber numberWithFloat:unitprice],
                                                           @"amount" : [NSNumber numberWithInteger:amount],
                                                           @"discount" : [NSNumber numberWithFloat:discount],
                                                           @"coupon" : EMPTY_IF_NIL(coupon),
                                                           @"price" : [NSNumber numberWithFloat:price],
                                                           @"insurance" : insurance ? insurance : @{}
                                                           }];
    return [G100ApiHelper postApi:@"order/submitorder" andRequest:request callback:callback];
}

-(ApiRequest *)servicePayFinishedWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"order_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:orderid])}];
    return [G100ApiHelper postApi:@"order/servicepayfinished" andRequest:request callback:callback];
}

-(ApiRequest *)cancelOrderWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"order_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:orderid])}];
    return [G100ApiHelper postApi:@"order/cancelorder" andRequest:request callback:callback];
}

- (ApiRequest *)sv_submitOrderWithBikeid:(NSString *)bikeid
                           devid:(NSString *)devid
                       productid:(NSInteger)productid
                       unitprice:(CGFloat)unitprice
                          amount:(NSInteger)amount
                        discount:(CGFloat)discount
                          coupon:(NSString *)coupon
                           price:(CGFloat)price
                       insurance:(NSDictionary *)insurance
                        callback:(API_CALLBACK)callback {
    NSDictionary *dic = @{
                          @"bike_id" : [NSNumber numberWithInteger:bikeid.integerValue],
                          @"device_id" : [NSNumber numberWithInteger:devid.integerValue],
                          @"product_id" : [NSNumber numberWithInteger:productid],
                          @"unit_price" : [NSNumber numberWithFloat:unitprice],
                          @"amount" : [NSNumber numberWithInteger:amount],
                          @"discount" : [NSNumber numberWithFloat:discount],
                          @"coupon" : EMPTY_IF_NIL(coupon),
                          @"price" : [NSNumber numberWithFloat:price],
                          @"insurance" : EMPTY_IF_NIL(insurance)
                          };

    ApiRequest *request = [ApiRequest requestWithBizData:dic];
    return [G100ApiHelper postApi:@"order/submitorder" andRequest:request callback:callback];
}

- (ApiRequest *)getOrderDetailWithOrder_id:(NSInteger)orderid callback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"order_ids" : @[ [NSNumber numberWithInteger:orderid] ] }];
    return [G100ApiHelper postApi:@"order/listorder" andRequest:request callback:callback];
}

@end
