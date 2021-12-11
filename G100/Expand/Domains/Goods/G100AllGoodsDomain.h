//
//  G100AllGoodsDomain.h
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100GoodDomain.h"

@interface G100AllGoodsDomain : G100BaseDomain

@property (strong, nonatomic) NSArray <G100GoodDomain *> * prods;

@end
