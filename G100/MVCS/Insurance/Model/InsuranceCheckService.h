//
//  InsuranceCheckService.h
//  G100
//
//  Created by yuhanle on 2017/8/10.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100InsuranceOrder.h"

typedef void(^InsuranceCheckServiceComplete)(NSInteger totalCount);

@interface InsuranceCheckService : NSObject

+ (instancetype)sharedService;

@property (strong, nonatomic) G100InsuranceStatusPacks *insuranceStatusPacks;

@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger lingquCount;
@property (assign, nonatomic) NSInteger waitPayCount;
@property (assign, nonatomic) NSInteger guaranteeCount;
@property (assign, nonatomic) NSInteger expiredCount;

- (void)checkInsurancePacksWithUserid:(NSString *)userid complete:(InsuranceCheckServiceComplete)complete;

@end
