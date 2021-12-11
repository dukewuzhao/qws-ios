//
//  G100UpdateVersionCell.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100UpdateVersionCell.h"

@implementation G100UpdateVersionCell
+ (instancetype)loadXibView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100UpdateVersionCell" owner:self options:nil] lastObject];
}

+ (void)registerNibCell:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:@"G100UpdateVersionCell" bundle:nil] forCellReuseIdentifier:@"G100UpdateVersionCell"];
}

+ (CGFloat)heightForDesc:(NSString *)desc {
    CGSize size = [desc calculateSize:CGSizeMake(WIDTH - 40, 999) font:[UIFont systemFontOfSize:14]];
    return 80 - 24 + size.height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _titleLabel.text = title;
}

- (void)setDesc:(NSString *)desc {
    _desc = desc;
    
    _textView.text = desc;
}

@end
