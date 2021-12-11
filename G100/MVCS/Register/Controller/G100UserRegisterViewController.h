//
//  G100UserRegisterViewController.h
//  G100
//
//  Created by sunjingjing on 16/7/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100UserRegisterViewController : G100BaseXibVC

@property (nonatomic, copy) void (^ loginResult)(NSString * userid, BOOL loginSuccess);

@property (assign, nonatomic) BOOL isThird;     // 判断是否第三方登录

@property (assign, nonatomic) UserLoginType loginType;
// 三方登录信息
@property (strong, nonatomic) NSString * partner;
@property (strong, nonatomic) NSString * partneraccount;
@property (strong, nonatomic) NSString * partneraccounttoken;
@property (strong, nonatomic) NSString * partneruseruid;

@property (copy, nonatomic) NSString * screen_name;


@end
