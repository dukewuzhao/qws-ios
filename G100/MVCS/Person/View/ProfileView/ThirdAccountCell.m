//
//  ThirdAccountCell.m
//  G100
//
//  Created by Tilink on 15/6/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ThirdAccountCell.h"
#import "G100TrAccountDomain.h"

@interface ThirdAccountCell ()

@property (assign, nonatomic) BOOL openStatus;

@end

@implementation ThirdAccountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)showCellWithDomain:(G100TrAccountDomain *)domain {
    self.domain = domain;
    self.on_off.enabled = domain.enable;
    self.on_off.on = domain.isBind;
    self.accountLabel.text = domain.accountName;
    
    self.openStatus = self.on_off.on;
}

- (IBAction)switchOpenOff:(UISwitch *)sender {
    if (sender.on == self.openStatus) {
        return;
    }
    
    [sender setOn:!sender.on animated:YES];
    if ([_delegate respondsToSelector:@selector(authorizeorCancelWithAccount:On_off:)]) {
        if (kNetworkNotReachability) {
            [CURRENTVIEWCONTROLLER showHint:kError_Network_NotReachable];
        }else {
            [self.delegate authorizeorCancelWithAccount:self.domain On_off:sender.on];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    // Configure the view for the selected state
}

@end
