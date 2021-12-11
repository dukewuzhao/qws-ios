//
//  PayServiceCell.m
//  G100
//
//  Created by Tilink on 15/3/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "PayServiceCell.h"
#import "G100GoodDomain.h"
#import "G100OrderDomain.h"

@implementation PayServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [super awakeFromNib];
    
    [self.cancelOrderBtn.layer setMasksToBounds:YES];
    [self.cancelOrderBtn.layer setCornerRadius:5.0];
    [self.cancelOrderBtn.layer setBorderWidth:1.0f];
    [self.cancelOrderBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.payOrderBtn.layer setMasksToBounds:YES];
    [self.payOrderBtn.layer setCornerRadius:5.0f];
    [self.payOrderBtn.layer setBorderWidth:1.0f];
    [self.payOrderBtn.layer setBorderColor:[UIColor colorWithRed:66/255.0 green:157/255.0 blue:69/255.0 alpha:1.0f].CGColor];
    self.seperateLineLabel.v_height = (0.5f / [UIScreen mainScreen].scale) / 2;;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)showOrderUIWithModel:(G100OrderDomain *)model {
    self.nameLabel.text = model.product_name;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%.1f", model.price];
    self.serLabel.text = [NSString stringWithFormat:@"期限：%ld个月", (long)model.service_months];
    NSInteger status = [model.status integerValue];
    
    if (model.order_type == 1) {
        // 所属设备
        self.masterLabel.hidden = NO;
        NSString *extraText = [NSString stringWithFormat:@"车辆：%@\n设备：%@", model.bike_name, model.device_name];
        self.masterLabel.text = extraText;
    }else if (model.order_type == 2) {
        // 保险跟人
        self.masterLabel.hidden = NO;
        self.masterLabel.text = [NSString stringWithFormat:@"所属用户：%@", [[CurrentUser sharedInfo] nickname]];
        
        // 判断是否可以支付保险
        BOOL insurance_apply = [UserAccount sharedInfo].appfunction.insurance_apply.enable && IsLogin();
        self.payOrderBtn.enabled = insurance_apply;
    }
    
    self.cancelOrderBtn.hidden = YES;
    self.payOrderBtn.hidden = YES;
    
    switch (status) {
        case 0:
        {
            self.statusLabel.text = @"待支付";
            self.cancelOrderBtn.hidden = NO;
            self.payOrderBtn.hidden = NO;
        }
            break;
        case 1:
        {
            // 已支付
            self.statusLabel.text = @"订单待确认";
        }
            break;
        case 2:
        {
            self.statusLabel.text = @"待支付";
            self.cancelOrderBtn.hidden = NO;
            self.payOrderBtn.hidden = NO;
        }
            break;
        case 3:
        {
            self.statusLabel.text = @"已关闭";
        }
            break;
        case 4:
        {
            self.statusLabel.text = @"已支付";
        }
            break;
        case 5:
        {
            // 已支付
            self.statusLabel.text = @"已支付";
        }
            break;
        case 6:
        {
            // 取消订单
            self.statusLabel.text = @"已关闭";
        }
            break;
        case 7:
        {
            // 待支付
            self.statusLabel.text = @"待支付";
            self.cancelOrderBtn.hidden = NO;
            self.payOrderBtn.hidden = NO;
        }
            break;
        case 8:{
            // 取消订单
            self.statusLabel.text = @"保单待审核";
        }
            break;
        default:
            break;
    }
}

- (IBAction)cancelOrder:(id)sender {
    [self.delegate handleCancelOrderWithIndexPath:self.indexPath];
}

- (IBAction)payOrder:(id)sender {
    [self.delegate handlePayOrderWithIndexPath:self.indexPath];
}

@end
