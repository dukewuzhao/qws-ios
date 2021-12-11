//
//  ModifyUsernameViewController.h
//  G100
//
//  Created by Tilink on 15/4/21.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^ModifySuccessBlock)();

@interface ModifyUsernameViewController : G100BaseVC

@property (copy, nonatomic) NSString * username;
@property (copy, nonatomic) ModifySuccessBlock sureBlock;

@end
