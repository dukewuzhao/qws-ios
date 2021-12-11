//
//  G100ExtraoptionDomain.m
//  G100
//
//  Created by Tilink on 15/6/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100ExtraoptionDomain.h"

@implementation G100ExtraoptionDomain

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"recent_order_id" : @"recentorderid",
              @"service_num" : @"servicenum",
              @"insured_amount" : @"insuredamount"};
}

@end
