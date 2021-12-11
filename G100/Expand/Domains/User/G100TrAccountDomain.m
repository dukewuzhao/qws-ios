//
//  G100TrAccountDomain.m
//  G100
//
//  Created by Tilink on 15/6/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100TrAccountDomain.h"

@implementation G100TrAccountDomain

- (ThirdAccountType)accountType {
    if ([self.partner isEqualToString:@"wx"]) {
        return WxAccountType;
    }
    
    if ([self.partner isEqualToString:@"qq"]) {
        return QQAccountType;
    }
    
    if ([self.partner isEqualToString:@"sina"]) {
        return SinaAccountType;
    }
    
    return 0;
}

@end
