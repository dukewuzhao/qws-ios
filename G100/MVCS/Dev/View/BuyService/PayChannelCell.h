//
//  PayChannelCell.h
//  ebike
//
//  Created by yuhanle on 2017/11/29.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PayChannel;
@interface PayChannelCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) PayChannel *channel;

@end

typedef enum : NSUInteger {
    PayChannelWX,
    PayChannelUnion,
    PayChannelAlipay,
    PayChannelApple,
    PayChannelUnionYun
} PayChannelType;

@interface PayChannel: NSObject

@property (nonatomic, assign) PayChannelType channel;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *channelImg;
@property (assign,nonatomic) BOOL isUnion;
@property (nonatomic, assign) BOOL selected;

@end
