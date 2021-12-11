//
//  G100BikeEditBrandViewController.h
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^ModifySuccessBlock)();
@interface G100BikeEditBrandViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *oldName;
@property (nonatomic, assign) NSInteger bikeType;

@property (copy, nonatomic) ModifySuccessBlock sureBlock;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldName:(NSString *)oldName;

@end
