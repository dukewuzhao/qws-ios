//
//  G100AlertCancelClickView.m
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100AlertCancelClickView.h"
#import <XXNibBridge.h>

@interface G100AlertCancelClickView () <XXNibBridge>

@end

@implementation G100AlertCancelClickView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton setTitleColor:MyOrangeColor forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.cancelButton.layer.masksToBounds = YES;
    self.cancelButton.layer.cornerRadius  = 6.0f;
    self.cancelButton.layer.borderWidth = 1.5f;
    self.cancelButton.layer.borderUIColor = MyOrangeColor;
}

- (IBAction)cancelButtonClick:(UIButton *)sender {
    if (self.cancelClickBlock) {
        self.cancelClickBlock();
    }
}

+ (instancetype)loadNibCancelClickView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100AlertCancelClickView" owner:self options:nil] lastObject];
}

@end
