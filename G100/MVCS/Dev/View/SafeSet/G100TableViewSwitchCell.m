//
//  G100TableViewSwitchCell.m
//  G100
//
//  Created by 煜寒了 on 16/1/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100TableViewSwitchCell.h"

@implementation G100TableViewSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)rightSwitchTouchUpinside:(UISwitch *)sender {
    if (sender.on == self.openStatus) {
        return;
    }
    
    if (_rightSwitchBlock) {
        self.rightSwitchBlock(sender.on);
    }
    
    [sender setOn:!sender.on animated:YES];
}

@end
