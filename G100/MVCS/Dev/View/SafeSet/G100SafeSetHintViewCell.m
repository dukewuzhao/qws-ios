//
//  G100SafeSetHintViewCell.m
//  G100
//
//  Created by 曹晓雨 on 2017/11/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100SafeSetHintViewCell.h"

@implementation G100SafeSetHintViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)detailBtnAction:(id)sender {
    self.detailBtnClicked();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
