//
//  G100ShareModel.m
//  G100ActionSheet
//
//  Created by yuhanle on 15/10/19.
//  Copyright © 2015年 yuhanle. All rights reserved.
//

#import "G100ShareModel.h"
#import "G100UMSocialConfig.h"
@implementation G100ShareModel

+ (instancetype)shareModelWithSnsPlatform:(NSString *)snsPlatformName handler:(G100ShareHandler)handler {
    G100ShareModel * shareModel = [[G100ShareModel alloc] init];
    shareModel.enable = YES; // 默认YES
    shareModel.platformName = snsPlatformName;
    
    if ([snsPlatformName isEqualToString:G100UMShareToWechatSession]) {
        shareModel.displayName = @"发送给朋友";
        shareModel.imgName = @"ShareWeChat";
    }else if ([snsPlatformName isEqualToString:G100UMShareToWechatTimeline]) {
        shareModel.displayName = @"分享到朋友圈";
        shareModel.imgName = @"ShareFriends";
    }else if ([snsPlatformName isEqualToString:G100UMShareToQQ]) {
        shareModel.displayName = @"分享到手机QQ";
        shareModel.imgName = @"ShareQQ";
    }else if ([snsPlatformName isEqualToString:G100UMShareToQzone]) {
        shareModel.displayName = @"分享到QQ空间";
        shareModel.imgName = @"ShareQQZone";
    }else if ([snsPlatformName isEqualToString:G100UMShareToSina]) {
        shareModel.displayName = @"分享到新浪";
        shareModel.imgName = @"ShareSina";
    }
    
    shareModel.handler = handler;
    
    return shareModel;
}

@end
