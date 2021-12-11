//
//  G100InsuranceApi.m
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100InsuranceApi.h"

@implementation G100InsuranceApi

+(instancetype)sharedInstance {
    static G100InsuranceApi * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ApiRequest *)queryInsuranceActivity:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{}];
    return [G100ApiHelper postApi:@"insurance/getinsuranceactivity" andRequest:request callback:callback];
}
- (ApiRequest *)queryAllInsuranceActivityWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"type" : [NSNumber numberWithInteger:0]
                                                            }];
    return [G100ApiHelper postApi:@"insurance/getinsuranceactivity" andRequest:request callback:callback];
}
- (ApiRequest *)queryMyInsuranceActivity:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"type" : [NSNumber numberWithInteger:1]
                                                            }];
    return [G100ApiHelper postApi:@"insurance/getinsuranceactivity" andRequest:request callback:callback];
}

- (ApiRequest *)queryInsurancePrompt:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{}];
    return [G100ApiHelper postApi:@"insurance/checkinsuranceprompt" andRequest:request callback:callback];
}

- (ApiRequest *)queryInsuranceFreeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]]}];
    return [G100ApiHelper postApi:@"insurance/checkinsurancefree" andRequest:request callback:callback];
}

- (ApiRequest *)queryInsuranceOrderWithUserid:(NSString *)userid status:(NSArray<NSNumber *> *)status callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"user_id" : [NSNumber numberWithInteger:[userid integerValue]],
                                                            @"status" : status ? status : @[] }];
    return [G100ApiHelper postApi:@"insurance/getinsuranceorder" andRequest:request callback:callback];
}

-(ApiRequest *)insurancePayFinishedWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"order_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:orderid])}];
    return [G100ApiHelper postApi:@"insurance/payfinished" andRequest:request callback:callback];
}

-(ApiRequest *)checkInsuranceOrderDetailWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"order_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:orderid])}];
    return [G100ApiHelper postApi:@"insurance/insurancedetail" andRequest:request callback:callback];
}

-(ApiRequest *)queryInsuranceStatusWithUserid:(NSString *)userid callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"userid" : EMPTY_IF_NIL(userid)}];
    return [G100ApiHelper postApi:@"insurance/insurancestatus" andRequest:request callback:callback];
}

@end
