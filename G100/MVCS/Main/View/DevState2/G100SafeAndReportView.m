//
//  G100SafeAndReportView.m
//  G100
//
//  Created by sunjingjing on 17/2/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100SafeAndReportView.h"
#import "NotificationHelper.h"

@implementation G100SafeAndReportView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100SafeAndReportView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width{
    return width * 30/207;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setSafeMode:(DEV_SECSET_MODE)safeMode {
    _safeMode = safeMode;
    
    NSString *imageName = @"";
    NSString *reportImageName = @"ic_report_normal";
    self.safeSetInfo.textColor = [UIColor colorWithHexString:@"A0A0A0"];
    
    // 先判断用户是否开启推送功能
    if (![[NotificationHelper shareInstance] notificationServicesEnabled]) {
        imageName = @"ic_report_close";
        self.safeSetInfo.text = @"系统推送未打开";
    }else {
        switch (safeMode) {
            case DEV_SECSET_MODE_WARN:
            {
                imageName = @"ic_safe_warn";
                self.safeSetInfo.text = @"警戒模式";
            }
                break;
            case DEV_SECSET_MODE_STANDARD:
            {
                imageName = @"ic_safe_normal";
                self.safeSetInfo.text = @"标准模式";
            }
                break;
            case DEV_SECSET_MODE_NODISTURB:
            {
                imageName = @"ic_safe_quiet";
                self.safeSetInfo.text = @"免打扰模式";
            }
                break;
            case DEV_SECSET_MODE_DEVLOST:
            {
                imageName = @"ic_report_find";
                self.safeSetInfo.text = @"寻车时模式不可切换";
                reportImageName = @"ic_report_find";
                self.safeSetInfo.textColor = [UIColor colorWithHexString:@"FF6600"];
            }
                break;
            case DEV_SECSET_MODE_DISARMING:
            {
                imageName = @"ic_safe_close";
                self.safeSetInfo.text = @"关闭通知";
            }
                break;
            default:
                imageName = @"ic_safe_normal";
                self.safeSetInfo.text = @"标准模式";
                break;
        }
    }
    
    self.safeSetImageView.image = [UIImage imageNamed:imageName];
    //TODO:下个版本加入寻车提示图片 同步用车报告内部修改
    // self.bikeReportImageView.image = [UIImage imageNamed:reportImageName];
}

-(void)setUnreadMsgCount:(NSInteger)unreadMsgCount{
    _unreadMsgCount = unreadMsgCount;
    if (unreadMsgCount >0) {
        self.unreadImageView.image = [UIImage imageNamed:@"ic_main_red_dot"];
        self.unreadImageView.hidden = NO;
    }else {
        self.unreadImageView.hidden = YES;
    }
}
- (IBAction)viewTappedSafeSet:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushCardSafeSetDetailWithView:)]) {
        [self.delegate viewTapToPushCardSafeSetDetailWithView:self];
    }
}

- (IBAction)viewTappedReport:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushCardSafeSetDetailWithView:)]) {
        [self.delegate viewTapToPushCardReportDetailWithView:self];
    }
}

@end
