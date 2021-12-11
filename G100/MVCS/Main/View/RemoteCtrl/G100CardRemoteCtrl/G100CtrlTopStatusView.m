//
//  G100CtrlTopStatusView.m
//  G100CtrlTopStatusView
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "G100CtrlTopStatusView.h"
#import "G100RTCollectionViewCell.h"

#define kBLEColor [UIColor colorWithRed:26/255.0 green:152/255.0 blue:252/255.0 alpha:1.0]
#define kGPRSColor [UIColor colorWithHexString:@"A0A0A0"]

#define kBLEColor1 [UIColor colorWithRed:26/255.0 green:152/255.0 blue:252/255.0 alpha:1.0]
#define kGPRSColor1 [UIColor colorWithRed:53/255.0 green:179/255.0 blue:30/255.0 alpha:1.0]

#define kBigFont [UIFont boldSystemFontOfSize:16]
#define kSmallFont [UIFont systemFontOfSize:12]

static NSString *const kAisleConnectedStatusGPSText = @"网络信号已连接";
static NSString *const kAisleConnectedStatusBLEText = @"蓝牙信号已连接";

static NSString *const kBleStatusImageName_open = @"ic_rc_ble_open";
static NSString *const kBleStatusImageName_close = @"ic_rc_ble_close";
static NSString *const kGprsStatusImageName_siginal = @"ic_rc_gps_signal";
static NSString *const kGprsStatusImageName_close = @"ic_rc_gps_close";

static NSString *const kSecurityStatus_s = @"ic_remote_sfang";
static NSString *const kSecurityStatus_c = @"ic_remote_cfang";

@interface G100CtrlTopStatusView () <G100CustomSwitchDelegate>

/**
 *  Left
 */
@property (nonatomic, strong) UILabel *leftTitleLabel;
@property (nonatomic, strong) UILabel *deviceConnectedStatusLabel;
@property (nonatomic, strong) UILabel *commandStatusLabel;
@property (nonatomic, strong) UIImageView *commandStatusImageView;

/**
 *  Right
 */
@property (nonatomic, strong) UIImageView *bleStatusImageView;
@property (nonatomic, strong) UIImageView *gprsStatusImageView;
@property (nonatomic, strong) UILabel *aisleConnectedStatusLabel;

@property (nonatomic, strong) UIImageView *securityStatusImageView;
@property (nonatomic, strong) UILabel *securityStatusLabel;

/**
 *  当前正在执行的指令
 */
@property (nonatomic, assign) int current_command;

@end

@implementation G100CtrlTopStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        self.current_command = -1;
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    /** 左半侧 布局*/
    self.leftTitleLabel = [[UILabel alloc] init];
    self.leftTitleLabel.font = kBigFont;
    self.leftTitleLabel.textColor = [UIColor colorWithHexString:@"000000"];
    self.leftTitleLabel.text = @"远程遥控";
    [self addSubview:self.leftTitleLabel];
    
    /*
    self.deviceConnectedStatusLabel = [[UILabel alloc] init];
    self.deviceConnectedStatusLabel.font = [UIFont boldSystemFontOfSize:16];
    self.deviceConnectedStatusLabel.textColor = [UIColor lightGrayColor];
    self.deviceConnectedStatusLabel.text = @"已检测到云安全智能防盗套装";
    [self addSubview:self.deviceConnectedStatusLabel];
     */
    
    self.commandStatusLabel = [[UILabel alloc] init];
    self.commandStatusLabel.font = [UIFont systemFontOfSize:12];
    self.commandStatusLabel.textColor = [UIColor colorWithHexString:@"A0A0A0"];
    self.commandStatusLabel.text = @"正在开启座桶锁...";
    [self addSubview:self.commandStatusLabel];
    
    /*
    self.commandStatusImageView = [[UIImageView alloc] init];
    self.commandStatusImageView.image = [UIImage imageNamed:@"ic_animaion0"];
    [self addSubview:self.commandStatusImageView];
     */
    
    [self.leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.leading.equalTo(@16);
    }];
    [self.commandStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.leftTitleLabel.mas_bottom);
        make.leading.equalTo(self.leftTitleLabel.mas_trailing).with.offset(10);
    }];
    
    /*
    [self.deviceConnectedStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.leftTitleLabel.mas_leading);
        make.bottom.equalTo(@-10);
    }];
     */
    
    /*
    [self.commandStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.commandStatusLabel.mas_trailing).with.offset(5);
        make.centerY.equalTo(self.commandStatusLabel);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
     */
    
    /** 右半侧 布局*/
    /*
    self.bleStatusImageView = [[UIImageView alloc] init];
    self.bleStatusImageView.image = [UIImage imageNamed:kBleStatusImageName_open];
    [self addSubview:self.bleStatusImageView];
    
    self.mwsSwitch = [[G100CustomSwitch alloc] init];
    self.mwsSwitch.delegate = self;
    [self addSubview:self.mwsSwitch];
    
    self.gprsStatusImageView = [[UIImageView alloc] init];
    self.gprsStatusImageView.image = [UIImage imageNamed:@"ic_rc_gps_signal5"];
    [self addSubview:self.gprsStatusImageView];
    
    self.aisleConnectedStatusLabel = [[UILabel alloc] init];
    self.aisleConnectedStatusLabel.font = kSmallFont;
    self.aisleConnectedStatusLabel.textColor = kGPRSColor;
    self.aisleConnectedStatusLabel.text = kAisleConnectedStatusGPSText;
    self.aisleConnectedStatusLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.aisleConnectedStatusLabel];
    
    [self.gprsStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@30);
        make.top.equalTo(@10);
        make.trailing.equalTo(@-12);
    }];
    [self.mwsSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.gprsStatusImageView);
        make.height.equalTo(@20);
        make.width.equalTo(@43);
        make.trailing.equalTo(self.gprsStatusImageView.mas_leading).with.offset(-6);
    }];
    [self.bleStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mwsSwitch.mas_leading).with.offset(-6);
        make.height.equalTo(@20);
        make.width.equalTo(@30);
        make.centerY.equalTo(self.gprsStatusImageView);
    }];
    [self.aisleConnectedStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.gprsStatusImageView.mas_trailing);
        make.centerY.equalTo(self.deviceConnectedStatusLabel);
    }];
     */
    
    self.securityStatusImageView = [[UIImageView alloc] init];
    self.securityStatusImageView.image = [UIImage imageNamed:kSecurityStatus_s];
    [self addSubview:self.securityStatusImageView];
    
    self.securityStatusLabel = [[UILabel alloc] init];
    self.securityStatusLabel.font = [UIFont systemFontOfSize:12];
    self.securityStatusLabel.textColor = [UIColor colorWithHexString:@"00B5B3"];
    self.securityStatusLabel.text = @"已设防";
    self.securityStatusLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.securityStatusLabel];
    
    [self.securityStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@20);
        make.centerY.equalTo(self.securityStatusLabel);
    }];
    
    [self.securityStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.securityStatusImageView.mas_trailing).with.offset(@0);
        make.trailing.equalTo(@-10);
        make.centerY.equalTo(self);
    }];
    
    self.commandStatusLabel.hidden = YES;
    self.commandStatusImageView.hidden = YES;
    
    self.securityStatusImageView.image = nil;
    self.securityStatusLabel.text = @"";
}

#pragma mark - 指令发送中... 动画
- (void)startAnimationWithTime:(NSTimeInterval)time {
    self.commandStatusLabel.hidden = NO;
    self.commandStatusImageView.hidden = NO;
    
    NSMutableArray * imgArrays = [NSMutableArray array];
    for (NSInteger i = 0; i <= 21; i++) {
        NSString * imgName = [NSString stringWithFormat:@"ic_animaion%@", @(i)];
        [imgArrays addObject:[UIImage imageNamed:imgName]];
    }
    
    self.commandStatusImageView.animationImages = imgArrays;
    self.commandStatusImageView.animationDuration = time;
    self.commandStatusImageView.animationRepeatCount = 0;
    [self.commandStatusImageView startAnimating];
}

- (void)stopAnimation {
    [self.commandStatusImageView stopAnimating];
    
    self.commandStatusLabel.hidden = YES;
    self.commandStatusImageView.hidden = YES;
}

#pragma mark - G100CustomSwitchDelegate
- (void)valueDidChanged:(G100CustomSwitch *)mwsSwitch status:(int)status {
    DLog(@"用户选择了状态%@", status == 0 ? @"蓝牙" : @"GPRS");
    [self setMwsSwitchStatus:status];
    
    if ([_delegate respondsToSelector:@selector(valueDidChanged:status:)]) {
        [_delegate valueDidChanged:self status:status];
    }
}

#pragma mark - Public Method

#pragma mark - Setter/Getter
- (void)setStatus:(int)status {
    _status = status;
    
    if (status == 0) {
        // 不存在任何设备
        self.bleStatusImageView.hidden = YES;
        self.gprsStatusImageView.hidden = YES;
        self.mwsSwitch.hidden = YES;
        self.deviceConnectedStatusLabel.hidden = YES;
        self.commandStatusImageView.hidden = YES;
        self.commandStatusLabel.hidden = YES;
        self.aisleConnectedStatusLabel.hidden = YES;
    }else if (status == 1) {
        // 蓝牙控制
        self.bleStatusImageView.hidden = YES;
        self.gprsStatusImageView.hidden = YES;
        self.mwsSwitch.hidden = YES;
        self.deviceConnectedStatusLabel.hidden = NO;
        self.commandStatusImageView.hidden = YES;
        self.commandStatusLabel.hidden = YES;
        self.aisleConnectedStatusLabel.hidden = NO;
        
        [self setMwsSwitchStatus:0];
    }else if (status == 2) {
        // GPRS控制
        self.bleStatusImageView.hidden = YES;
        self.gprsStatusImageView.hidden = NO;
        self.mwsSwitch.hidden = YES;
        self.deviceConnectedStatusLabel.hidden = NO;
        self.commandStatusImageView.hidden = YES;
        self.commandStatusLabel.hidden = YES;
        self.aisleConnectedStatusLabel.hidden = NO;
        
        [self setMwsSwitchStatus:1];
    }else if (status == 3) {
        // 同时存在
        self.bleStatusImageView.hidden = NO;
        self.gprsStatusImageView.hidden = NO;
        self.mwsSwitch.hidden = NO;
        self.deviceConnectedStatusLabel.hidden = NO;
        self.commandStatusImageView.hidden = YES;
        self.commandStatusLabel.hidden = YES;
        self.aisleConnectedStatusLabel.hidden = NO;
    }else {
        // 其他
        
    }
}

- (void)setMwsSwitchStatus:(int)mwsSwitchStatus {
    _mwsSwitchStatus = mwsSwitchStatus;
    [self.mwsSwitch setMws_status:mwsSwitchStatus];
    
    if (mwsSwitchStatus == 0) {
        self.aisleConnectedStatusLabel.textColor = kBLEColor;
        self.aisleConnectedStatusLabel.text = kAisleConnectedStatusBLEText;
        
        self.commandStatusLabel.textColor = kBLEColor;
    }else if (mwsSwitchStatus == 1) {
        self.aisleConnectedStatusLabel.textColor = kGPRSColor;
        self.aisleConnectedStatusLabel.text = kAisleConnectedStatusGPSText;
        
        self.commandStatusLabel.textColor = kGPRSColor;
    }
}

#pragma mark - Public Method
- (void)mws_sendCommand:(G100RTCommandModel *)command {
    if (_current_command != -1) {
        return;
    }
    _current_command = command.rt_command;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimation) object:nil];
    
    NSString *hint = @"正在发送指令...";
    
    if (command.rt_status == 1) {
        // 蓝牙
        switch (command.rt_command) {
            case 1:
                hint = @"正在设防...";
                break;
            case 2:
                hint = @"正在撤防...";
                break;
            case 3:
                hint = @"正在一键启动...";
                break;
            case 4:
                hint = @"正在寻车...";
                break;
            case 5:
                hint = @"正在开启坐桶锁...";
                break;
            case 6:
                hint = @"正在切换低速档...";
                break;
            case 7:
                hint = @"正在切换中速挡...";
                break;
            case 8:
                hint = @"正在切换高速挡...";
                break;
            default:
                hint = @"正在发送指令...";
                break;
        }
        
    }else if (command.rt_status == 2) {
        // 网络信号
        switch (command.rt_command) {
            case 1:
                hint = @"正在设防...";
                break;
            case 2:
                hint = @"正在撤防...";
                break;
            case 3:
            {
                if (command.rt_type == 1) {
                    hint = @"正在打开电门...";
                }else if (command.rt_type == 2) {
                    hint = @"正在关闭电门...";
                }
            }
                break;
            case 4:
                hint = @"正在寻车...";
                break;
            case 5:
                hint = @"正在开启座桶锁...";
                break;
            case 6:
                hint = @"正在开启中撑锁...";
                break;
            case 7:
                hint = @"正在开启龙头锁...";
                break;
            case 8:
                hint = @"正在一键启动...";
                break;
            case 9:
                hint = @"正在追车报警...";
                break;
            case 10:
                hint = @"正在切换低速挡...";
                break;
            default:
                hint = @"正在发送指令...";
                break;
        }
    }else {
        hint = @"正在发送指令...";
    }
    
    self.commandStatusLabel.text = hint;
    [self startAnimationWithTime:1.5f];
}
- (void)mws_completeCommand:(G100RTCommandModel *)command result:(int)result {
    NSString *hint = @"正在发送指令...";
    
    if (command.rt_status == 1) {
        // 蓝牙
        switch (command.rt_command) {
            case 1:
                hint = @"设防成功";
                break;
            case 2:
                hint = @"撤防成功";
                break;
            case 3:
                hint = @"一键启动成功";
                break;
            case 4:
                hint = @"寻车指令已发送";
                break;
            case 5:
                hint = @"座桶锁已开启";
                break;
            case 6:
                hint = @"切换低速挡指令已发送";
                break;
            case 7:
                hint = @"切换中速挡指令已发送";
                break;
            case 8:
                hint = @"切换高速挡指令已发送";
                break;
            default:
                hint = @"通用指令已发送";
                break;
        }
        
    }else if (command.rt_status == 2) {
        if (result == 0) {
            // 网络信号
            switch (command.rt_command) {
                case 1:
                    hint = @"设防失败";
                    break;
                case 2:
                    hint = @"撤防失败";
                    break;
                case 3:
                {
                    if (command.rt_type == 1) {
                        hint = @"开电门失败";
                    }else if (command.rt_type == 2) {
                        hint = @"关电门失败";
                    }
                }
                    break;
                case 4:
                    hint = @"寻车失败";
                    break;
                case 5:
                    hint = @"开启座桶锁失败";
                    break;
                case 6:
                    hint = @"开启中撑锁失败";
                    break;
                case 7:
                    hint = @"开启龙头锁失败";
                    break;
                case 8:
                    hint = @"一键启动失败";
                    break;
                case 9:
                    hint = @"追车报警失败";
                    break;
                case 10:
                    hint = @"切换低速挡失败";
                    break;
                default:
                    hint = @"指令发送失败";
                    break;
            }
        }else if (result == 1) {
            // 网络信号
            switch (command.rt_command) {
                case 1:
                    hint = @"设防成功";
                    break;
                case 2:
                    hint = @"撤防成功";
                    break;
                case 3:
                {
                    if (command.rt_type == 1) {
                        hint = @"开电门成功";
                    }else if (command.rt_type == 2) {
                        hint = @"关电门成功";
                    }
                }
                    break;
                case 4:
                    hint = @"寻车指令已发送";
                    break;
                case 5:
                    hint = @"开启座桶锁指令已发送";
                    break;
                case 6:
                    hint = @"开启中撑锁指令已发送";
                    break;
                case 7:
                    hint = @"开启龙头锁指令已发送";
                    break;
                case 8:
                    hint = @"一键启动成功";
                    break;
                case 9:
                    hint = @"追车报警指令已发送";
                    break;
                case 10:
                    hint = @"切换低速挡指令已发送";
                    break;
                default:
                    hint = @"指令已发送";
                    break;
            }
        }else if (result == 2) {
            switch (command.rt_command) {
                case 1:
                    hint = @"正在设防...";
                    break;
                case 2:
                    hint = @"正在撤防...";
                    break;
                case 3:
                {
                    if (command.rt_type == 1) {
                        hint = @"正在打开电门...";
                    }else if (command.rt_type == 2) {
                        hint = @"正在关闭电门...";
                    }
                }
                    break;
                case 4:
                    hint = @"正在寻车...";
                    break;
                case 5:
                    hint = @"正在开启座桶锁...";
                    break;
                case 6:
                    hint = @"正在开启中撑锁...";
                    break;
                case 7:
                    hint = @"正在开启龙头锁...";
                    break;
                case 8:
                    hint = @"正在一键启动...";
                    break;
                case 9:
                    hint = @"正在追车报警...";
                    break;
                case 10:
                    hint = @"正在切换低速挡...";
                    break;
                default:
                    hint = @"正在发送指令...";
                    break;
            }
        }
    }else {
        hint = @"指令已发送";
    }
    
    self.commandStatusLabel.text = hint;
    
    if (result == 0 || result == 1) {
        [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:3.0f];
    }
    
    _current_command = -1;
}

- (void)mws_setupGPRS_signalLevel:(int)level {
    if (level == 0) {
        self.gprsStatusImageView.image = [UIImage imageNamed:kGprsStatusImageName_close];
    }else {
        self.gprsStatusImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", kGprsStatusImageName_siginal, @(level)]];
    }
}

- (void)mws_setupBLE_signalLevel:(int)level {
    if (level == 0) {
        self.bleStatusImageView.image = [UIImage imageNamed:kBleStatusImageName_close];
    }else {
        self.bleStatusImageView.image = [UIImage imageNamed:kBleStatusImageName_open];
    }
}
- (void)mws_setupCardTitle:(NSString *)cardTitle {
    self.leftTitleLabel.text = cardTitle;
}
- (void)mws_setupCardDetail:(NSString *)cardDetail {
    self.deviceConnectedStatusLabel.text = cardDetail;
}
- (void)mws_setupSecurityStatus:(int)status {
    switch (status) {
        case -1:
        {
            self.securityStatusImageView.hidden = YES;
            self.securityStatusLabel.hidden = YES;
        }
        break;
        case 1:
        case 4:
        {
            self.securityStatusImageView.image = [UIImage imageNamed:kSecurityStatus_c];
            self.securityStatusLabel.text = @"撤防";
            self.securityStatusImageView.hidden = NO;
            self.securityStatusLabel.hidden = NO;
        }
            break;
        case 3:
        case 2:
        {
            self.securityStatusImageView.image = [UIImage imageNamed:kSecurityStatus_s];
            self.securityStatusLabel.text = @"设防";
            self.securityStatusImageView.hidden = NO;
            self.securityStatusLabel.hidden = NO;
        }
            break;
        case -2:
        {
            self.securityStatusImageView.image = nil;
            self.securityStatusLabel.text = @"设/撤防未知";
            self.securityStatusImageView.hidden = NO;
            self.securityStatusLabel.hidden = NO;
        }
            break;
        default:
        {
            
        }
            break;
    }
    
}

/** 2.2.1 版本 去掉下阴影效果
- (void)drawRect:(CGRect)rect {
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.shadowOpacity = 0.4;
}
 */

@end
