//
//  G10BikeInfoCardViewCell.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G10BikeInfoCardViewCell.h"

@implementation G10BikeInfoCardViewCell

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


@end
