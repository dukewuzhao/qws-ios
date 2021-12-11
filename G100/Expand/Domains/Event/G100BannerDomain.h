//
//  G100BannerDomain.h
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100BannerButtonDomain;
@interface G100BannerDomain : G100BaseDomain

/** 横幅id*/
@property (nonatomic, assign) NSInteger banner_id;
/** 类型 1盗抢险 2其它保险*/
@property (nonatomic, assign) NSInteger type;
/** 文案标题*/
@property (nonatomic, copy) NSString *title;
/** 简介*/
@property (nonatomic, copy) NSString *brief;
/** 按钮*/
@property (nonatomic, strong) G100BannerButtonDomain *button;

@end

@interface G100BannerButtonDomain : G100BaseDomain

/** 按钮id*/
@property (nonatomic, assign) NSInteger button_id;
/** 类型*/
@property (nonatomic, assign) NSInteger type;
/** 按钮文字*/
@property (nonatomic, copy) NSString *text;
/** 按钮点击链接*/
@property (nonatomic, copy) NSString *url;

@end
