//
//  MyAlertView.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//
#import "MyAlertView.h"

@implementation MyAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        // Initialization code
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (self.alertBlock) {
        self.alertBlock(buttonIndex);
    }
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate withMyAlertBlock:(MyAlertBlock)alertBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    self = [ super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        self.alertBlock = alertBlock;
    }
    
    return self;
}

+ (void)MyAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate withMyAlertBlock:(MyAlertBlock)alertBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    MyAlertView * alert = [[MyAlertView alloc]initWithTitle:title message:message delegate:self withMyAlertBlock:alertBlock cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
    [alert show];
}

@end
