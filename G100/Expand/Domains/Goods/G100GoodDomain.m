//
//  G100GoodDomain.m
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100GoodDomain.h"

@implementation G100GoodDomain

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"insurance_type" : @"insurancetype",
              @"extra_option" : @"extraoption" ,
              @"kextraoption":@"extra_option"};
}

-(void)setExtraoption:(NSString *)extraoption {
    self.kextraoption = [[G100ExtraoptionDomain alloc] initWithDictionary:[extraoption mj_JSONObject]];
}

@end

@implementation G100InsuranceInfo

@end
