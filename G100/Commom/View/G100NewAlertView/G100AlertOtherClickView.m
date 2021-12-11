//
//  G100AlertOtherClickView.m
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100AlertOtherClickView.h"
#import <XXNibBridge.h>

@interface G100AlertOtherClickView () <XXNibBridge>

@end

@implementation G100AlertOtherClickView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.otherButton.backgroundColor = [UIColor whiteColor];
    [self.otherButton setTitleColor:MyGreenColor forState:UIControlStateNormal];
    self.otherButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.otherButton.layer.masksToBounds = YES;
    self.otherButton.layer.cornerRadius  = 6.0f;
    self.otherButton.layer.borderWidth = 1.5f;
    self.otherButton.layer.borderUIColor = MyGreenColor;
}


- (IBAction)otherButtonClick:(UIButton *)sender {
    if (self.otherClickBlock) {
        self.otherClickBlock();
    }
}

@end
