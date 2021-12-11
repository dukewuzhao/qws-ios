//
//  SecurityBaojingqiCell.m
//  G100
//
//  Created by 温世波 on 15/11/13.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "SecuritySetCell.h"

@interface SecuritySetCell ()

@end

@implementation SecuritySetCell

+(instancetype)securitySetCellWithIdentifier:(NSString *)identifier {
    NSArray * arr = [[NSBundle mainBundle] loadNibNamed:@"SecuritySetCell" owner:self options:nil];
    if ([identifier isEqualToString:@"baojingqicell"]) {
        return arr[0];
    }else if ([identifier isEqualToString:@"yaokongqicell"]) {
        return arr[1];
    }
    return arr[1];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
