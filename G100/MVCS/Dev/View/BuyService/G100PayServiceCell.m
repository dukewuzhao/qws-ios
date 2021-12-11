//
//  G100PayServiceCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PayServiceCell.h"
#import "G100GoodDomain.h"

@implementation G100PayServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showUIWithModel:(G100GoodDomain *)model {
    // 设置不可选中
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.nameLabel.text = model.name;
    self.leftImageView.image = [UIImage imageNamed:@"ic_product"];
    NSString * servicemonths = [NSString stringWithFormat:@"%ld个月", (long)model.service_months];
    self.serLabel.text = servicemonths;
    self.masterLabel.text = [NSString stringWithFormat:@"服务期至：%@", model.serviceenddate];
    self.bikeForService.text = [NSString stringWithFormat:@"所属车辆: %@", model.bike_name];
}

@end
