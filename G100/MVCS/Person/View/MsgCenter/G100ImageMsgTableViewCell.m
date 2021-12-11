//
//  G100ImageMsgTableViewCell.m
//  G100
//
//  Created by William on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ImageMsgTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "NSDate+TimeString.h"
#import "G100MsgDomain.h"

@interface G100ImageMsgTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *unreadMarkImageview;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageview;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lycContentToptoTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lycContentToptoImage;

@end

@implementation G100ImageMsgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentImageview.layer.masksToBounds = YES;
    self.contentImageview.layer.cornerRadius = 3.0;
    self.contentLabel.numberOfLines = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)setDomain:(G100MsgDomain *)domain {
    _domain = domain;
    [self updateUI];
}

- (void)updateUI {
    self.unreadMarkImageview.hidden = _domain.hasRead;
    self.titleLabel.text = _domain.mctitle;
    self.timeLabel.text = [NSDate getMsgTimeWithSp:_domain.mcts];
    
    NSArray *contentArray = [_domain.mcdesc componentsSeparatedByString:@"<img>"];
    if (contentArray.count == 2) {
        self.contentImageview.hidden = NO;
        self.lycContentToptoImage.priority = 999;
        self.lycContentToptoTitle.priority = 749;
        [self.contentImageview sd_setImageWithURL:[NSURL URLWithString:[contentArray firstObject]] placeholderImage:[UIImage imageNamed:@"ic_my_msg_default"]];
    }else {
        self.contentImageview.hidden = YES;
        self.lycContentToptoImage.priority = 749;
        self.lycContentToptoTitle.priority = 999;
    }
    
    self.contentLabel.text = [contentArray lastObject];
    self.editBtn.selected = _domain.hasPicked;
}

@end
