//
//  G100OptionsCell.m
//  G100
//
//  Created by William on 16/8/16.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100OptionsCell.h"

@implementation G100OptionsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (UIImageView *)optionImageView {
    if (!_optionImageView) {
        _optionImageView = [[UIImageView alloc]init];
    }
    return _optionImageView;
}

- (UILabel *)optionLabel {
    if (!_optionLabel) {
        _optionLabel = [[UILabel alloc]init];
    }
    return _optionLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.optionImageView];
    [self.optionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@26);
        make.centerY.equalTo(self.mas_centerY);
        make.leading.equalTo(@0);
    }];
    
    [self addSubview:self.optionLabel];
    [self.optionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.optionImageView.mas_trailing).with.offset(10);
        make.trailing.equalTo(@10);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
