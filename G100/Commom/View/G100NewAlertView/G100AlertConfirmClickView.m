//
//  G100AlertConfirmClickView.m
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100AlertConfirmClickView.h"
#import <XXNibBridge.h>

@interface G100AlertConfirmClickView () <XXNibBridge>

@end

@implementation G100AlertConfirmClickView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.confirmButton.backgroundColor = MyNavColor;
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.confirmButton.layer.masksToBounds = YES;
    self.confirmButton.layer.cornerRadius  = 6.0f;
}


+ (instancetype)confirmClickView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100AlertConfirmClickView" owner:self options:nil] lastObject];
}

- (IBAction)confirmButtonClick:(UIButton *)sender {
    if (self.confirmClickBlock) {
        self.confirmClickBlock();
    }
}

@end
