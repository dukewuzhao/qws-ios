//
//  BindErrorView.h
//  G100
//
//  Created by 温世波 on 16/1/6.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"
#import "G100DeviceDomainExpand.h"

@class ApiResponse;
@interface BindErrorView : G100PopBoxBaseView

@property (nonatomic, strong) G100DevBindResultDomain *bindResultDomain;

@property (nonatomic, copy) void (^bindErrorViewRebind)();
@property (nonatomic, copy) void (^bindErrorViewExit)();

+ (instancetype)bindErrorViewWithErrorCode:(NSInteger)errCode response:(ApiResponse *)respponse;

@end
