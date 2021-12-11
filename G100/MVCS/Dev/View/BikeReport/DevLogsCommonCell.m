//
//  DevLogsCommonCell.m
//  G100
//
//  Created by yuhanle on 16/3/31.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DevLogsCommonCell.h"
#import "DevLogsLocalDomain.h"

#import "NSString+CalHeight.h"
NSString * const kNibNameDevLogsNormalCell        = @"DevLogsNormalCell";
NSString * const kNibNameDevLogsErrorCell         = @"DevLogsErrorCell";
NSString * const kNibNameDevLogsNormalDriveCell   = @"DevLogsNormalDriveCell";
NSString * const kNibNameDevLogsUnNormalDriveCell = @"DevLogsUnNormalDriveCell";

@interface DevLogsCommonCell ()

@property (strong, nonatomic) UITapGestureRecognizer * gesture;

@end

@implementation DevLogsCommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLogsLocalDomain:(DevLogsLocalDomain *)logsLocalDomain {
    _logsLocalDomain = logsLocalDomain;
    self.type = logsLocalDomain.type;
    
    self.cellMianView.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.msgLabel.textColor = [UIColor lightGrayColor];
    self.timeLabel.text = [logsLocalDomain.ts substringToIndex:5];
    
    self.v_height = logsLocalDomain.cellHeight;
    
    if (logsLocalDomain.type == REPT_MSG_CODE_NORMAL_DRIVE ||
        logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DRIVE)
    {
        [self showDriveCellWithDomain:logsLocalDomain];
    }
    
    else if (logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DATA ||
              logsLocalDomain.type == REPT_MSG_CODE_DEV_SHAKE ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_OPEN ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_CLOSE ||
              logsLocalDomain.type == REPT_MSG_CODE_BATTERY_IN ||
              logsLocalDomain.type == REPT_MSG_CODE_BATTERY_OUT ||
              logsLocalDomain.type == REPT_MSG_CODE_VOLTAGE_LOW ||
              logsLocalDomain.type == REPT_MSG_CODE_ALARM_REMOVE ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_ILLEGAL_OPEN)
    {
        [self showNormalCellWithDomain:logsLocalDomain];
    }
    
    else if (logsLocalDomain.type == REPT_MSG_CODE_DEV_FAULT ||
              logsLocalDomain.type == REPT_MSG_CODE_ILLEGAL_DIS ||
              logsLocalDomain.type == REPT_MSG_CODE_MATCH_FAULT ||
              logsLocalDomain.type == REPT_MSG_CODE_COMM_FAULT)
    {
        [self showErrorCellWithDomain:logsLocalDomain];
    }
}

-(void)showNormalCellWithDomain:(DevLogsLocalDomain *)logsLocalDomain {
    self.titleLabel.text = logsLocalDomain.title;
    
    if (!logsLocalDomain.msg.length) {
        self.msgLabel.hidden = YES;
        self.titleLabel.v_width = WIDTH - 96 - 28;
    }else {
        self.msgLabel.hidden = NO;
        self.titleLabel.v_width = 80;
    }
    
    self.msgLabel.text = logsLocalDomain.msg;
    
    if (_type != REPT_MSG_CODE_DEV_SHAKE) {
        if (_gesture) {
            [self.cellMianView removeGestureRecognizer:self.gesture];
            self.gesture = nil;
        }
        
        self.rightUpView.hidden = YES;
    }else {
        if (!_gesture) {
            self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taptoOpenView:)];
            [self.cellMianView addGestureRecognizer:self.gesture];
        }
        
        self.rightUpView.hidden = NO;
    }
    
    switch (_type) {
        case REPT_MSG_CODE_UNNORMAL_DATA:
        {   // 处理特殊情况
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_shake"];
            self.titleLabel.textColor = [UIColor blackColor];
            self.msgLabel.textColor = [UIColor lightGrayColor];
        }
            break;
        case REPT_MSG_CODE_DEV_SHAKE:
        {
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_shake"];
            self.titleLabel.textColor = [UIColor blackColor];
            self.msgLabel.textColor = [UIColor lightGrayColor];
        }
            break;
        case REPT_MSG_CODE_SWITCH_OPEN:
        {
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_elec_open"];
            self.titleLabel.textColor = [UIColor blackColor];
            self.msgLabel.textColor = [UIColor lightGrayColor];
        }
            break;
        case REPT_MSG_CODE_SWITCH_CLOSE:
        {
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_lock"];
            self.titleLabel.textColor = [UIColor blackColor];
            self.msgLabel.textColor = [UIColor lightGrayColor];
        }
            break;
        case REPT_MSG_CODE_BATTERY_IN: // 电瓶插入
        {
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_power_move"];
        }
            break;
        case REPT_MSG_CODE_BATTERY_OUT:
        {
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_power_move"];
            self.titleLabel.textColor = [UIColor redColor];
            self.msgLabel.textColor = [UIColor redColor];
        }
            break;
        case REPT_MSG_CODE_VOLTAGE_LOW: // 低电量
        {
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_power_low"];
        }
            break;
        default:
            self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_shake"];
            break;
    }
    
    if (logsLocalDomain.hasYanzhong) {
        self.titleLabel.textColor = [UIColor redColor];
        self.msgLabel.textColor = [UIColor redColor];
    }
    
    // 新增报警器移除 电门打开错误
    if (_type == REPT_MSG_CODE_ALARM_REMOVE) {
        self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_alarm_remove"];
        self.titleLabel.textColor = [UIColor redColor];
        self.msgLabel.textColor = [UIColor redColor];
    }else if (_type == REPT_MSG_CODE_SWITCH_ILLEGAL_OPEN) {
        self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_switch_open"];
        self.titleLabel.textColor = [UIColor redColor];
        self.msgLabel.textColor = [UIColor redColor];
    }
}

-(void)showErrorCellWithDomain:(DevLogsLocalDomain *)logsLocalDomain {
    self.titleLabel.text = logsLocalDomain.msg;
    
    if (_type == REPT_MSG_CODE_COMM_FAULT) {
        self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_commfault"];
        self.titleLabel.textColor = [UIColor redColor];
        self.msgLabel.textColor = [UIColor redColor];
    }
    
    if (_type == REPT_MSG_CODE_DEV_FAULT || _type == REPT_MSG_CODE_ILLEGAL_DIS || _type == REPT_MSG_CODE_MATCH_FAULT) {
        self.leftImage.image = [UIImage imageNamed:@"ic_dev_logs_fault"];
        self.titleLabel.textColor = [UIColor redColor];
        self.msgLabel.textColor = [UIColor redColor];
    }
}

-(void)showDriveCellWithDomain:(DevLogsLocalDomain *)logsLocalDomain {
    self.startPoint.text = logsLocalDomain.road;
    self.endPoint.text = logsLocalDomain.area;
    self.status = logsLocalDomain.status;
    
    NSInteger time = [logsLocalDomain.time integerValue];
    NSMutableString * timeStr = [[NSMutableString alloc] init];
    if (time / 60) {
        if (time / 60 / 60) {
            [timeStr appendFormat:@"%.1lf小时", (float)time / 60.0 / 60.0];
        }else [timeStr appendFormat:@"%.1lf分钟", (float)time / 60.0];
    }else [timeStr appendFormat:@"%.1ld秒", (long)time];
    
    self.driveInfoLabel.text = [NSString stringWithFormat:@"%.1lfkm  %@  %.1lfkm/h", [logsLocalDomain.distance floatValue], timeStr, [logsLocalDomain.speed floatValue]];
    
    if (logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DRIVE) {
        self.cellMianView.layer.borderColor = [UIColor colorWithRed:232.0f / 255.0f green:127.0f / 255.0f blue:111.0f / 255.0f alpha:1.0f].CGColor;
        self.cellMianView.layer.borderWidth = 0.8f;
    }else {
        self.cellMianView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.cellMianView.layer.borderWidth = 0.4f;
    }
    
    self.begintime = logsLocalDomain.begintime;
    self.endtime = logsLocalDomain.endtime;
    
    if (!_gesture) {
        self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taptoOpenView:)];
        [self.cellMianView addGestureRecognizer:self.gesture];
    }
    if (logsLocalDomain.topSpeedOpen && logsLocalDomain.overSpeedOpen) {
        if (logsLocalDomain.remindtype == 0) {
            self.overSpeedHintLabel.hidden = YES;
        }else if (logsLocalDomain.remindtype == 1){
            self.overSpeedHintLabel.hidden = NO;
            self.overSpeedHintLabel.text = logsLocalDomain.remindcontent;
            self.overSpeedHintLabel.textColor = [UIColor blackColor];
        }else if (logsLocalDomain.remindtype == 2){
            self.overSpeedHintLabel.hidden = NO;
            self.overSpeedHintLabel.text = logsLocalDomain.remindcontent;
            self.overSpeedHintLabel.textColor = [UIColor redColor];
        }else{
            self.overSpeedHintLabel.hidden = YES;
        }
    }else{
         self.overSpeedHintLabel.hidden = YES;
    }
   
   }

#pragma mark - /****************** 点击MainView 的事件 ********************/
- (void)taptoOpenView:(UITapGestureRecognizer *)gesture {
    if (_openEvent) {
        self.openEvent();
    }
}

#pragma mark - /****************** 类方法返回行高 ********************/
+ (CGFloat)heightForRow:(DevLogsLocalDomain *)logsLocalDomain {
    if (0 != logsLocalDomain.cellHeight) {
        return logsLocalDomain.cellHeight;
    }
    
    if (logsLocalDomain.type == REPT_MSG_CODE_NORMAL_DRIVE) {
        if (logsLocalDomain.remindtype == 0) {
             logsLocalDomain.cellHeight = 90;
        }else{
            CGFloat remindContentStrHeight;
            if (logsLocalDomain.topSpeedOpen && logsLocalDomain.overSpeedOpen) {
                remindContentStrHeight = [NSString heightWithText:logsLocalDomain.remindcontent fontSize:[UIFont systemFontOfSize:14] Width:WIDTH - 102];
            }else{
                remindContentStrHeight = 0;
            }
            logsLocalDomain.cellHeight = 125 + remindContentStrHeight - 21;
        }
    }else if (logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DRIVE) {
        logsLocalDomain.cellHeight = 130;
    }else if (logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DATA ||
              logsLocalDomain.type == REPT_MSG_CODE_DEV_SHAKE ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_OPEN ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_CLOSE ||
              logsLocalDomain.type == REPT_MSG_CODE_BATTERY_IN ||
              logsLocalDomain.type == REPT_MSG_CODE_BATTERY_OUT ||
              logsLocalDomain.type == REPT_MSG_CODE_VOLTAGE_LOW ||
              logsLocalDomain.type == REPT_MSG_CODE_ALARM_REMOVE ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_ILLEGAL_OPEN) {
        logsLocalDomain.cellHeight = 44;
    }else if (logsLocalDomain.type == REPT_MSG_CODE_DEV_FAULT ||
              logsLocalDomain.type == REPT_MSG_CODE_ILLEGAL_DIS ||
              logsLocalDomain.type == REPT_MSG_CODE_MATCH_FAULT ||
              logsLocalDomain.type == REPT_MSG_CODE_COMM_FAULT) {
        logsLocalDomain.cellHeight = 44;
    }else {
        logsLocalDomain.cellHeight = 44;
    }
    
    return logsLocalDomain.cellHeight;
}

#pragma mark - /****************** 类方法返回可重用ID ********************/
+ (NSString *)idForRow:(DevLogsLocalDomain *)logsLocalDomain {
    if (logsLocalDomain.type == REPT_MSG_CODE_NORMAL_DRIVE) {
        return kNibNameDevLogsNormalDriveCell;
    }else if (logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DRIVE) {
        return kNibNameDevLogsUnNormalDriveCell;
    }else if (logsLocalDomain.type == REPT_MSG_CODE_UNNORMAL_DATA ||
              logsLocalDomain.type == REPT_MSG_CODE_DEV_SHAKE ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_OPEN ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_CLOSE ||
              logsLocalDomain.type == REPT_MSG_CODE_BATTERY_IN ||
              logsLocalDomain.type == REPT_MSG_CODE_BATTERY_OUT ||
              logsLocalDomain.type == REPT_MSG_CODE_VOLTAGE_LOW ||
              logsLocalDomain.type == REPT_MSG_CODE_ALARM_REMOVE ||
              logsLocalDomain.type == REPT_MSG_CODE_SWITCH_ILLEGAL_OPEN) {
        return kNibNameDevLogsNormalCell;
    }else if (logsLocalDomain.type == REPT_MSG_CODE_DEV_FAULT ||
              logsLocalDomain.type == REPT_MSG_CODE_ILLEGAL_DIS ||
              logsLocalDomain.type == REPT_MSG_CODE_MATCH_FAULT ||
              logsLocalDomain.type == REPT_MSG_CODE_COMM_FAULT) {
        return kNibNameDevLogsErrorCell;
    }
    
    return kNibNameDevLogsNormalCell;
}

@end
