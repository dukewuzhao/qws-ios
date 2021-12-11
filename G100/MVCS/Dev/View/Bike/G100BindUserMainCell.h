//
//  G100BindUserMainCell.h
//  G100
//
//  Created by William on 16/5/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100BindUserMainCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *identifierImageView;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumLabel;

- (void)setCellDataWithDomain:(G100UserDomain*)domain;

@end
