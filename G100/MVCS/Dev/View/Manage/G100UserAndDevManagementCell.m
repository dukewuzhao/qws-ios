//
//  G100UserAndDevManagementCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/11/22.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserAndDevManagementCell.h"
#import "G100UserDomain.h"
#import "G100BikeDomain.h"
#import <UIImageView+WebCache.h>
@implementation G100UserAndDevManagementCell

+ (NSString *)cellID
{
    return NSStringFromClass([self class]);
}
+ (void)registerToTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:[self cellID] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[self cellID]];
}

- (void)setDomainOfUser:(G100UserDomain *)userDomain bike:(G100BikeDomain *)bikeDomain
{
    if (userDomain.isMaster) {
        self.rigthIcon.hidden = YES;
        self.rankIcon.hidden = NO;
        self.rankIcon.image = [UIImage imageNamed:@"ic_count_rank"];
    }else {
        if (bikeDomain.isMaster) {
            self.rankIcon.hidden = YES;
            self.rigthIcon.hidden = NO;
            self.rigthIcon.image = [UIImage imageNamed:@"ic_arrow"];
        }
        else {
            self.rigthIcon.hidden = YES;
            self.rankIcon.hidden = YES;
        }
    }
    self.userNameLabel.text = userDomain.nickname;
    NSString *headerImgName ;
    if ([userDomain.icon hasPrefix:@"http"]) {
        headerImgName = userDomain.icon;
    }
    else
    {
        headerImgName = [NSString stringWithFormat:@"https://210.22.78.6:9090/file/picture/user/%@", userDomain.icon];
    }
    
    [self.userHeaderImg sd_setImageWithURL:[NSURL URLWithString:headerImgName]
                          placeholderImage:[UIImage imageNamed: [userDomain.gender isEqualToString:@"1"] ? @"ic_default_male" : @"ic_default_female"]];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.userHeaderImg.layer setMasksToBounds:YES];
    [self.userHeaderImg.layer setCornerRadius:6.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
