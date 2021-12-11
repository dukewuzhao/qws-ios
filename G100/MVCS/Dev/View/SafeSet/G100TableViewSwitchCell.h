//
//  G100TableViewSwitchCell.h
//  G100
//
//  Created by 煜寒了 on 16/1/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100TableViewSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *hintTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *rightSwitch;

@property (nonatomic, assign) BOOL openStatus;//!< 记录开关的初始状态
@property (copy, nonatomic) void (^rightSwitchBlock) (BOOL result);

@end
