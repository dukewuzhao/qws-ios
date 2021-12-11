//
//  G100DevApi.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"

typedef enum : NSInteger {
    G100DevProfileUpdateTypeBrand = 1,
    G100DevProfileUpdateTypeServiceNum,
    G100DevProfileUpdateTypeFeature
}G100DevProfileUpdateType; //更新数据类型 1品牌 2厂商电话 3特征信息

@interface G100DevApi : NSObject

+(instancetype) sharedInstance;

/**
 *  获取当前用户的设备列表
 *
 *  @param callback  接口回调
 */
-(ApiRequest *)loadCurrentUserDevlistWithCallback:(API_CALLBACK)callback;

/**
 *  获取某一组电动车的信息
 *
 *  @param  devid       电动车id数组
 *  @param  callback    接口回调
 */
-(ApiRequest *)loadCurrentUserDevlistWithDevid:(NSArray *)devid callback:(API_CALLBACK)callback;

/**
 *  获取电动车当前位置
 *
 *  @param  devid       设备号
 *  @param  tracemode   追踪状态标识，0非追踪态 1进入追踪态 (默认使用0，可以不传，进入实时追踪界面时传1)
 *  @param  callback    接口回调
 */
-(ApiRequest *)getDevCurrentPositionWithDevid:(NSString *)devid tracemode:(NSInteger)tracemode callback:(API_CALLBACK)callback;

/**
 *  获取电动车特定日期的行驶情况概要
 *
 *  @param  devid    设备号
 *  @param  day      某一天
 *  @param  callback 接口回调
 */
-(ApiRequest *)getDevDriveSummaryWithDevid:(NSString *)devid
                                day:(NSString *)day
                           callback:(API_CALLBACK)callback;
/**
 *  获取电动车按日汇总概要
 *
 *  @param  devid    设备号
 *  @param  callback 接口回调
 */
-(ApiRequest *)loadDevDayDriveSummaryWithDevid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  获取电动车历史轨迹
 *
 *  @param  devid     设备号
 *  @param  begintime 开始时间
 *  @param  endtime   结束时间
 *  @param  callback  接口回调
 */
-(ApiRequest *)loadDevHistoryTrackWithDevid:(NSString *)devid
                         begintime:(NSString *)begintime
                           endtime:(NSString *)endtime
                          callback:(API_CALLBACK)callback;

/**
 *  获取电动车电量
 *
 *  @param  devid       设备号
 *  @param  callback    接口回调
 */
-(ApiRequest *)getDevCurrentPowerWithDevid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  绑定电动车
 *  
 *  @param  qr       定位器二维码
 *  @param  callback 接口回调
 */
-(ApiRequest *)bindNewDevWithQRCode:(NSString *)qr callback:(API_CALLBACK)callback G100Deprecated("建议使用bindNewDevWithQRCode:alertor:callback:");

/**
 *  绑定电动车 new接口 区分前装 后装
 *
 *  @param  qr       定位器二维码
 *  @param  alertor  报警器类型  0 未定义   -1 无报警器     1 有报警器
 *  @param  callback 接口回调
 */
-(ApiRequest *)bindNewDevWithQRCode:(NSString *)qr alertor:(NSInteger)alertor callback:(API_CALLBACK)callback;

/**
 *  检查电动车绑定
 *
 *  @param  devid    设备号
 *  @param  callback 接口回调
 */
-(ApiRequest *)checkBindWithBikeid:(NSString *)bikeid Devid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  重新绑定
 *  
 *  @param  devid     设备号
 *  @param  callback  接口回调
 */
-(ApiRequest *)rebindDevWithDevid:(NSString *)devid callback:(API_CALLBACK)callback;
 
/**
 *  获取和电动车有关系的用户列表
 *
 *  @param  devid    设备号
 *  @param  callback 接口回调
 */
-(ApiRequest *)loadRelativeUserinfoWithDevid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  修改电动车名称
 *
 *  @param  devid       设备号
 *  @param  name        新名称
 *  @param  callback    接口回调
 */
-(ApiRequest *)modifyDevNameWithDevid:(NSString *)devid
                         name:(NSString *)name
                     callback:(API_CALLBACK)callback;

/**
 *  解除用户（非机主）对电动车的查看权限
 *
 *  @param  devid       设备号
 *  @param  userid      用户id
 *  @param  callback    接口回调
 */
-(ApiRequest *)removeDevUserWithDevid:(NSString *)devid
                       userid:(NSString *)userid
                     callback:(API_CALLBACK)callback;

/**
 *  解除对电动车的绑定
 *
 *  @param  devid       设备号
 *  @param  vcode       验证码
 *  @param  callback    接口回调
 */
-(ApiRequest *)removeDevUserSelfWithDevid:(NSString *)devid
                            vcode:(NSString *)vcode
                         callback:(API_CALLBACK)callback;

/**
 *  删除设备
 *
 *  @param  devid       设备号
 *  @param  vcode       验证码
 *  @param  callback    接口回调
 */
-(ApiRequest *)deleteDevWithBikeid:(NSString *)bikeid
                            deviceid:(NSString *)deviceid
                         callback:(API_CALLBACK)callback;
/**
 *  设置电动车安防选项
 *
 *  @param  data        数据
 *  "data": {                           // 数据
         "secset": [{                   // 安防设置
         "devid" : "1",                 // 电动车编号
         "vibrate":"1",                 // 震动
         "elecfence" :"1",              // 电子围栏
         "battrm" :"1",                 // 电瓶移除
         "lowpower":"1"                 // 低电量
         "lockswitch":"1"               // 开关锁
         "regularrep": "1"              // 定时报告
     }]
 }
 *  @param  callback    接口回调
 */
-(ApiRequest *)setSecuritySetingWithData:(NSDictionary *)data callback:(API_CALLBACK)callback G100Deprecated("2.0 接口废弃");

/**
 *  获取电动车的各类日志消息
 *
 *  @param  devid     设备号
 *  @param  begintime 开始时间
 *  @param  endtime   结束时间
 *  @param  callback  接口回调
 */
-(ApiRequest *)loadListDevMsgWithDevid:(NSString *)devid
                     begintime:(NSString *)begintime
                       endtime:(NSString *)endtime
                      callback:(API_CALLBACK)callback;

/**
 *  电动车授权
 *  @param  bikeid      车辆id
 *  @param  devid       设备号
 *  @param  userid      用户id
 *  @param  grant       授权类型
 *  @param  privs       权限
 *  @param  msgid       消息id push中传过来的msgid unit64类型
 *  @param  callback    接口回调
 */
-(ApiRequest *)grantDevPrivsWithBikeid:(NSString *)bikeid
                        Devid:(NSString *)devid
                        userid:(NSString *)userid
                        grant:(NSString *)grant
                        privs:(NSString *)privs
                        msgid:(NSInteger)msgid
                        callback:(API_CALLBACK)callback;

/**
 *  电动车加锁解锁
 *
 *  @param  devid       设备号
 *  @param  lock        加解锁指令
 *  @param  callback    接口回调
 */
-(ApiRequest *)controllerLockWithDevid:(NSString *)devid
                          lock:(NSInteger)lock
                      callback:(API_CALLBACK)callback;

/**
 *  电动车加锁解锁状态
 *
 *  @param  devid       设备号
 *  @param  callback    接口回调
 */
-(ApiRequest *)getDevStatusWithDevid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  电动车安全评分
 *
 *  @param  token           口令
 *  @param  devid           设备号
 *  @param  securitysetting 当前安防等级
 *  @param  callback        接口回调
 */
-(ApiRequest *)evaluatingDevSafetyScoreWithDevid:(NSString *)devid
                         securitysetting:(NSInteger)securitysetting
                                callback:(API_CALLBACK)callback;

/**
 *  安防设置
 *
 *  @param  token       口令
 *  @param  devid       设备号
 *  @param  mode        模式
 *  @param  detail      具体内容    字典形式
 *  "detail" : {
                 "vibrate1": 1 ,    //轻微震动
                 "vibrate2": 0 ,    //中度震动
                 "vibrate3": 0 ,    //严重震动
                 "lowpower": 0 ,     //低电量
                 "battrm" : 0 ,    //电瓶移除
                 "battin" : 0 ,    //电瓶接入
                 "abnormalmove": 1, //非法移动
                }
 *  @param  bluetooth   蓝牙感应
 *  @param  callback    接口回调
 */
-(ApiRequest *)setDevSecuritySettingsWithDevid:(NSString *)devid
                                  mode:(NSInteger)mode
                                detail:(NSDictionary *)detail
                             bluetooth:(NSInteger)bluetooth
                              callback:(API_CALLBACK)callback G100Deprecated("2.0 接口废弃");

/**
 *  用户点击忽略或找车
 *  
 *  @param  token       口令
 *  @param  devid       设备id
 *  @param  type        动作  igonre 忽略   find 找车
 *  @param  callback    接口回调
 */
-(ApiRequest *)ignoreOrFindDevWhenWarnComeWithBikeid:(NSString *)bikeid devid:(NSString *)devid
                                       type:(NSString *)type
                                   callback:(API_CALLBACK)callback;

/**
 *  根据二维码检查设备类型
 *
 *  @param qr       设备二维码
 *  @param callback 接口回调
 */
-(ApiRequest *)checkDevtypeWithQr:(NSString *)qr callback:(API_CALLBACK)callback;

/**
 *  设置报警器选项
 *
 *  @param devid    设备id
 *  @param alertor  报警器类型 0 无   1 有
 *  @param callback 接口回调
 */
-(ApiRequest *)setAlertSwitchWithDevid:(NSString *)devid alertor:(NSInteger)alertor callback:(API_CALLBACK)callback;

/**
 *  给报警器发送指令
 *
 *  @param devid         设备id
 *  @param command       指令类型   1 设防    2 撤防    3 开关电门  4 鸣笛
 *  @param commandParams 指令参数值  
 *  {"type" : 0} 
 *  设防：1 正常设防  2 静音设防
 *  撤防：暂不使用
 *  开关电门：1 开电门  2 关电门
 *  鸣笛：未定义
 *  @param callback      接口回调
 */
- (ApiRequest *)sendOperateAlertorWithBikeid:(NSString *)bikeid devid:(NSString *)devid command:(NSInteger)command commandParams:(NSDictionary *)commandParams callback:(API_CALLBACK)callback;

/**
 *  设置相同报警（推送到app）忽略的时间
 *
 *  @param devid      电动车编号
 *  @param ignoretime 忽略时间（分钟） 0 无
 *  @param callback   接口回调
 */
- (ApiRequest *)setSamePushIgnoreWithDevid:(NSString *)devid ignoretime:(NSInteger)ignoretime callback:(API_CALLBACK)callback;

/**
 *  忽略相同的报警
 *
 *  @param devid    电动车编号
 *  @param pushtype 推送类型，使用推送代码。不同的震动级别定义为不同类型，用推送代码+震动级别表示，即0110/0120/0130
 *  @param callback 接口回调
 */
- (ApiRequest *)ignoreSamePushWithDevid:(NSString *)devid pushtype:(NSString *)pushtype callback:(API_CALLBACK)callback;

/**
 *  设置电门开关提醒功能
 *
 *  @param devid    车辆id
 *  @param noify    功能开关
 *  @param callback 接口回调
 */
- (ApiRequest *)setAccNotify:(NSString *)devid notify:(NSInteger)notify callback:(API_CALLBACK)callback;

/**
 *  重启定位器
 *
 *  @param devid    电动车编号
 *  @param callback 接口回调
 */
- (ApiRequest *)rebootLocatorWithDevid:(NSString *)devid callback:(API_CALLBACK)callback;
/**
 重新启动定位器 2.0
 
 @param bikeid 车辆id
 @param devid 设备id
 @param callback 接口回调
 */
- (ApiRequest *)rebootLocatorWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  检查定位器重启
 *
 *  @param devid    电动车编号
 *  @param minute   检查n分钟内
 *  @param callback 接口回调
 */
- (ApiRequest *)checkLocatorRebootWithDevid:(NSString *)devid minute:(NSInteger)minute callback:(API_CALLBACK)callback G100Deprecated("2.0 接口废弃");

/**
 检查定位器重启 2.0

 @param bikeid 电动车编号
 @param devid 设备编号
 @param minute 检查n分钟内
 @param callback 接口回调
 */
- (ApiRequest *)checkLocatorRebootWithBikeid:(NSString *)bikeid devid:(NSString *)devid minute:(NSInteger)minute callback:(API_CALLBACK)callback;
/**
 *  获取电动车特征信息
 *
 *  @param devid    电动车编号
 *  @param callback 接口回调
 */
- (ApiRequest *)getBikeFeatureWithDevid:(NSString *)devid callback:(API_CALLBACK)callback G100Deprecated("2.0 接口废弃");

/**
 获取电动车特征信息2.0

 @param bikeid 电动车id
 @param callback 接口回调
 */
- (ApiRequest *)getBikeFeatureWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 *  更新电动车资料
 *
 *  @param devid          电动车编号
 *  @param updateType     更新数据类型 1品牌 2厂商电话 3特征信息
 *  @param name           电动车昵称
 *  @param custbrand      品牌
 *  @param custservicenum 厂商电话
 *  @param picturedel     删除的图片url
 *  @param pictureadd     新添图片数据，base64字符串
 *  @param color          车辆颜色
 *  @param type           车型 99其它 1滑板 2两轮 3三轮 4四轮 5电动自行车 6摩托车
 *  @param platenumber    车牌号
 *  @param otherfeature   其它信息
 *  @param vin            车架号
 *  @param motornumber    电机号
 *  @param callback       接口回调
 */
- (ApiRequest *)updateBikeProfileWithDev:(NSString *)devid
                      updateType:(G100DevProfileUpdateType)updateType
                         profile:(NSDictionary *)devInfo
                  imageDataArray:(NSArray*)imageDataArray
                  imageNameArray:(NSArray*)imageNameArray
                        /*  name:(NSString *)name
                       custbrand:(NSString *)custbrand
                  custservicenum:(NSString *)custservicenum
                      picturedel:(NSArray *)picturedel
                      pictureadd:(NSArray *)pictureadd
                           color:(NSString *)color
                            type:(NSInteger)type
                     platenumber:(NSString *)platenumber
                    otherfeature:(NSString *)otherfeature
                             vin:(NSString *)vin
                     motornumber:(NSString *)motornumber */
                        progress:(Progress_Callback)progressCallback
                        callback:(API_CALLBACK)callback;

/**
 *  获取丢车记录
 *
 *  @param devid    电动车编号
 *  @param lostid   丢车记录id，数组，可空
 *  @param callback 接口回调
 */
- (ApiRequest *)getBikeLostRecordWithDev:(NSString *)devid lostid:(NSArray *)lostid callback:(API_CALLBACK)callback;

/**
 *  上报丢车
 *
 *  @param devid     电动车编号
 *  @param lostid    丢车记录id，为0表示新上报 >0表示更新
 *  @param lostlongi 丢车时经度
 *  @param lostlati  丢车时纬度
 *  @param losttime  丢车时间
 *  @param lostlocdesc 丢车地点
 *  @param contact   联系人
 *  @param phonenum  联系人电话
 *  @param callback  接口回调
 */
- (ApiRequest *)reportBikeLostWithDev:(NSString *)devid
                       lostid:(NSInteger)lostid
                    lostlongi:(CGFloat)lostlongi
                     lostlati:(CGFloat)lostlati
                     losttime:(NSString *)losttime
                  lostlocdesc:(NSString *)lostlocdesc
                      contact:(NSString *)contact
                     phonenum:(NSString *)phonenum
                     callback:(API_CALLBACK)callback;

/**
 *  添加寻车记录
 *
 *  @param devid    电动车编号
 *  @param lostid   丢失记录id
 *  @param desc     寻车记录文本
 *  @param picture  新天图片数据， base64字符串
 *  @param callback 接口回调
 */
- (ApiRequest *)addFindLostRecordWithDev:(NSString *)devid
                          lostid:(NSInteger)lostid
                            desc:(NSString *)desc
                         picture:(NSArray *)picture
                        callback:(API_CALLBACK)callback;

/**
 *  获取寻车记录
 *
 *  @param devid    电动车编号
 *  @param lostid   丢车记录id
 *  @param page     分页页码
 *  @param size     每页个数
 *  @param callback 接口回调
 */
- (ApiRequest *)getFindLostRecordWithDev:(NSString *)devid
                          lostid:(NSInteger)lostid
                            page:(NSInteger)page
                            size:(NSInteger)size
                        callback:(API_CALLBACK)callback;

/**
 *  删除寻车记录
 *
 *  @param devid      电动车编号
 *  @param lostid     丢车记录id
 *  @param findlostid 寻车记录id
 *  @param callback   接口回调
 */
- (ApiRequest *)deleteFindLostRecordWithDev:(NSString *)devid
                             lostid:(NSInteger)lostid
                         findlostid:(NSInteger)findlostid
                           callback:(API_CALLBACK)callback;

/**
 *  结束寻车
 *
 *  @param devid        电动车编号
 *  @param lostid       丢车记录id
 *  @param foundlongi   经度
 *  @param callback     纬度
 *  @param callback     找到位置
 *  @param callback     接口回调
 */
- (ApiRequest *)endFindLostWithDev:(NSString *)devid
                    lostid:(NSInteger)lostid
                foundlongi:(CGFloat)foundlongi
                 foundlati:(CGFloat)foundlati
              foundlocdesc:(NSString *)foundlocdesc
                  callback:(API_CALLBACK)callback;
/**
 *  上传寻车分享连接
 *
 *  @param lostid   丢车id
 *  @param devid    设备id
 *  @param shareurl 分享链接
 *  @param callback 接口回调
 */
- (ApiRequest *)shareBikeLostWithLostid:(NSInteger)lostid
                          devid:(NSString *)devid
                       shareurl:(NSString *)shareurl
                       callback:(API_CALLBACK)callback;

/**
 *  设置微信报警通知
 *
 *  @param devid    设备id
 *  @param notify   功能开关 0关，1开
 *  @param callback 接口回调
 */
- (ApiRequest *)setWXNotifyWithDevid:(NSString *)devid notify:(BOOL)notify callback:(API_CALLBACK)callback;
/**
 *  设置电话报警通知
 *
 *  @param devid    设备id
 *  @param notify   功能开关 0关，1开
 *  @param callback 接口回调
 */
- (ApiRequest *)setPhoneNotifyWithDevid:(NSString *)devid notify:(BOOL)notify callback:(API_CALLBACK)callback;
/**
 *  发送测试报警消息
 *
 *  @param devid    设备id
 *  @param type     测试类型 1app 2微信 3电话
 *  @param callback 接口回调
 */
/**
 设置报警报警通知
 
 @param devid    设备id
 @param phoneNum 接收报警的手机号
 @param notify   功能开关 0关 1开 关闭报警的时候不用传手机号
 @param callback 接口回调
 */
- (ApiRequest *)setPhoneNotifyWithDevid:(NSString *)devid phoneNum:(NSString *)phoneNum notify:(BOOL)notify callback:(API_CALLBACK)callback;
- (ApiRequest *)testAlarmNotifyWithDevid:(NSString *)devid type:(NSInteger)type callback:(API_CALLBACK)callback;
/**
 *  2.0 发送测试报警消息
 *
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param type     测试类型 1app 2微信 3电话
 *  @param callback 接口回调
 */
- (ApiRequest *)testAlarmNotifyWithBikeid:(NSString *)bikeid devid:(NSString *)devid type:(NSInteger)type callback:(API_CALLBACK)callback;
/**
 *  更换定位器设备（针对可用任何卡设备）
 *
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param qr       新定位器二维码
 *  @param callback 接口回调
 */
- (ApiRequest *)changeLocatorWithBikeid:(NSString *)bikeid devid:(NSString *)devid qr:(NSString *)qr callback:(API_CALLBACK)callback;

/**
 2.0 修改设备名称

 @param bikeid     车辆id
 @param devid      设备id
 @param deviceName 设备名称
 @param callback   接口回调
 */
- (ApiRequest *)updateDeviceNameWithBikeid:(NSString *)bikeid devid:(NSString *)devid deviceName:(NSString *)deviceName callback:(API_CALLBACK)callback;
/**
 *  2.0 电动车加锁解锁
 *
 *  @param  devid       设备号
 *  @param  lock        加解锁指令
 *  @param  callback    接口回调
 */
- (ApiRequest *)controllerLockWithBikeid:(NSString *)bikeid devid:(NSString *)devid lock:(NSInteger)lock callback:(API_CALLBACK)callback;

/**
 *  1.5.2 新增设置报警器声音
 *
 *  @param devid    车辆id
 *  @param func     功能id
 *  @param sound    声音id 0无 1舒缓 2普通
 *  @param callback 接口回调
 */
- (ApiRequest *)setAlertorSoundWithDevid:(NSString *)devid func:(NSInteger)func sound:(NSInteger)sound callback:(API_CALLBACK)callback;
/**
 *  新增设置报警器声音 2.0
 *
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param func     功能id
 *  @param sound    声音id 0无 1舒缓 2普通
 *  @param callback 接口回调
 */
- (ApiRequest *)setAlertorSoundWithBikeid:(NSString *)bikeid devid:(NSString *)devid func:(NSInteger)func sound:(NSInteger)sound callback:(API_CALLBACK)callback;

@end
