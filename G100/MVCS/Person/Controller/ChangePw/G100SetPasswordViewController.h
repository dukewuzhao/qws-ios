//
//  G100SetPasswordViewController.h
//  G100
//
//  Created by Tilink on 15/4/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

typedef enum : NSUInteger {
    NOLoginSetPasswprd,
    LoginSetPassword,
} SetPasswordStyle;

@interface G100SetPasswordViewController : G100BaseXibVC <UITextFieldDelegate>

+ (instancetype)loadXibVc;

@property (copy, nonatomic) NSString * testVC;
@property (copy, nonatomic) NSString * phoneNum;
@property (assign, nonatomic) SetPasswordStyle findStyle;

@end
