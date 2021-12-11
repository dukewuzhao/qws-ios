//
//  G100UserAndDevManagementCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/11/22.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100UserDomain;
@class G100BikeDomain;
@interface G100UserAndDevManagementCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rigthIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rankIcon;

- (void)setDomainOfUser:(G100UserDomain *)userDomain bike:(G100BikeDomain *)bikeDomain;

+ (void)registerToTableView:(UITableView *)tableView;
+ (NSString *)cellID;
@end
