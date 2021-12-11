//
//  PayChannelCell.m
//  ebike
//
//  Created by yuhanle on 2017/11/29.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "PayChannelCell.h"

@implementation PayChannelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChannel:(PayChannel *)channel {
    _channel = channel;
    
    self.leftImageView.image = [UIImage imageNamed:channel.channelImg];
    self.titleLabel.text = channel.channelName;
    
    if (channel.selected) {
        self.statusImageView.image = [UIImage imageNamed:@"ic_service_commplete"];
    }else {
        self.statusImageView.image = [UIImage imageNamed:@"icon_channel_normal"];
    }
    if (channel.isUnion) {
        self.iconImageView.hidden = NO;
    }else{
        self.iconImageView.hidden = YES;
    }
}

@end

@implementation PayChannel

- (void)setChannel:(PayChannelType)channel {
    _channel = channel;
    
    switch (channel) {
        case PayChannelWX:
        {
            _channelName = @"微信支付";
            _channelID = @"wx";
            _channelImg = @"icon_channel_wx";
            _isUnion = NO;
        }
            break;
        case PayChannelAlipay:
        {
            _channelName = @"支付宝支付";
            _channelID = @"alipay";
            _channelImg = @"icon_channel_alipay";
            _isUnion = NO;
        }
            break;
        case PayChannelUnion:
        {
            _channelName = @"银联支付";
            _channelID = @"upacp";
            _channelImg = @"icon_channel_union";
            _isUnion = YES;
        }
            break;
        case PayChannelUnionYun:
        {
            _channelName = @"云闪付";
            _channelID = @"upacp";
            _channelImg = @"yunPay";
            _isUnion = YES;
        }
            break;
        case PayChannelApple:
        {
            _channelName = @"Apple Pay";
            _channelID = @"applepay_upacp";
            _channelImg = @"applepay";
            _isUnion = YES;
        }
            break;
        default:
        {
            _channelName = @"微信支付";
            _channelID = @"wx";
            _channelImg = @"icon_channel_wx";
            _isUnion = NO;
        }
            break;
    }
}

@end
