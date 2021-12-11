//
//  G100LinfoHelper.h
//  G100
//
//  Created by Tilink on 15/10/14.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHKeychain.h"

#import "G100AccountDomain.h"
#import "G100UserDomain.h"
#import "G100DeviceDomainExpand.h"
#import "G100TestResultDomain.h"
#import "G100EventDomain.h"

#import "G100BikeDomain.h"
#import "G100DeviceDomain.h"

extern NSString * const kGXFirstLogin;
extern NSString * const kGXUsername;
extern NSString * const kGXPassword;
extern NSString * const kGXToken;

extern NSString * const kGXUserLoginType;
extern NSString * const kGXThirdLoginUserid;
extern NSString * const kGXThirdPartnerUseruid;

extern NSString * const kGXBUserid;
extern NSString * const kGXBChannelid;
extern NSString * const kGXAccountInfo;
extern NSString * const kGXUserInfo;
extern NSString * const kGXCurrentDevInfo;
extern NSString * const kGXDevlist;

extern NSString * const kGXScoreChanged;
extern NSString * const kGXDevSecset;
extern NSString * const kGXDevTestResult;
extern NSString * const kGXDevPromptTime;
extern NSString * const kGXWeatherReportResult;
extern NSString * const kGXCurrentEvent;
extern NSString * const kGXNewOfflineMsg;
extern NSString * const kGXMapRefreshState;

typedef enum : NSUInteger {
    UserLoginTypePhoneNum = 1,
    UserLoginTypeWeixin,
    UserLoginTypeQQ,
    UserLoginTypeSina
} UserLoginType;

typedef enum : NSUInteger {
    UserTokenStatus_Online = 1,     // token有效
    UserTokenStatus_Invalid,        // token无效
    UserTokenStatus_Occupy,         // token被占用 -> = 无效
    UserTokenStatus_Offline,        // 无token
} UserTokenStatus;

typedef enum : NSUInteger {
    OfflineMsgReadStatusRead = -1,  // 已读
    OfflineMsgReadStatusAll = 0,    // 全读
    OfflineMsgReadStatusUnread = 1  // 未读
} OfflineMsgReadStatus;

/**
 *  2.0 版本采用 CoreData 数据库存储 支持多用户数据管理
 */
@interface G100InfoHelper : NSObject

/** 用户登录的用户名 注意不是昵称 而是登录名*/
@property (nonatomic, copy) NSString * username;
/** 用户登录的密码 - md5加密 */
@property (nonatomic, copy) NSString * password;
/** 用户请求token */
@property (nonatomic, copy) NSString * token;
/** 当前app的版本号 */
@property (nonatomic, copy) NSString * appVersion;
/** 记录的app版本号 */
@property (nonatomic, copy) NSString * oldAppVersion;

/** 注册推送的userid 也是用户id*/
@property (nonatomic, copy) NSString * buserid;
/** 注册推送的channelid */
@property (nonatomic, copy) NSString * bchannelid;

/** 用户是否刚登陆成功 */
@property (nonatomic, assign) BOOL isFirstLogin;
/** 用户的登录状态 */
@property (nonatomic, readonly, assign) BOOL isLogin;
/** 用户的绑定状态 */
@property (nonatomic, readonly, assign) BOOL isBind;
/** 用户是否首次安装应用 */
@property (nonatomic, assign) BOOL isFirstInstall;

/** 三方登录的userid */
@property (nonatomic, copy) NSString * thirdUserid;
/** 三方登录的形式 wx  qq  sina */
@property (nonatomic, copy) NSString * thirdPartnerUseruid;
/** 当前登录方式 */
@property (nonatomic, assign) UserLoginType loginType;
/** 当前token状态 */
@property (nonatomic, assign) UserTokenStatus tokenStatus;
/** 记录本次启动弹出消息状态*/
@property (nonatomic, strong) NSMutableDictionary *statusMap;

/**
 *  本地数据 统一单例
 *
 *  @return 单例对象
 */
+(instancetype)shareInstance;

#pragma mark - 用户相关
/**
 *  判断是否首次安装，或者升级版本后第一次打开应用
 *
 *  @return YES / NO
 */
-(BOOL)isFirstOpenFromNewAppVersion;

/** 用户信息 */
@property (nonatomic, strong) NSDictionary * currentAccountInfo;
@property (nonatomic, strong) NSDictionary * currentUserInfo;

/** 用户信息的存取 含帐号-用户等都是字典形式*/
/**
 *  2.0 登录成功后 更新本地存储的当前帐号信息
 *
 *  @param devid 用户id
 *  @param dict  帐号详情
 *
 *  @return 保存结果
 */
-(BOOL)updateMyAccountInfoWithUserid:(NSString *)userid accountInfo:(NSDictionary *)dict;
/**
 *  2.0 从本地取出帐号信息
 *
 *  @param userid 用户id
 *
 *  @return 对应帐号详情
 */
-(G100AccountDomain *)findMyAccountInfoWithUserid:(NSString *)userid;
/**
 *  2.0 登录成功后 更新本地存储的当前用户信息
 *
 *  @param userid 用户id
 *  @param dict   帐号详情
 *
 *  @return 保存结果
 */
-(BOOL)updateMyUserInfoWithUserid:(NSString *)userid userInfo:(NSDictionary *)dict;
/**
 *  2.0 从本地取出帐号信息
 *
 *  @param userid 用户id
 *
 *  @return 对应用户详情
 */
-(G100UserDomain *)findMyUserInfoWithUserid:(NSString *)userid;

/**
 *  2.0 地图刷新状态
 *
 *  @param userid 用户id
 *  @param state  状态 0：2G/3G/4G下不刷新 2：1分钟  3：5分钟  4：10分钟
 *
 *  @return 保存结果
 */
-(BOOL)updateMapRefreshStateWithUserid:(NSString *)userid state:(NSInteger)state;

/**
 *  2.0 获取地图刷新状态
 *
 *  @param userid 用户id
 *
 *  @return 状态 0：2G/3G/4G下不刷新 2：1分钟  3：5分钟  4：10分钟
 */
-(NSInteger)findMapRefreshStateWithUserid:(NSString *)userid;

#pragma mark - 2.0 车辆相关
/**
 *  2.0 更新本地存储的用户车辆列表
 *
 *  @param userid   用户id
 *  @param bikeList 车辆列表
 *
 *  @return YES/NO
 */
-(BOOL)updateMyBikeListWithUserid:(NSString *)userid bikelist:(NSArray *)bikeList;
/**
 *  2.0 更新本地存储的用户车辆详情
 *
 *  @param userid   用户id
 *  @param bikeid   车辆id
 *  @param bikeInfo 车辆详情
 *
 *  @return YES/NO
 */
-(BOOL)updateMyBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeInfo:(NSDictionary *)bikeInfo;
/**
 *  2.0 更新本地存储的某用户某车辆的设备列表
 *
 *  @param userid  用户id
 *  @param bikeid  车辆id
 *  @param devList 设备列表
 *
 *  @return YES/NO
 */
-(BOOL)updateMyDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devlist:(NSArray *)devList;
/**
 *  2.0 更新本地存储的某用户某车辆某设备的设备信息
 *
 *  @param userid  用户id
 *  @param bikeid  车辆id
 *  @param devid   设备id
 *  @param devInfo 设备详情
 *
 *  @return YES/NO
 */
-(BOOL)updateMyDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid devInfo:(NSDictionary *)devInfo;

/**
 *  2.0 查找本地某用户的正常车辆列表 （不包括激活中和审核中状态）
 *
 *  @param userid 用户id
 *
 *  @return 车辆列表
 */
-(NSArray *)findMyBikeListWithUserid:(NSString *)userid;
/**
 *  2.0 查找本地某用户的所有车辆列表 （包括激活中和审核中状态）
 *
 *  @param userid 用户id
 *
 *  @return 车辆列表
 */
-(NSArray *)findMyAllBikeListWithUserid:(NSString *)userid;
/**
 *  2.0 查找本地某用户的某车辆详情
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 车辆详情
 */
-(G100BikeDomain *)findMyBikeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 *  2.0 更新车辆检测结果
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *  @param result 检测结果
 *
 *  @return YES/NO
 */
-(BOOL)updateMyBikeTestResultWithuserid:(NSString *)userid bikeid:(NSString *)bikeid result:(NSDictionary *)result;
/**
 *  2.0 查找某辆车的检测结果
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 检查结果
 */
-(G100TestResultDomain *)findMyBikeTestResultWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;

/**
 *  2.0 更新车辆最新存车记录
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *  @param lastFindRecord 最新存车记录
 *
 *  @return YES/NO
 */
-(BOOL)updateMyBikeLastFindRecordWithUserid:(NSString *)userid bikeid:(NSString *)bikeid lastFindRecord:(NSDictionary *)lastFindRecord;
/**
 *  2.0 查找某辆车的最新存车记录
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 检查结果
 */
-(NSDictionary *)findMyBikeLastFindRecordWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 2.0 设置某车辆某设备的位置显示隐藏

 @param userid 用户id
 @param bikeid 车辆id
 @param deviceid 设备id
 @param locationDisplay 是否显示隐藏
 @return 设置结果
 */
-(BOOL)updateMyDevLocationDisplayWithuserid:(NSString *)userid bikeid:(NSString *)bikeid deviceid:(NSString *)deviceid locationDisplay:(BOOL)locationDisplay;

/**
 *  2.0 查找某车辆的正常设备列表 GPS 设备
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 设备列表
 */
-(NSArray *)findMyDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;

/**
 *  2.0 查找某车辆的正常设备列表 Battery 设备
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 设备列表
 */
-(NSArray *)findMyBatteryListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;

/**
 *  2.0 查找某车辆的所有设备列表 包含GPS 设备和 Battery 设备
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 设备列表
 */
-(NSArray *)findMyAllDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;

/**
 *  2.0 查找某设备的设备详情
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *  @param devid  设备id
 *
 *  @return 设备详情
 */
-(G100DeviceDomain *)findMyDevWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

/**
 *  2.0 更新某设备的最长响铃时间
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *  @param devid  设备id
 *  @param time   响铃时长
 *
 *  @return YES/NO
 */
-(BOOL)updateMyDevPromptTimeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid propmtTime:(NSInteger)time;
/**
 *  2.0 查找某设备本地设置的最长响铃时间
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *  @param devid  设备id
 *
 *  @return 最长响铃时间 单位：分钟
 */
-(NSInteger)findMyDevPromptTimeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;
/**
 *  2.0 更新车辆的特征信息
 *
 *  @param userid  用户id
 *  @param bikeid  车辆id
 *  @param feature 特征信息
 *
 *  @return YES/NO
 */
-(BOOL)updateMyBikeFeatureWithUserid:(NSString *)userid bikeid:(NSString *)bikeid feature:(NSDictionary *)feature;
/**
 *  2.0 查找车辆的特征信息
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 特征信息
 */
-(G100BikeFeatureDomain *)findMyBikeFeatureWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 *  更新当前设备信息
 *
 *  @param userid  用户id
 *  @param devInfo 车辆信息
 *
 *  @return 保存结果
 */
-(BOOL)updateMyCurrentDevInfoWithUserid:(NSString *)userid devInfo:(NSDictionary *)devInfo G100Deprecated("2.0 接口废弃");
/** 用户车辆信息 */
/**
 *  更新用户存储在本地的车辆信息
 *
 *  @param userid  用户id
 *  @param devlist 车辆信息
 *  @param secset  车辆设置
 *
 *  @return 保存结果
 */
-(BOOL)updateMyDevInfoWithUserid:(NSString *)userid devlist:(NSArray *)devlist secset:(NSArray *)secset G100Deprecated("建议使用 Use -updateMyBikeListWithUserid:bikelist:");
/**
 *  登录成功后 存储用户的车辆列表到本地
 *
 *  @param userid 用户id
 *  @param dict  帐号详情
 *
 *  @return 保存结果
 */
-(BOOL)updateMyDevListWithUserid:(NSString *)userid devlist:(NSArray *)devlist G100Deprecated("建议使用 Use -updateMyBikeListWithUserid:bikelist:");
/**
 *  从本地取出车辆列表
 *
 *  @param userid 用户id
 *
 *  @return 对应用户详情
 */
-(NSArray *)findMyDevlistWithUserid:(NSString *)userid G100Deprecated("建议使用 Use -findMyBikeListWithUserid:");
/**
 *  本地查询某用户的某辆车的检测结果
 *
 *  @param userid 用户id
 *  @param devid  设备id
 *
 *  @return 检测结果
 */
-(G100TestResultDomain *)findMyDevTestResultWithUserid:(NSString *)userid devid:(NSString *)devid G100Deprecated("建议使用 Use -findMyBikeTestResultWithUserid:bikeid:");

/**
 *  保存该车辆的最长提醒时长
 *
 *  @param devid 设备id
 *  @param time  时长
 *
 *  @return 更新结果
 */
-(BOOL)updateMyDevPromptTimeWithUserid:(NSString *)userid devid:(NSString *)devid propmtTime:(NSInteger)time G100Deprecated("2.0 建议使用 Use -updateMyDevPromptTimeWithUserid:bikeid:devid:propmtTime:");
/**
 *  获取该车辆的最长提醒时长
 *
 *  @param devid 设备id
 *
 *  @return 提醒时长
 */
-(NSInteger)findMyDevPromptTimeWithUserid:(NSString *)userid devid:(NSString *)devid G100Deprecated("2.0 建议使用 Use -findMyDevPromptTimeWithUserid:bikeid:devid:");

#pragma mark - 活动相关
/**
 *  保存当前用户显示过的活动
 *
 *  @param userid 用户Id
 *  @param domain 具体活动
 *
 *  @return 更新结果
 */
-(BOOL)updateCurrentEventWithUserid:(NSString *)userid detailEventDomain:(G100EventDetailDomain *)domain;
/**
 *  获取当前用户显示过的某个活动
 *
 *  @param userid 用户Id
 *  @param eventId 具体活动Id
 *
 *  @return 具体活动
 */
-(G100EventDetailDomain*)getCurrentEventWithUserId:(NSString *)userid eventId:(NSInteger)eventId;
/**
 *  保存当前用户显示过的活动
 *
 *  @param userid 用户Id
 *  @param devid  设备id
 *  @param domain 具体活动id
 *
 *  @return 更新结果
 */
-(BOOL)updateCurrentEventWithUserid:(NSString *)userid bikeid:(NSString *)bikeid detailEventDomain:(G100EventDetailDomain *)domain;
/**
 *  获取当前用户显示过的某个活动
 *
 *  @param userId  用户Id
 *  @param devid   设备id
 *  @param eventId 具体活动
 *
 *  @return 具体活动
 */
-(G100EventDetailDomain*)getCurrentEventWithUserId:(NSString *)userid bikeid:(NSString *)bikeid eventId:(NSInteger)eventId;

#pragma mark - 消息相关
/**
 *  保存新获取的离线消息个数
 *
 *  @param userId  用户Id
 *  @param hasRead 1 新增消息  0 清空消息   -1 阅读消息
 *  @param need    是否需要发送通知
 *
 *  @return 更新结果
 */
- (BOOL)updateCurrentUserNewMsgCountWithUserId:(NSString *)userId hasRead:(NSInteger)hasRead needNotification:(BOOL)need;
/**
 *  保存新获取的离线消息个数
 *
 *  @param userId  用户Id
 *  @param hasRead 1 新增消息  0 清空消息   -1 阅读消息
 *
 *  @return 更新结果
 */
- (BOOL)updateCurrentUserNewMsgCountWithUserId:(NSString *)userId hasRead:(NSInteger)hasRead;
/**
 *  获取新获取的离线消息个数
 *
 *  @param userId 用户Id
 *
 *  @return 新获取的离线消息个数
 */
- (NSInteger)getCurrentUserNewMsgCountWithUserId:(NSString *)userId;

#pragma mark - 其他相关
/**
 *  2.0 登录成功后 保存用户名密码以及用户数据
 *
 *  @param username  用户名
 *  @param password  密码
 *  @param loginInfo 用户数据
 *
 *  @return 保存状态
 */
-(BOOL)loginWithUsername:(NSString *)username password:(NSString *)password userInfo:(NSDictionary *)loginInfo;

/**
 *  2.0 删除本地设备相关信息
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *
 *  @return 删除结果
 */
-(BOOL)clearRelevantDataWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 *  2.0 删除本地设备相关信息
 *
 *  @param userid 用户id
 *  @param bikeid 车辆id
 *  @param devid  设备id
 *
 *  @return 删除结果
 */
-(BOOL)clearRelevantDataWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;
/**
 *  2.0 用户退出 清空数据
 *
 *  @return 退出状态
 */
-(BOOL)clearAllData;

#pragma mark - 数据简单存取
/** 缓存数据 */
-(void)setAsynchronous:(id)object withKey:(NSString *)key;
/** 清除缓存 */
-(void)clearAsynchronousWithKey:(NSString *)key;
/** 取缓存 */
-(id)getAsynchronousWithKey:(NSString *)key;

#pragma mark - 各种提醒的计数
/**
 *  更新某事件剩余提醒次数
 *
 *  @param remainderKey 事件唯一ID
 *
 *  @return YES/NO
 */
- (BOOL)updateRemainderTimesWithKey:(NSString *)remainderKey leftTimes:(NSInteger)times;
/**
 *  某事件剩余的提醒次数
 *
 *  @param remainderKey  事件的唯一ID
 *
 *  @return 剩余次数
 */
- (NSInteger)leftRemainderTimesWithKey:(NSString *)remainderKey;
/**
 *  设置某一事件的提醒次数
 *
 *  @param remainderKey  事件的唯一ID
 *  @param times         提醒次数
 *  @param dependVersion 是否和版本相关
 *
 *  @return YES/NO
 */
- (BOOL)setLeftRemainderTimesWithKey:(NSString *)remainderKey times:(NSInteger)times dependOnVersion:(BOOL)dependOnVersion;

/**
 *  更新某事件剩余提醒次数
 *
 *  @param remainderKey 事件唯一ID
 *  @param times        剩余次数
 *  @param userid       用户id 如与用户无关则传 nil
 *  @param devid        设备id 如与设备无关则传 nil
 *
 *  @return YES/NO
 */
- (BOOL)updateRemainderTimesWithKey:(NSString *)remainderKey leftTimes:(NSInteger)times userid:(NSString *)userid devid:(NSString *)devid;
/**
 *  某事件剩余的提醒次数
 *
 *  @param remainderKey  事件的唯一ID
 *  @param userid       用户id 如与用户无关则传 nil
 *  @param devid        设备id 如与设备无关则传 nil
 *
 *  @return 剩余次数
 */
- (NSInteger)leftRemainderTimesWithKey:(NSString *)remainderKey userid:(NSString *)userid devid:(NSString *)devid;
/**
 *  设置某一事件的提醒次数
 *
 *  @param remainderKey  事件的唯一ID
 *  @param times         提醒次数
 *  @param userid       用户id 如与用户无关则传 nil
 *  @param devid        设备id 如与设备无关则传 nil
 *  @param dependVersion 是否和版本相关
 *
 *  @return YES/NO
 */
- (BOOL)setLeftRemainderTimesWithKey:(NSString *)remainderKey times:(NSInteger)times userid:(NSString *)userid devid:(NSString *)devid dependOnVersion:(BOOL)dependOnVersion;

#pragma mark - 车辆绑定成功消息
/**
 *  有新车绑定成功后时 存储一下绑定成功的信息
 *
 *  @param userid 用户id
 *  @param devid  设备id
 *
 *  @return YES/NO
 */
- (BOOL)updateNewDevBindSuccessWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid params:(NSDictionary *)params;
/**
 *  获取是否有新设备绑定成功的信息
 *
 *  @param userid 用户id
 *
 *  @return 数组元素 [0]用户id [1]车辆id [2]设备id
 */
- (NSArray *)findThereisNewDevBindSuccessWithUserid:(NSString *)userid;

#pragma mark - 用户测试三方报警时的本地参数存储
/**
 *  进入推送测试时 如果测试未完成 存储一下测试信息
 *
 *  @param userid 用户id
 *  @param devid  设备id
 *  @param params 页面参数 @{userid, bikeid, devid, isTrainTest, entrance}
 *
 *  @return YES/NO
 */
- (BOOL)updatePushTestResultWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid params:(NSDictionary *)params;
/**
 *  获取是否有设备测试中的信息
 *
 *  @param userid 用户id
 *
 *  @return 字典 测试结果页面属性
 */
- (NSDictionary *)findThereisPushTestResultWithUserid:(NSString *)userid;

#pragma mark - 记录用户手机收取最后一条推送的时间
/**
 *  更新最后一次推送时间
 *  用户在下次启动应用的时候 自动检测这个时间是否超过五天 如果超过五天 则弹出提示 引导用户前去测试推送
 *
 *  @param lastest_time 最后一次推送时间
 *
 *  @return YES/NO
 */
- (BOOL)updateLastestNotificationTime:(NSDate *)lastest_time;

/**
 *  获取最后一次推送时间
 *
 *  @return 最后一次推送时间
 */
- (NSDate *)findLastestNotificationTime;


/**
 根据devid设置upgradeid

 @param upgradeID 升级id
 @param devid 设备id
 */
- (void)setUpgradeID:(NSNumber *)upgradeID devid:(NSString *)devid;

/**
 根据devid获取upgradeid

 @param devid 设备id
 @return 当前设备的upgradeid
 */
- (NSNumber *)getUpgradeIDWithDevid:(NSString *)devid;

/**
 根据userid设置已同意隐私version
 
 @param userid 当前用户id
 @param version 当前同意最新隐私版本
 */
- (void)updatePrivacyWithUserid:(NSString *)userid version:(NSString *)version;

/**
 根据userid获取当前隐私版本
 
 @param userid 用户id
 @return 当前隐私政策版本
 */
- (NSString *)getPrivacyVersionWithUserid:(NSString *)userid;

@end
