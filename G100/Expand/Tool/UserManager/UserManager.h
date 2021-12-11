//
//  UserManager.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100Api.h"
#import "G100InfoHelper.h"
#import "CDDDataHelper.h"

@interface UserManager : NSObject

/** 异地登陆 YES 表示被登陆  NO 表示正常*/
@property (nonatomic, assign) BOOL remoteLogin;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * password;
@property (nonatomic, copy) NSString * token;
@property (nonatomic, readonly, assign) BOOL isLogin;
@property (nonatomic, readonly, assign) BOOL isBind;

@property (nonatomic, copy) NSString * thirdUserid;
@property (nonatomic, copy) NSString * partneruseruid;
@property (nonatomic, assign) UserLoginType loginType;

@property (nonatomic, readonly, copy) NSString * appVersion;
@property (nonatomic, copy, readonly) NSString *webUa;
@property (nonatomic, copy, readonly) NSString *reqUa;
@property (nonatomic, copy, readonly) NSString *downloaderUa;
@property (nonatomic, copy, readonly) NSString *env;

@property (nonatomic, assign) BOOL appHasActived;

+(UserManager *)shareManager;

/**
 初始化UserAgent 标识
 */
-(void)setupUa;

/**
 调试更新UserAgent
 */
-(void)runTestUa;

/**
 检查token 是否需要刷新

 @return YES/NO
 */
-(BOOL)checkTokenNeedRefresh;

/**
 *  登录成功后保存帐号信息以及其他操作
 *
 *  @param username  用户名
 *  @param password  密码
 *  @param loginInfo 帐号信息
 */
-(void)loginWithUsername:(NSString *)username password:(NSString *)password userInfo:(NSDictionary *)loginInfo;

/**
 *  用于token过期时 自动登录
 *
 *  @param completeBlock 登录成功后的回调
 */
-(void)autoLoginWithComplete:(void(^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;

/**
 *  更新当前用户信息
 *
 *  @param userid        用户id
 *  @param completeBlock 更新后的回调
 */
-(void)updateUserInfoWithUserid:(NSString *)userid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
/**
 *  更新某用户 部分车辆信息
 *
 *  @param userid        用户id
 *  @param devid         车辆id
 *  @param completeBlock 更新后的回调
 */
-(void)updateDevInfoWithUserid:(NSString *)userid devid:(NSArray *)devid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock G100Deprecated("建议使用 Use -updateBikeInfoWithUserid:bikeid:complete:");

/**
 *  2.0 更新车辆列表
 *
 *  @param userid        用户id
 *  @param completeBlock 更新后的回调
 */
-(void)updateBikeListWithUserid:(NSString *)userid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
/**
 *  2.0 更新车辆列表
 *
 *  @param userid        用户id
 *  @param updateType    车辆列表更新类型
 *  @param completeBlock 更新后的回调
 */
-(void)updateBikeListWithUserid:(NSString *)userid updateType:(BikeListUpdateType)updateType complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
/**
 *  2.0 更新车辆信息
 *
 *  @param userid        用户id
 *  @param bikeid        车辆id
 *  @param completeBlock 更新后的回调
 */
-(void)updateBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
-(void)updateBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid updateType:(BikeInfoUpdateType)updateType complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
/**
 *  2.0 更新车辆的设备列表
 *
 *  @param userid        用户id
 *  @param bikeid        车辆id
 *  @param completeBlock 更新后的回调
 */
-(void)updateDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
/**
 *  2.0 更新设备信息
 *
 *  @param userid        用户id
 *  @param bikeid        车辆id
 *  @param devid         设备id
 *  @param completeBlock 更新后的回调
 */
-(void)updateDevInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;
/**
 *  更新用户设备列表
 *
 *  @param completeBlock 更新后的回调
 */
-(void)updateDevlistWithComplete:(void(^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock G100Deprecated("建议使用 Use -updateDevListWithUserid:bikeid:complete:");
/**
 *  向服务器注册推送
 *
 *  @param completeBlock 注册成功后的回调
 */
-(void)postPush:(void(^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock;

/**
 *  开始注册推送 登录成功后就调用
 */
-(void)startPostPush;
/**
 *  注册推送成功后 停止timer
 */
-(void)stopPostPush;

/**
 *  开始更新相关信息 如电量
 */
-(void)startUpdateInfo;
/**
 *  停止更新相关信息 如异常导致退出登录时调用
 */
-(void)stopUpdateInfo;

/** 退出登录 */
-(void)logoff;

/** 缓存数据 */
-(void)setAsynchronous:(id)object withKey:(NSString *)key;
/** 清除缓存 */
-(void)clearAsynchronousWithKey:(NSString *)key;
/** 取缓存 */
-(id)getAsynchronousWithKey:(NSString *)key;

@end
