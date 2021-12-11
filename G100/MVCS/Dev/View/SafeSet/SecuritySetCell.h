//
//  SecurityBaojingqiCell.h
//  G100
//
//  Created by 温世波 on 15/11/13.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecuritySetCell : UITableViewCell

+(instancetype)securitySetCellWithIdentifier:(NSString *)identifier;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *rightSwitch;
@property (weak, nonatomic) IBOutlet UILabel *smallHintLable;

@property (nonatomic, assign) BOOL openStatus;//!< 记录开关的初始状态
@property (copy, nonatomic) void (^rightSwitchBlock) (BOOL result);

@end
