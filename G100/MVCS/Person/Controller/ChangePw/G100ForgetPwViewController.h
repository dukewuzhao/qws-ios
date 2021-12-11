//
//  G100ForgetPwViewController.h
//  G100
//
//  Created by Tilink on 15/4/26.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

typedef enum : NSUInteger {
    NOLoginFindPasswprd,
    LoginFindPassword,
} FindPasswordStyle;

@interface G100ForgetPwViewController : G100BaseXibVC

@property (assign, nonatomic) FindPasswordStyle findStyle;

@end
