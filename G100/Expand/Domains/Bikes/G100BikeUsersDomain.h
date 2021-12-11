//
//  G100BikeUsersDomain.h
//  G100
//
//  Created by yuhanle on 16/9/19.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100UserDomain;
@interface G100BikeUsersDomain : G100BaseDomain

@property (nonatomic, strong) NSArray <G100UserDomain *> *bikeusers;
@property (nonatomic, strong) NSArray <G100UserDomain *> *auditing;

@end
