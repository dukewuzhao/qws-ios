//
//  G100UserLoginViewController.h
//  G100
//
//  Created by sunjingjing on 16/7/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100UserLoginViewController : G100BaseXibVC

@property (nonatomic, copy) void (^ loginResult)(NSString * userid, BOOL loginSuccess);

@end
