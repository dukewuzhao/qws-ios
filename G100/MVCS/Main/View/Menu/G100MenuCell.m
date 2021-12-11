//
//  G100MenuCell.m
//  G100
//
//  Created by William on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MenuCell.h"

@implementation G100MenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"1D1D1D"];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"303030"];
    }
}

- (void)setNeedNoticeDot:(BOOL)needNoticeDot {
    _needNoticeDot = needNoticeDot;
    self.redDotImageView.hidden = !needNoticeDot;
}

@end
