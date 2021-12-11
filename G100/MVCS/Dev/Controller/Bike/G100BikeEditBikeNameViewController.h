//
//  G100BikeEditBikeNameViewController.h
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^ModifySuccessBlock)();
@interface G100BikeEditBikeNameViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *oldName;

@property (copy, nonatomic) ModifySuccessBlock sureBlock;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldName:(NSString *)oldName;

@end
