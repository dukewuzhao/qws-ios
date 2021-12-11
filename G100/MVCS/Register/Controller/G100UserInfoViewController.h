//
//  G100UserInfoViewController.h
//  G100
//
//  Created by sunjingjing on 16/7/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100UserInfoViewController : G100BaseXibVC

@property (nonatomic, copy) void (^ loginResult)(NSString * userid, BOOL loginSuccess);

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userid;

// 三方登录信息
@property (copy, nonatomic) NSString * screen_name;

@end
