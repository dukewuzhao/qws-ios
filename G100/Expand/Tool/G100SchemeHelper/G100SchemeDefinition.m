//
//  G100SchemeDefinition.m
//  G100
//
//  Created by 曹晓雨 on 2016/11/17.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100SchemeDefinition.h"

@implementation G100SchemeDefinition

+ (NSString *)exchangeToUrlPrefix:(NSDictionary *)routerParameters
{
    NSString * parameterURL = routerParameters[G100RouterParameterURL];
    NSString * result = nil;
    if ([parameterURL hasContainString:kGSDAPPScheme]) {
        result = [parameterURL stringByReplacingOccurrencesOfString:kGSDAPPScheme withString:kGSDHostScheme];
    }
    
    return result;
}

+ (NSString *)exchangeToScheme:(NSDictionary *)routerParameters
{
    NSString * parameterURL = routerParameters[G100RouterParameterURL];
    NSString * result = nil;
    if ([parameterURL hasContainString:kGSDHostScheme]) {
        result = [parameterURL stringByReplacingOccurrencesOfString:kGSDHostScheme withString:kGSDAPPScheme];
    }
    return result;
}

@end
