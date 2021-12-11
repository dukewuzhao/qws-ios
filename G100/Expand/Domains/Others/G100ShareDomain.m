//
//  G100ShareDomain.m
//  G100
//
//  Created by yuhanle on 16/4/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ShareDomain.h"

@implementation G100ShareDomain

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"shareto" : @"shareto",
             @"shareTopic" : @"stp",
             @"shareTitle" : @"stt",
             @"shareText" : @"sct",
             @"shareAtUser" : @"at",
             @"sharePicUrl" : @"spicurl",
             @"shareJumpUrl" : @"sjumpurl"
             };
};

@end
