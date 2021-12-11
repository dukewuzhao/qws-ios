//
//  G100SchemeDefinition.h
//  G100
//
//  Created by 曹晓雨 on 2016/11/17.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGSDAPPScheme           @"qwsapp://"
#define kGSDReleaseHostScheme   @"https://appwebv2.360qws.cn/"
#define kGSDTestHostScheme      @"https://appweb.d.360qws.cn/"
#define kGSDHostScheme          ISProduct ? kGSDReleaseHostScheme : kGSDTestHostScheme

#define KSDPushScheme   [kGSDAPPScheme stringByAppendingString:@"%@"]
#define KSDActionScheme [kGSDAPPScheme stringByAppendingString:@"action/%@"]
#define KSDActionHost   [kGSDHostScheme stringByAppendingString:@"action/%@"]

@interface G100SchemeDefinition : NSObject

+ (NSString *)exchangeToUrlPrefix:(NSDictionary *)routerParameters;
+ (NSString *)exchangeToScheme:(NSDictionary *)routerParameters;

@end
