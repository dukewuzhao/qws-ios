//
//  ModifyRealnameViewController.h
//  G100
//
//  Created by yuhanle on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^ModifySuccessBlock)();
@interface ModifyRealnameViewController : G100BaseVC

@property (copy, nonatomic) NSString * realname;
@property (copy, nonatomic) ModifySuccessBlock sureBlock;

@end
