//
//  PingAnInsuranceModel.m
//  G100
//
//  Created by Tilink on 15/4/11.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "PingAnInsuranceModel.h"

@implementation PingAnInsuranceModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"servicemonths" : @"service_months",
              @"extraoption" : @"extra_option",
              @"insurancetype" : @"insurance_type",
              @"productid" : @"product_id"};
}

-(void)setExtraoption:(NSString *)extraoption {
    self.kextraoption = [[G100ExtraoptionDomain alloc] initWithDictionary:[extraoption mj_JSONObject]];
}
- (void)setInsurance:(NSDictionary *)insurance
{
    self.kinsurance = [[G100InsuranceInfo alloc]initWithDictionary:[insurance mj_JSONObject]];
}
- (void)setPicture:(NSString *)picture {
    _picture = [picture stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
