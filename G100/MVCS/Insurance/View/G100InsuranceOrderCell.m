//
//  G100InsuranceOrderCell.m
//  G100
//
//  Created by yuhanle on 2017/8/7.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100InsuranceOrderCell.h"
#import "G100InsuranceOrder.h"

@interface G100InsuranceOrderCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *coverageLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation G100InsuranceOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.sureBtn.layer.masksToBounds = YES;
    self.sureBtn.layer.cornerRadius = 6.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.insuranceOrder.status == 6) {
        return;
    }
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.insuranceOrder.status == 6) {
        return;
    }
    
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setInsuranceOrder:(G100InsuranceOrder *)insuranceOrder {
    _insuranceOrder = insuranceOrder;
    
    // update
    self.nameLabel.text = insuranceOrder.product_name.length ? insuranceOrder.product_name : @"暂无保险名称";
    self.hintLabel.text = insuranceOrder.product_desc;
    
    if ([insuranceOrder.type isEqualToString:@"1"]) {
        if (insuranceOrder.insurance_amount) {
            self.coverageLabel.text = [NSString stringWithFormat:@"保额：%@元", @(insuranceOrder.insurance_amount)];
        }
        else {
            self.coverageLabel.text = @"保额：暂无";
        }
        
        if (insuranceOrder.bike_brand.length) {
            self.bikeBrandLabel.text = [NSString stringWithFormat:@"车辆品牌：%@", insuranceOrder.bike_brand];
        }
        else {
            self.bikeBrandLabel.text =@"车辆品牌：暂无";
        }
        
        if (insuranceOrder.vin.length) {
            self.vinLabel.text = [NSString stringWithFormat:@"车架号：%@", insuranceOrder.vin];
        }
        else {
            self.vinLabel.text = @"车架号：暂无";
        }
    }
    else {
        if (insuranceOrder.insurance_name.length) {
            self.coverageLabel.text = [NSString stringWithFormat:@"被保险人：%@", insuranceOrder.insurance_name];
        }
        else {
            self.coverageLabel.text = @"被保险人：暂无";
        }
        
        if (insuranceOrder.idcard.length) {
            self.bikeBrandLabel.text = [NSString stringWithFormat:@"身份证号：*%@", [insuranceOrder.idcard substringFromIndex:insuranceOrder.idcard.length - 4]];
        }
        else {
            self.bikeBrandLabel.text =@"身份证号：暂无";
        }
        
        if (insuranceOrder.phone_num.length) {
            self.vinLabel.text = [NSString stringWithFormat:@"手机号码：%@", insuranceOrder.phone_num];
        }
        else {
            self.vinLabel.text = @"手机号码：暂无";
        }
    }
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.1f", insuranceOrder.product_price];
    
    NSString *inDetail = @"待付款";
    NSString *inStatus = @"保单未生效";
    
    NSInteger mDay = insuranceOrder.insurance_endmin / (24*60);
    NSInteger mHour = ((insuranceOrder.insurance_endmin % (24*60)) / 60) + (((insuranceOrder.insurance_endmin % (24*60)) % 60) == 0 ? 0 : 1);
    
    NSMutableString *timeString = [[NSMutableString alloc] init];
    if (mDay) {
        [timeString appendFormat:@"%@天", @(mDay)];
    }
    
    if (mHour) {
        [timeString appendFormat:@"%@小时", @(mHour)];
    }
    
    self.detailLabel.textColor = [UIColor colorWithHexString:@"#FC7222"];
    self.statusLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
    
    if (insuranceOrder.status == 2) {
        // 审核中
        if (timeString.length) {
            inDetail = [NSString stringWithFormat:@"审核中 剩余%@", timeString];
        }
        else {
            inDetail = @"审核中";
        }
        inStatus = @"保单未生效";
        self.statusLabel.textColor = [UIColor colorWithHexString:@"#FC7222"];
    }
    else if (insuranceOrder.status == 9) {
        // 待领取
        if (timeString.length) {
            inDetail = [NSString stringWithFormat:@"待领取 剩余%@", timeString];
        }
        else {
            inDetail = @"待领取";
        }
        inStatus = @"保单未生效";
        self.statusLabel.textColor = [UIColor colorWithHexString:@"#FC7222"];
    }
    else if (insuranceOrder.status == 10) {
        // 待支付
        if (timeString.length) {
            inDetail = [NSString stringWithFormat:@"待支付 剩余%@", timeString];
        }
        else {
            inDetail = @"待支付";
        }
        inStatus = @"保单未生效";
        self.statusLabel.textColor = [UIColor colorWithHexString:@"#FC7222"];
    }
    else if (insuranceOrder.status == 6) {
        // 已作废
        inDetail = @"已作废";
        inStatus = @"";
        self.detailLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
        self.statusLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
    }
    else if (insuranceOrder.status == 7) {
        // 即将到期
        if (timeString.length) {
            inDetail = [NSString stringWithFormat:@"即将到期 剩余%@", timeString];
        }
        else {
            inDetail = @"即将到期";
        }
        inStatus = [NSString stringWithFormat:@"%@~%@", insuranceOrder.begin_date, insuranceOrder.end_date];
        self.statusLabel.textColor = [UIColor colorWithHexString:@"#FC7222"];
    }
    else if (insuranceOrder.status == 8) {
        // 已过期
        inDetail = @"已过期";
        inStatus = [NSString stringWithFormat:@"%@~%@", insuranceOrder.begin_date, insuranceOrder.end_date];
        self.detailLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
        self.statusLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
    }
    else if (insuranceOrder.status == 1) {
        // 保障中
        inDetail = @"保障中";
        inStatus = [NSString stringWithFormat:@"%@~%@", insuranceOrder.begin_date, insuranceOrder.end_date];
        
        // 即将到期
        if (mDay < 31) {
            if (timeString.length) {
                inDetail = [NSString stringWithFormat:@"即将到期 剩余%@", timeString];
            }
            else {
                inDetail = @"即将到期";
            }
            inStatus = [NSString stringWithFormat:@"%@~%@", insuranceOrder.begin_date, insuranceOrder.end_date];
            self.statusLabel.textColor = [UIColor colorWithHexString:@"#FC7222"];
        }
    }
    else {
        inStatus = [NSString stringWithFormat:@"%@~%@", insuranceOrder.begin_date, insuranceOrder.end_date];
    }
    
    self.statusLabel.text = inStatus;
    self.detailLabel.text = inDetail;
    
    if (insuranceOrder.status == 9 || insuranceOrder.status == 10) {
        // 待领取
        self.sureBtn.layer.masksToBounds = YES;
        self.sureBtn.layer.cornerRadius = 6.0f;
        
        self.sureBtn.layer.borderWidth = 0.0;
        self.sureBtn.backgroundColor = [UIColor colorWithHexString:@"#FC7222"];
        [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        self.sureBtn.layer.masksToBounds = YES;
        self.sureBtn.layer.cornerRadius = 6.0f;
        
        self.sureBtn.layer.borderWidth = 1.0;
        self.sureBtn.layer.borderUIColor = [UIColor colorWithHexString:@"#FC7222"];
        self.sureBtn.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        [self.sureBtn setTitleColor:[UIColor colorWithHexString:@"#FC7222"] forState:UIControlStateNormal];
    }
    
    self.sureBtn.hidden = !insuranceOrder.action_button.length;
    
    [self.sureBtn setTitle:insuranceOrder.action_button forState:UIControlStateNormal];
}

#pragma mark - Actions
- (IBAction)btnAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(insuranceOrderCell:insuranceOrder:)]) {
        [self.delegate insuranceOrderCell:self insuranceOrder:self.insuranceOrder];
    }
}

@end
