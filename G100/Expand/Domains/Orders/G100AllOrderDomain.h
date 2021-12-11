//
//  G100AllOrderDomain.h
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100OrderDomain.h"

@interface G100AllOrderDomain : G100BaseDomain

@property (strong, nonatomic) NSArray <G100OrderDomain *> *orders;

@end
