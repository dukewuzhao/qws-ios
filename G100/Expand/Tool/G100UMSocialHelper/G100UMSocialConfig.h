//
//  G100UMSocialConfig.h
//  G100
//
//  Created by yuhanle on 2016/11/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>

/**
 新浪微博
 */
extern NSString *const G100UMShareToSina;

/**
 腾讯微博
 */
extern NSString *const G100UMShareToTencent;

/**
 人人网
 */
extern NSString *const G100UMShareToRenren;

/**
 豆瓣
 */
extern NSString *const G100UMShareToDouban;

/**
 QQ空间
 */
extern NSString *const G100UMShareToQzone;

/**
 邮箱
 */
extern NSString *const G100UMShareToEmail;

/**
 短信
 */
extern NSString *const G100UMShareToSms;

/**
 微信好友
 */
extern NSString *const G100UMShareToWechatSession;

/**
 微信朋友圈
 */
extern NSString *const G100UMShareToWechatTimeline;

/**
 微信收藏
 */
extern NSString *const G100UMShareToWechatFavorite;

/**
 支付宝好友
 */
extern NSString *const G100UMShareToAlipaySession;

/**
 手机QQ
 */
extern NSString *const G100UMShareToQQ;

/**
 Facebook
 */
extern NSString *const G100UMShareToFacebook;

/**
 Twitter
 */
extern NSString *const G100UMShareToTwitter;


/**
 易信好友
 */
extern NSString *const G100UMShareToYXSession;

/**
 易信朋友圈
 */
extern NSString *const G100UMShareToYXTimeline;

/**
 来往好友
 */
extern NSString *const G100UMShareToLWSession;

/**
 来往朋友圈
 */
extern NSString *const G100UMShareToLWTimeline;

/**
 分享到Instragram
 */
extern NSString *const G100UMShareToInstagram;

/**
 分享到Whatsapp
 */
extern NSString *const G100UMShareToWhatsapp;

/**
 分享到Line
 */
extern NSString *const G100UMShareToLine;

/**
 分享到Tumblr
 */
extern NSString *const G100UMShareToTumblr;

/**
 分享到Pinterest
 */
extern NSString *const G100UMShareToPinterest;

/**
 分享到KakaoTalk
 */
extern NSString *const G100UMShareToKakaoTalk;

/**
 分享到Flickr
 */
extern NSString *const G100UMShareToFlickr;

typedef enum : NSUInteger {
    G100ThirdPlatformType_UnKnown            = -2,
    //预定义的平台
    G100ThirdPlatformType_Predefine_Begin    = -1,
    G100ThirdPlatformType_Sina               = 0, //新浪
    G100ThirdPlatformType_WechatSession      = 1, //微信聊天
    G100ThirdPlatformType_WechatTimeLine     = 2,//微信朋友圈
    G100ThirdPlatformType_WechatFavorite     = 3,//微信收藏
    G100ThirdPlatformType_QQ                 = 4,//QQ聊天页面
    G100ThirdPlatformType_Qzone              = 5,//qq空间
    G100ThirdPlatformType_TencentWb          = 6,//腾讯微博
    G100ThirdPlatformType_AlipaySession      = 7,//支付宝聊天页面
    G100ThirdPlatformType_YixinSession       = 8,//易信聊天页面
    G100ThirdPlatformType_YixinTimeLine      = 9,//易信朋友圈
    G100ThirdPlatformType_YixinFavorite      = 10,//易信收藏
    G100ThirdPlatformType_LaiWangSession     = 11,//点点虫（原来往）聊天页面
    G100ThirdPlatformType_LaiWangTimeLine    = 12,//点点虫动态
    G100ThirdPlatformType_Sms                = 13,//短信
    G100ThirdPlatformType_Email              = 14,//邮件
    G100ThirdPlatformType_Renren             = 15,//人人
    G100ThirdPlatformType_Facebook           = 16,//Facebook
    G100ThirdPlatformType_Twitter            = 17,//Twitter
    G100ThirdPlatformType_Douban             = 18,//豆瓣
    G100ThirdPlatformType_KakaoTalk          = 19,//KakaoTalk（暂未支持）
    G100ThirdPlatformType_Pinterest          = 20,//Pinterest（暂未支持）
    G100ThirdPlatformType_Line               = 21,//Line
    
    G100ThirdPlatformType_Linkedin           = 22,//领英
    
    G100ThirdPlatformType_Flickr             = 23,//Flickr
    
    G100ThirdPlatformType_Tumblr             = 24,//Tumblr（暂未支持）
    G100ThirdPlatformType_Instagram          = 25,//Instagram
    G100ThirdPlatformType_Whatsapp           = 26,//Whatsapp
    G100ThirdPlatformType_Predefine_end      = 999,
    
    //用户自定义的平台
    G100ThirdPlatformType_UserDefine_Begin = 1000,
    G100ThirdPlatformType_UserDefine_End = 2000,
} G100ThirdPlatformType;

@interface G100UMSocialConfig : NSObject

@end
