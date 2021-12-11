//
//  G100BindUserMainCell.m
//  G100
//
//  Created by William on 16/5/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BindUserMainCell.h"

@implementation G100BindUserMainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellDataWithDomain:(G100UserDomain*)domain {
    // 判断是否是主用户
    self.identifierImageView.hidden = !domain.isMaster;
    
    self.userNameLabel.text = domain.nickname;
    self.phoneNumLabel.text = [NSString shieldImportantInfo:domain.phonenum];
}


@end
