//
//  G100PictureCaptchaDomain.h
//  G100
//
//  Created by yuhanle on 16/8/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

/**
 *  图形验证码
 */
@interface G100PictureCaptchaDomain : G100BaseDomain

@property (nonatomic, copy) NSString *url; //!< 图形验证码url
@property (nonatomic, copy) NSString *did; //!< 图片文件id 不含后缀
@property (nonatomic, copy) NSString *input; //!< 用户输入的验证码
@property (nonatomic, copy) NSString *session_id; //!< 会话id
@property (nonatomic, copy) NSString *usage; //!< 用户 1 注册 2 找回密码 3 更改手机 4 登陆

@end
