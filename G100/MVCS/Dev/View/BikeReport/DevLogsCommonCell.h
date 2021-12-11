//
//  DevLogsCommonCell.h
//  G100
//
//  Created by yuhanle on 16/3/31.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DevLogsCommonCell;
@class DevLogsLocalDomain;
typedef void(^OpenNextView)();

extern NSString * const kNibNameDevLogsNormalCell;
extern NSString * const kNibNameDevLogsErrorCell;
extern NSString * const kNibNameDevLogsNormalDriveCell;
extern NSString * const kNibNameDevLogsUnNormalDriveCell;

@interface DevLogsCommonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *seperateLine;
@property (weak, nonatomic) IBOutlet UIImageView *blackSm;
@property (weak, nonatomic) IBOutlet UIView *cellMianView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightUpView;

@property (weak, nonatomic) IBOutlet UIImageView *upView;
@property (weak, nonatomic) IBOutlet UIImageView *downView;
@property (weak, nonatomic) IBOutlet UILabel *startPoint;
@property (weak, nonatomic) IBOutlet UILabel *endPoint;
@property (weak, nonatomic) IBOutlet UILabel *driveInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *overSpeedHintLabel;

@property (copy, nonatomic) NSString * begintime;
@property (copy, nonatomic) NSString * endtime;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) NSInteger type;

@property (assign, nonatomic) CGFloat cellHeight;

@property (copy, nonatomic) OpenNextView openEvent;

@property (strong, nonatomic) DevLogsLocalDomain *logsLocalDomain;

/**
 *  类方法返回行高
 */
+ (CGFloat)heightForRow:(DevLogsLocalDomain *)logsLocalDomain;

/**
 *  类方法返回可重用的id
 */
+ (NSString *)idForRow:(DevLogsLocalDomain *)logsLocalDomain;

@end
