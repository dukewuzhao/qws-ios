//
//  G100PartnerDomain.h
//  G100
//
//  Created by yuhanle on 16/8/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

/**
 *  三方帐号 partner
 */
@interface G100PartnerDomain : G100BaseDomain

@property (nonatomic, copy) NSString *partner; //!< 三方名称 wx 微信 sina 新浪 qq 腾讯qq
@property (nonatomic, copy) NSString *partner_account; //!< 三方帐号
@property (nonatomic, copy) NSString *partner_account_token; //!< 口令 app和服务端商定规则进行校验
@property (nonatomic, copy) NSString *partner_user_uid; //!< 三方帐号用户全局id（如微信的unionid），可为空

@end
