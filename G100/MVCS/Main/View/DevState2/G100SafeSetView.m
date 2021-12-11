//
//  G100SafeSetView.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100SafeSetView.h"
#import "NotificationHelper.h"

@implementation G100SafeSetView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100SafeSetView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width{
    return width * 30/197;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}
- (void)setSafeMode:(DEV_SECSET_MODE)safeMode {
    _safeMode = safeMode;
    
    NSString *imageName = @"";
    NSString *bgImageName = @"ic_card_normalnew";
    
    // 先判断用户是否开启推送功能
    if (![[NotificationHelper shareInstance] notificationServicesEnabled]) {
        imageName = @"ic_map_mode_warn";
        bgImageName = @"ic_card_middlenew";
        self.safeSetInfo.text = @"系统推送未打开";
    }else {
        switch (safeMode) {
            case DEV_SECSET_MODE_WARN:
            {
                imageName = @"ic_map_mode_jingjie";
                self.safeSetInfo.text = @"警戒模式";
            }
                break;
            case DEV_SECSET_MODE_STANDARD:
            {
                imageName = @"ic_map_mode_normal";
                self.safeSetInfo.text = @"标准模式";
            }
                break;
            case DEV_SECSET_MODE_NODISTURB:
            {
                imageName = @"ic_map_mode_nowarn";
                self.safeSetInfo.text = @"免打扰模式";
            }
                break;
            case DEV_SECSET_MODE_DEVLOST:
            {
                imageName = @"ic_map_mode_find";
                bgImageName = @"ic_card_import";
                self.safeSetInfo.text = @"丢车模式";
            }
                break;
            case DEV_SECSET_MODE_DISARMING:
            {
                imageName = @"ic_map_mode_close";
                self.safeSetInfo.text = @"关闭通知";
            }
                break;
            default:
                imageName = @"ic_map_mode_normal";
                self.safeSetInfo.text = @"标准模式";
                break;
        }
    }
    
    self.safeSetImageView.image = [UIImage imageNamed:imageName];
    self.safeSetBgImageView.image = [UIImage imageNamed:bgImageName];
}
- (IBAction)viewTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushCardSafeSetDetailWithView:)]) {
        [self.delegate viewTapToPushCardSafeSetDetailWithView:self];
    }
}
@end
