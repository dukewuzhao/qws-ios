//
//  G100BikeEditBrandPhoneNumViewController.h
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^ModifySuccessBlock)();
@interface G100BikeEditBrandPhoneNumViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *oldNumber;
@property (nonatomic, copy) NSString *defaultNumber; //!< 默认厂商电话
@property (nonatomic, assign)NSInteger brand_id; //0无默认厂商 1有默认厂商
@property (copy, nonatomic) ModifySuccessBlock sureBlock;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldNumber:(NSString *)oldNumber;

@end
