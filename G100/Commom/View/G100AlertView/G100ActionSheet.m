//
//  G100ActionSheet.m
//  G100
//
//  Created by Tilink on 15/5/18.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100ActionSheet.h"

@implementation G100ActionSheet

+(void)actionSheetWithTitle:(NSString *)title andBlock:(G100ActionSheetSelected)actionSheetSelected view:(UIView *)view cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    G100ActionSheet * actionSheet = [[G100ActionSheet alloc]initWithTitle:title andBlock:actionSheetSelected delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
    
    [actionSheet showInView:view];
}

-(instancetype)initWithTitle:(NSString *)title andBlock:(G100ActionSheetSelected)actionSheetSelected delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super initWithTitle:title delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil]) {
        
        self.actionSheetSelected = actionSheetSelected;
    }
    
    return self;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_actionSheetSelected) {
        self.actionSheetSelected(buttonIndex);
    }
}

@end
