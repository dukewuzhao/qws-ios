//
//  G100TopHintViewCell.m
//  G100
//
//  Created by 曹晓雨 on 2017/4/20.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TopHintViewCell.h"
#import "NSString+CalHeight.h"

@implementation G100TopHintViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.hintLabel.numberOfLines = 0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.alpha = 0.64;
    } else {
        self.alpha = 1.0;
    }
}

@end
