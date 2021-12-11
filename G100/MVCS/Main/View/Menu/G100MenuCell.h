//
//  G100MenuCell.h
//  G100
//
//  Created by William on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100MenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *menuImageView;
@property (strong, nonatomic) IBOutlet UILabel *menuTitle;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *redDotImageView;
@property (assign, nonatomic) BOOL needNoticeDot;

@end
