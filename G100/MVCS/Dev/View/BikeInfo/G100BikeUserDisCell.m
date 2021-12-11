//
//  G100BikeUserDisCell.m
//  G100
//
//  Created by yuhanle on 2017/6/3.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeUserDisCell.h"

#import <UIImageView+WebCache.h>

#define DetailHintColorNormal @"8b8b8b"
#define DetailHintColorWaitShenhe @"ff7800"

@interface G100BikeUserDisCell ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailHintLabel;

@property (weak, nonatomic) IBOutlet UIButton *menuArrowBtn;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) G100UserDomain *userDomain;

@property (nonatomic, assign) BOOL isYourself;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHintToSuperRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHintToArrowRight;

@end

@implementation G100BikeUserDisCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 25.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (!highlighted) {
        self.backgroundColor = [UIColor whiteColor];
    }else {
        self.backgroundColor = [UIColor colorWithHexString:@"dedede"];
    }
}

- (void)setUserDomain:(G100UserDomain *)userDomain {
    _userDomain = userDomain;
    
    [self updateUI];
}

- (void)setUserDomain:(G100UserDomain *)userDomain isYourself:(BOOL)yourself {
    _userDomain = userDomain;
    _isYourself = yourself;
    
    [self updateUI];
}

- (void)updateUI {
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.userDomain.icon] placeholderImage:[self.userDomain.gender isEqualToString:@"1"] ? [UIImage imageNamed:@"ic_default_male"] : [UIImage imageNamed:@"ic_default_female"]];
    
    NSString *username = self.isYourself ? self.userDomain.nick_name : (self.userDomain.comment.length ? self.userDomain.comment : self.userDomain.nick_name);
    self.usernameLabel.text = username;
    
    if (self.userDomain.isMaster) {
        self.menuArrowBtn.hidden = YES;
        
        self.constraintHintToArrowRight.priority = 749;
        self.constraintHintToSuperRight.priority = 999;
    } else {
        self.menuArrowBtn.hidden = NO;
        
        self.constraintHintToArrowRight.priority = 999;
        self.constraintHintToSuperRight.priority = 749;
    }
    
    if (self.userDomain.user_status == 1) {
        self.detailHintLabel.textColor = [UIColor colorWithHexString:DetailHintColorNormal];
        NSString *userHint = self.userDomain.isMaster == 1 ? @"主用户" : @"副用户";
        self.detailHintLabel.text = userHint;
        
        if (self.isYourself) {
            self.usernameLabel.textColor = [UIColor colorWithHexString:@"0a9221"];
        } else {
            self.usernameLabel.textColor = [UIColor blackColor];
        }
    } else if (self.userDomain.user_status == 2) {
        self.detailHintLabel.textColor = [UIColor colorWithHexString:DetailHintColorWaitShenhe];
        self.detailHintLabel.text = @"副用户审核";
        self.usernameLabel.textColor = [UIColor colorWithHexString:@"f5a623"];
    } else {
        
    }
}

@end
