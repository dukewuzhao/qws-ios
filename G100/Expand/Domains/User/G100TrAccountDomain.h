//
//  G100TrAccountDomain.h
//  G100
//
//  Created by Tilink on 15/6/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

typedef enum : NSUInteger {
    WxAccountType,
    QQAccountType,
    SinaAccountType,
} ThirdAccountType;

@interface G100TrAccountDomain : G100BaseDomain

/** 是否允许解绑 */
@property (assign, nonatomic) BOOL enable;
/** 是否绑定 */
@property (assign, nonatomic) BOOL isBind;
/** 第三方帐号类型 qq wx sina */
@property (copy, nonatomic) NSString * partner;
/** 第三方帐号号 */
@property (copy, nonatomic) NSString * partner_account;
/** 第三方帐号名 */
@property (copy, nonatomic) NSString * accountName;
/** 三方帐号用户全局id（如微信的unionid），可为空*/
@property (copy, nonatomic) NSString *partner_user_uid;
/** 口令 app和服务端商定规则进行校验*/
@property (copy, nonatomic) NSString *partner_account_token;
/** 登录类型 */
@property (assign, nonatomic) ThirdAccountType accountType;

@end
