//
//  SetSelecteCell.h
//  G100
//
//  Created by Tilink on 15/4/17.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetSelecteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusTitle;
@property (weak, nonatomic) IBOutlet UILabel *statusContent;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@property (assign, nonatomic) BOOL enabled;

@end
