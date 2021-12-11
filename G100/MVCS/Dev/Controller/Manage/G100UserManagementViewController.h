//
//  G100UserManagementViewController.h
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@class G100UserDomain;
@interface G100UserManagementViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, strong) G100UserDomain *userDomain;

@end
