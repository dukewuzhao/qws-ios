//
//  G100BikeUpdateInfoDomain.m
//  G100
//
//  Created by sunjingjing on 16/9/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeUpdateInfoDomain.h"

@implementation G100BikeUpdateInfoDomain

- (instancetype)init {
    if (self = [super init]) {
        self.brand = [[G100BrandInfoDomain alloc] init];
        self.feature = [[G100BikeFeatureDomain alloc] init];
    }
    
    return self;
}

@end
