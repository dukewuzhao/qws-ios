//
//  G100PaymentApi.h
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"

@interface G100PaymentApi : NSObject

+(instancetype)sharedInstance;

/**
 *  ping++  支付
 *  
 *  @param  pingpp      ping++提供的json格式
 *  @param  callback    接口回调
 */
-(ApiRequest *)paymentByPingppWith:(NSDictionary *)pingpp callback:(API_CALLBACK)callback;

@end
