//
//  G100PhotoPickerCell.m
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100PhotoPickerCell.h"
#import "G100PickActionSheet.h"

@implementation G100PhotoPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)addNewPhoto:(UIButton *)sender {
    if (IQKeyHelper.keyboardIsVisible) {
        [CURRENTVIEWCONTROLLER.view endEditing:YES];
        return;
    }
    
    G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc]initWithTitle:nil clickedAtIndex:^(NSInteger index) {
        [self.delegate actionWithButtonIndex:index];
    } cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从手机相册选择",nil];
    [actionSheet show];
}


@end
