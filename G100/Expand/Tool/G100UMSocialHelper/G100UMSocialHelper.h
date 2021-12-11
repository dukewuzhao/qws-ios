//
//  G100UMShareHelper.h
//  G100
//
//  Created by yuhanle on 16/1/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>
#import "G100ShareDomain.h"

@interface UMShareModel : G100BaseDomain

@property (nonatomic, assign) NSInteger shareto;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, copy) NSString *shareTopic;
@property (nonatomic, copy) NSString *shareAtUser;
@property (nonatomic, copy) NSString *sharePicUrl;
@property (nonatomic, copy) NSString *shareJumpUrl;

/**
 *  分享的图片 data 或者 image
 */
@property (nonatomic, strong) id shareImage;

@end

@interface G100UMSocialHelper : NSObject

@property (assign, nonatomic) NSInteger eventid; //!< 分享事件的id

/**
 *  实例化第三方分享平台管理实例
 *
 *  @return 实例
 */
+ (instancetype)shareInstance;

/**
 *  平台配置
 */
+ (void)socialConfiguration;

/**
 *  分享结束后的统一处理
 *
 *  @param response 分享结束后友盟的回应
 *  @param eventid  分享的事件id
 */
+ (void)didFinishGetUMSocialDataWithResponse:(UMSocialShareResponse *)response eventid:(NSInteger)eventid;

/**
 *  分享回调的统一处理入口
 *
 *  @param url 分享回调的url消息
 *
 *  @return 处理结果
 */
- (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark - 分享
/**
 *  快速创建分享弹窗 仅支持全平台统一内容
 *
 *  @param domain 分享的内容信息
 */
- (void)showShareWithData:(G100ShareDomain *)domain;
/**
 *  从服务器下载分享对应支持的平台和内容
 *
 *  @param shareid 分享id
 *  @param complete 接口回调
 */
- (void)loadShareWithShareid:(NSInteger)shareid complete:(void (^)(NSDictionary *dict, BOOL isSuccess))complete;
/**
 *  从服务器下载分享对应支持的平台和内容
 *  部分分享接口中可能存在需要从外部传 shareUrl的情况
 *
 *  @param shareid  分享id
 *  @param shareUrl 分享链接
 *  @param complete 接口回调
 */
- (void)loadShareWithShareid:(NSInteger)shareid shareUrl:(NSString *)shareUrl complete:(void (^)(NSDictionary *dict, BOOL isSuccess))complete;
/**
 *  从服务器下载分享对应支持的平台和内容
 *  部分分享接口中可能存在需要从外部传 shareUrl和sharePicUrl的情况
 *
 *  @param shareid      分享id
 *  @param shareUrl     分享链接
 *  @param sharePic     分享图片
 *  @param complete     接口回调
 */
- (void)loadShareWithShareid:(NSInteger)shareid shareUrl:(NSString *)shareUrl sharePic:(id)sharePic complete:(void (^)(NSDictionary *dict, BOOL isSuccess))complete;
/**
 *  快速创建分享弹窗 根据shareid 创建分享
 *
 *  @param shareid 分享id
 */
- (void)showShareWithShareid:(NSInteger)shareid;
/**
 *  快速创建分享弹窗 根据shareid 创建分享
 *
 *  @param shareid        分享id
 *  @param viewController 分享所在的VC
 *  @param complete       接口回调
 */
- (void)showShareWithShareid:(NSInteger)shareid onViewController:(UIViewController *)onViewController complete:(void (^)(NSInteger shareto, BOOL success))complete;
/**
 *  快速创建分享弹窗 根据shareid 创建分享
 *
 *  @param shareid        分享id
 *  @param viewController 分享所在的VC
 *  @param selected       选中按钮回调
 *  @param complete       接口回调
 */
- (void)showShareWithShareid:(NSInteger)shareid onViewController:(UIViewController *)onViewController selected:(void (^)(NSInteger shareto))selected complete:(void (^)(NSInteger shareto, BOOL success))complete;
/**
 *  通过JSON字符串创建分享
 *
 *  @param shareJsonStr     JSON分享字符串
 *  @param onViewController 分享所在的VC
 *  @param selected         选中按钮回调
 *  @param complete         接口回调
 */
- (void)showShareWithShareJSONStr:(NSString *)shareJSONStr onViewController:(UIViewController *)onViewController selected:(void (^)(NSInteger shareto))selected complete:(void (^)(NSInteger shareto, BOOL success))complete;

#pragma mark - 三方授权


@end
