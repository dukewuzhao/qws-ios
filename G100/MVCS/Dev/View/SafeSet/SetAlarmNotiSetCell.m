//
//  SetAlarmNotiSetCell.m
//  G100
//
//  Created by yuhanle on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "SetAlarmNotiSetCell.h"

@interface SetAlarmNotiSetCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewConstraintH;
@property (weak, nonatomic) IBOutlet UIButton *serviceAgreeBtn;

@property (nonatomic, assign) BOOL openStatus;//!< 记录开关的初始状态

@end

@implementation SetAlarmNotiSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bottomDetailLabel.numberOfLines = 0;
    self.topTitleLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

+ (instancetype)alarmNotiSetCellWithType:(NSInteger)type {
    if (type == 1) {
        return [[[NSBundle mainBundle] loadNibNamed:@"SetAlarmNotiSetCell" owner:self options:nil] firstObject];
    }else {
        return [[[NSBundle mainBundle] loadNibNamed:@"SetAlarmNotiSetCell" owner:self options:nil] lastObject];
    }
}

- (IBAction)testButtonEvent:(UIButton *)sender {
    if (_testButtonEventBlock) {
        self.testButtonEventBlock(sender);
    }
}

- (IBAction)alarmSwitchChanged:(UISwitch *)sender {
    if (sender.on == self.openStatus) {
        return;
    }
    
    [sender setOn:!sender.on animated:YES];
    
    if (_testAlarmSwitchChangedBlock) {
        self.testAlarmSwitchChangedBlock(sender);
    }
}

- (void)showUIWithDict:(NSDictionary *)dict {
    self.topTitleLabel.text = dict[@"topTitle"];
    self.bottomDetailLabel.text = dict[@"bottomDetail"];
    self.lastDescriptionLabel.text = dict[@"lastDescription"];
    
    self.openStatus = [dict[@"switchon"] boolValue];
    self.alarmSwitch.on = [dict[@"switchon"] boolValue];
    self.leftImageView.image = [UIImage imageNamed:dict[@"leftImage"]];
    
    CGSize bottomLabelSize = [dict[@"bottomDetail"] calculateSize:CGSizeMake(WIDTH - 134, 999)
                                                             font:[UIFont systemFontOfSize:14]];
    if (bottomLabelSize.height > 17) {
        // 开启的话 需要显示服务协议入口
        self.backViewConstraintH.constant = self.alarmSwitch.on ? 90 : 54 + bottomLabelSize.height - 17;
    }
}

- (IBAction)serviceAgreeBtnClick:(UIButton *)sender {
    if (_serviceAgreementClickBlock) {
        self.serviceAgreementClickBlock();
    }
}

+ (CGFloat)heightForDict:(NSDictionary *)dict {
    CGFloat height = 54;
    switch ([dict[@"type"] integerValue]) {
        case 1:
            height = 54;
            break;
        case 2:
        case 3:
        {
            if ([dict[@"switchon"] boolValue]) {
                NSString *result = dict[@"lastDescription"];
                CGSize size = [result calculateSize:CGSizeMake(WIDTH - 125, 999)
                                               font:[UIFont systemFontOfSize:14]];
                height = 140 - 50 + (size.height > 20 ? size.height : 20);
            }else {
                height = 54;
            }
        }
            break;
        default:
            height = 54;
            break;
    }
    
    CGSize bottomLabelSize = [dict[@"bottomDetail"] calculateSize:CGSizeMake(WIDTH - 134, 999)
                                                             font:[UIFont systemFontOfSize:14]];
    if (bottomLabelSize.height > 17) {
        return height + bottomLabelSize.height - 17;
    }
    
    return height;
}

@end
