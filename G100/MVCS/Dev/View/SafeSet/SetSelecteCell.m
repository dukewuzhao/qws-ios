//
//  SetSelecteCell.m
//  G100
//
//  Created by Tilink on 15/4/17.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "SetSelecteCell.h"

@implementation SetSelecteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        self.backgroundColor = [UIColor whiteColor];
    }else {
        self.backgroundColor = RGBColor(247, 247, 247, 1.0);
    }
}

@end
