//
//  G100CardViewCell.m
//  G100
//
//  Created by yuhanle on 16/7/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardViewCell.h"

#define Line_Spacing 12.0
#define Side_Spacing 9.0

@implementation G100CardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupView{
    UIView * containerView = [[UIView alloc]init];
    [self.contentView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    self.containerView = containerView;
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)setupShadowView {
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 2);
    self.containerView.layer.shadowOpacity = 0.4;
    self.containerView.layer.shadowRadius = 2;
}

- (void)setupRightShadowView {
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(2, 0);
    self.containerView.layer.shadowOpacity = 0.4;
    self.containerView.layer.shadowRadius = 2;
}

- (void)refreshShadowView {
    self.containerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(2, 2);
    self.containerView.layer.shadowOpacity = 0.8;
    self.containerView.layer.shadowRadius = 2;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}
- (void)refreshNomalView {
    self.containerView.layer.shadowColor = [UIColor clearColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.containerView.layer.shadowOpacity = 0;
    self.containerView.layer.shadowRadius = 0;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}

@end
