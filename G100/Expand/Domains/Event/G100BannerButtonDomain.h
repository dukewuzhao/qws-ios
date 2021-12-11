//
//  G100BannerDomain.h
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

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
