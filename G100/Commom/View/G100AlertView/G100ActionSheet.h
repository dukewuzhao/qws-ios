//
//  G100ActionSheet.h
//  G100
//
//  Created by Tilink on 15/5/18.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^G100ActionSheetSelected)(NSInteger buttonIndex);

@interface G100ActionSheet : UIActionSheet <UIActionSheetDelegate>

@property (copy, nonatomic) G100ActionSheetSelected actionSheetSelected;
@property (strong, nonatomic) NSArray * buttons;

+(void)actionSheetWithTitle:(NSString *)title andBlock:(G100ActionSheetSelected)actionSheetSelected view:(UIView *)view cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
