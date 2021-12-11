//
//  MyAlertView.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface MyAlertView : UIAlertView<UIAlertViewDelegate>

typedef void (^MyAlertBlock)(NSInteger buttonIndex);

@property (nonatomic,copy) MyAlertBlock alertBlock;

+ (void)MyAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate withMyAlertBlock:(MyAlertBlock)alertBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
