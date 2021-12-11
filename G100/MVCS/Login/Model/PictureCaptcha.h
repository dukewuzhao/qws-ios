//
//  PictureCaptcha.h
//  G100
//
//  Created by sunjingjing on 16/8/19.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100BaseDomain.h"

@interface PictureCaptcha : G100BaseDomain

/** 用途*/
@property (assign, nonatomic) NSInteger usage;
/** 验证码 */
@property (copy, nonatomic) NSString * input;
/** session */
@property (copy, nonatomic) NSString * session_id;
/** 图片url */
@property (copy, nonatomic) NSString * url;
/** 图形验证码id */
@property (copy, nonatomic) NSString * ID;

@end
