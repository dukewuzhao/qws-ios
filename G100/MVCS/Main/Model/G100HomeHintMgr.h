//
//  G100HomeHintMgr.h
//  G100
//
//  Created by yuhanle on 2018/9/5.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100InsuranceManager.h"
#import "G100TopHintTableView.h"
#import "G100TopHintModel.h"

@interface G100HomeHintMgr : NSObject

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;

@property (nonatomic, readonly, strong) G100TopHintViewModel *topViewModel;
@property (nonatomic, strong) G100InsuranceManager *insuranceDataManager;

@property (nonatomic, strong) G100TopHintTableView *topHintTableView;
@property (nonatomic, strong) G100TopHintModel *topHintModel;

- (void)updateInfo;

@end
