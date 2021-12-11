//
//  G100ConfirmView.m
//  G100
//
//  Created by William on 16/8/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ConfirmView.h"

@implementation G100ConfirmView

- (IBAction)btnConfirmAction:(UIButton *)sender {
    if (self.confirmBtnClick) {
        self.confirmBtnClick(sender.tag);
    }
}

+ (instancetype)loadSingleConfirmView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100SingleConfirmView" owner:self options:nil]firstObject];
}

+ (instancetype)loadDoubleConfirmView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100DoubleConfirmView" owner:self options:nil]firstObject];
}

@end