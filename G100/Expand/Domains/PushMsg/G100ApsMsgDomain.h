//
//  G100ApsMsgDomain.h
//  G100
//
//  Created by Tilink on 15/5/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100ApsMsgDomain : G100BaseDomain

@property (copy, nonatomic) NSString * alert;
@property (copy, nonatomic) NSString * sound;
@property (assign, nonatomic) NSInteger badge;

@end
