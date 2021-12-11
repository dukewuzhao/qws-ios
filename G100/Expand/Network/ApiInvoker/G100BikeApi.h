//
//  G100BikeApi.h
//  G100
//
//  Created by yuhanle on 16/7/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    G100BikeProfileUpdateTypeBrand = 1,
    G100BikeProfileUpdateTypeServiceNum,
    G100BikeProfileUpdateTypeFeature
}G100BikeProfileUpdateType; //更新数据类型 1品牌 2厂商电话 3特征信息
@interface G100BikeApi : NSObject

+(instancetype) sharedInstance;

/**
 *  添加车辆
 *
 *  @param bikeInfo 车辆信息
 *  @param callback 接口回调
 */
-(ApiRequest *)addBikeWithUserid:(NSString *)userid bikeInfo:(NSDictionary *)bikeInfo callback:(API_CALLBACK)callback;

/**
 *  获取所有车辆列表
 *
 *  @param userid   用户id
 *  @param callback 接口回调
 */
- (ApiRequest *)getAllBikelistWithUserid:(NSString *)userid callback:(API_CALLBACK)callback;

/**
 *  获取指定多个车辆信息
 *
 *  @param userid   用户id
 *  @param bikeids  车辆id 数组
 *  @param callback 接口回调
 */
- (ApiRequest *)getBikelistWithUserid:(NSString *)userid bikeids:(NSArray *)bikeids callback:(API_CALLBACK)callback;

/**
 *  获取指定车辆信息
 *
 *  @param userid   用户id
 *  @param bikeid   车辆id
 *  @param callback 接口回调
 */
- (ApiRequest *)getBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 *  获取车辆当前实时数据
 *
 *  @param bikeids   车辆id列表
 *  @param traceMode 追踪状态标识，0非追踪态 1进入追踪态 (默认0，进入实时追踪界面时传1)
 *  @param callback  接口回调
 */
- (ApiRequest *)getBikeRuntimeWithBike_ids:(NSArray *)bikeids traceMode:(NSInteger)traceMode callback:(API_CALLBACK)callback;

/**
 *  获取设备当前实时数据
 *
 *  @param bikeid     车辆id
 *  @param device_ids 设备id列表
 *  @param callback   接口回调
 */
- (ApiRequest *)getDeviceRuntimeWithbikeid:(NSInteger)bikeid device_ids:(NSArray *)device_ids callback:(API_CALLBACK)callback;

/**
 *  设置电动车安防选项
 *
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param mode     安防模式 1低 2标准 3警戒 8丢车模式 9撤防
 *  @param callback 接口回调
 */
- (ApiRequest *)setBikeSecuritySettingsWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid mode:(NSInteger)mode callback:(API_CALLBACK)callback;

/**
 *  电动车安全评分
 *
 *  @param  token           口令
 *  @param  bikeid          车辆号
 *  @param  callback        接口回调
 */
-(ApiRequest *)evaluatingBikeSafetyScoreWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 *  绑定电动车设备
 *
 *  @param userid   用户id
 *  @param bikeid   车辆id
 *  @param bikeName 车辆名称
 *  @param new_flag 新建车辆标志 0不新建 1新建
 *  @param qr       设备（GPS或蓝牙）二维码
 *  @param callback 接口回调
 */
- (ApiRequest *)bindBikeDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName new_flag:(NSInteger)new_flag qr:(NSString *)qr callback:(API_CALLBACK)callback;

/**
 *  重新绑定电动车设备
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param callback 接口回调
 */
- (ApiRequest *)rebindBikeDeviceWithbikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback;
/**
 *  添加电动车设备
 *
 *  @param userid   用户id
 *  @param bikeid   车辆id
 *  @param bikeName 车辆名称
 *  @param new_flag 新建车辆标志 0不新建 1新建
 *  @param qr       设备（GPS或蓝牙）二维码
 *  @param callback 接口回调
 */
- (ApiRequest *)addBikeDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName new_flag:(NSInteger)new_flag qr:(NSString *)qr callback:(API_CALLBACK)callback;
/**
 *  添加电动车设备
 *
 *  @param userid   用户id
 *  @param bikeid   车辆id
 *  @param bikeName 车辆名称
 *  @param new_flag 新建车辆标志 0不新建 1新建
 *  @param devid    设备id
 *  @param callback 接口回调
 */
- (ApiRequest *)addBikeDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName new_flag:(NSInteger)new_flag devid:(NSString *)devid callback:(API_CALLBACK)callback;
/**
 *  删除车辆
 *
 *  @param userid   用户id
 *  @param bikeid   车辆id
 *  @param callback 接口回调
 */
- (ApiRequest *)deleteBikeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 *  2.0 获取电动车按日汇总概要
 *
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param callback 接口回调
 */
- (ApiRequest *)loadDevDayDriveSummaryWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  2.0 获取电动车的各类日志消息
 *
 *  @param bikeid    车辆id
 *  @param devid     设备id
 *  @param begintime 开始时间
 *  @param endtime   结束时间
 *  @param callback  接口回调
 */
- (ApiRequest *)loadListDevMsgWithBikeid:(NSString *)bikeid
                           devid:(NSString *)devid
                       begintime:(NSString *)begintime
                         endtime:(NSString *)endtime
                        callback:(API_CALLBACK)callback;
/**
 *  2.0 获取电动车行驶轨迹（坐标点数组）
 *
 *  @param bikeid    车辆id
 *  @param devid     设备id
 *  @param begintime 开始时间
 *  @param endtime   结束时间
 *  @param callback  接口回调
 */
- (ApiRequest *)loadDevHistoryTrackWithBikeid:(NSString *)bikeid
                                devid:(NSString *)devid
                           begintime:(NSString *)begintime
                             endtime:(NSString *)endtime
                            callback:(API_CALLBACK)callback;

/**
 *  获取和电动车有关系的用户列表
 *
 *  @param  bikeid   车辆id
 *  @param  callback 接口回调
 */
- (ApiRequest *)loadRelativeUserinfoWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 *  更新车辆名称
 *
 *  @param bikeid   车辆id
 *  @param bikeName 车辆名称
 *  @param callback 接口回调
 */
- (ApiRequest *)updateBikeNameWithBikeid:(NSString *)bikeid bikedName:(NSString *)bikeName callback:(API_CALLBACK)callback;

/**
 *  更新电动车资料
 *
 *  @param bikeid          电动车编号
 *  @param updateType     更新数据类型 1品牌 2厂商电话 3特征信息
 *  @param picturedel     删除的图片url
 *  @param pictureadd     新添图片数据，base64字符串
 *  @param callback       接口回调
 */

- (ApiRequest *)updateBikeProfileWithBikeid:(NSString *)bikeid
                                   bikeType:(NSInteger)bikeType
                                    profile:(NSDictionary *)bikeInfo
                                   progress:(Progress_Callback)progressCallback
                                   callback:(API_CALLBACK)callback;
/**
 *  解除用户（非机主）对电动车的查看权限
 *
 *  @param  bikeid      车辆号
 *  @param  userid      用户id
 *  @param  callback    接口回调
 */
-(ApiRequest *)removeBikeUserWithUserid:(NSString *)userid
                       bikeid:(NSString *)bikeid
                     callback:(API_CALLBACK)callback;

/**
 获取电动车品牌列表

 @param callback 接口回调
 */
- (ApiRequest *)getBikeBrandsWithBikeType:(NSInteger)bikeType :(API_CALLBACK)callback;

/**
 *  设置微信报警通知
 *
 *  @param devid    设备id
 *  @param notify   功能开关 0关，1开
 *  @param callback 接口回调
 */
- (ApiRequest *)setWXNotifyWithBikeid:(NSString *)bikeid notify:(BOOL)notify callback:(API_CALLBACK)callback;
/**
 *  设置电话报警通知
 *
 *  @param devid    设备id
 *  @param notify   功能开关 0关，1开
 *  @param callback 接口回调
 */
- (ApiRequest *)setPhoneNotifyWithBikeid:(NSString *)bikeid notify:(BOOL)notify callback:(API_CALLBACK)callback;
/**
    设置电话报警通知
 
 @param devid    设备id
 @param phoneNum 接收报警的手机号
 @param notify   功能开关 0关 1开 关闭报警的时候不用传手机号
 @param callback 接口回调
 */
- (ApiRequest *)setPhoneNotifyWithBikeid:(NSString *)bikeid phoneNum:(NSString *)phoneNum notify:(BOOL)notify callback:(API_CALLBACK)callback;

/**
 *  获取丢车记录
 *
 *  @param bikeid    电动车编号
 *  @param lostid   丢车记录id，数组，可空
 *  @param callback 接口回调
 */
- (ApiRequest *)getBikeLostRecordWithBikeid:(NSString *)bikeid lostid:(NSArray *)lostid callback:(API_CALLBACK)callback;

/**
 *  上报丢车
 *
 *  @param bikeid     电动车编号
 *  @param lostid    丢车记录id，为0表示新上报 >0表示更新
 *  @param lostlongi 丢车时经度
 *  @param lostlati  丢车时纬度
 *  @param losttime  丢车时间
 *  @param lostlocdesc 丢车地点
 *  @param contact   联系人
 *  @param phonenum  联系人电话
 *  @param callback  接口回调
 */
- (ApiRequest *)reportBikeLostWithBikeid:(NSString *)bikeid
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
 *  @param bikeid    电动车编号
 *  @param lostid   丢失记录id
 *  @param desc     寻车记录文本
 *  @param picture  新天图片数据， base64字符串
 *  @param callback 接口回调
 */
- (ApiRequest *)addFindLostRecordWithBikeid:(NSString *)bikeid
                          lostid:(NSInteger)lostid
                            desc:(NSString *)desc
                         picture:(NSArray *)picture
                        callback:(API_CALLBACK)callback;

/**
 *  获取寻车记录
 *
 *  @param bikeid    电动车编号
 *  @param lostid   丢车记录id
 *  @param page     分页页码
 *  @param size     每页个数
 *  @param callback 接口回调
 */
- (ApiRequest *)getFindLostRecordWithBikeid:(NSString *)bikeid
                          lostid:(NSInteger)lostid
                            page:(NSInteger)page
                            size:(NSInteger)size
                        callback:(API_CALLBACK)callback;

/**
 *  删除寻车记录
 *
 *  @param bikeid      电动车编号
 *  @param lostid     丢车记录id
 *  @param findlostid 寻车记录id
 *  @param callback   接口回调
 */
- (ApiRequest *)deleteFindLostRecordWithBikeid:(NSString *)bikeid
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
- (ApiRequest *)endFindLostWithBikeid:(NSString *)bikeid
                    lostid:(NSInteger)lostid
                foundlongi:(CGFloat)foundlongi
                 foundlati:(CGFloat)foundlati
              foundlocdesc:(NSString *)foundlocdesc
                  callback:(API_CALLBACK)callback;
/**
 *  上传寻车分享连接
 *
 *  @param lostid   丢车id
 *  @param bikeid    设备id
 *  @param shareurl 分享链接
 *  @param callback 接口回调
 */
- (ApiRequest *)shareBikeLostWithLostid:(NSInteger)lostid
                          bikeid:(NSString *)bikeid
                       shareurl:(NSString *)shareurl
                       callback:(API_CALLBACK)callback;
/**
 *  设置电门开关提醒功能
 *
 *  @param bikeid    车辆id
 *  @param noify    功能开关
 *  @param callback 接口回调
 */
- (ApiRequest *)setAccNotifyWithBikeid:(NSString *)bikeid notify:(NSInteger)notify callback:(API_CALLBACK)callback;

/**
 *  设置相同报警（推送到app）忽略的时间
 *
 *  @param bikeid      电动车编号
 *  @param ignoretime 忽略时间（分钟） 0 无
 *  @param callback   接口回调
 */
- (ApiRequest *)setSamePushIgnoreWithBikeid:(NSString *)bikeid ignoretime:(NSInteger)ignoretime callback:(API_CALLBACK)callback;

/**
 *  忽略相同的报警
 *
 *  @param bikeid   电动车编号
 *  @param pushtype 推送类型，使用推送代码。不同的震动级别定义为不同类型，用推送代码+震动级别表示，即0110/0120/0130
 *  @param callback 接口回调
 */
- (ApiRequest *)ignoreSamePushWithBikeid:(NSString *)bikeid pushtype:(NSString *)pushtype callback:(API_CALLBACK)callback;


/**
 设置车最高时速

 @param bikeid 车辆id
 @param maxSpeed 最高时速
 @param callback 接口回调
 @return
 */
- (ApiRequest *)setOverSpeedWithBikeid:(NSString *)bikeid  maxSpeed:(CGFloat)maxSpeed callback:(API_CALLBACK)callback;
/**
 设置电动车卡片封面图片显示

 @param bikeid 车辆id
 @param coverPicture 图片url
 @param callback 接口回调
 */
- (ApiRequest *)setBikeCoverWithBikeid:(NSString *)bikeid coverPicture:(NSString *)coverPicture callback:(API_CALLBACK)callback;

/**
 车辆列表自定义排序

 @param userid 用户id
 @param bike_seq 车辆排序数组
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)updateBikeSeqWithUserid:(NSString *)userid bike_seq:(NSArray *)bike_seq callback:(API_CALLBACK)callback;

/**
 检查设备固件升级
 
 @param bikeid 车辆id
 @param deviceid 设备id
 @param callback 接口回调
 */
- (void)checkDeviceFirmWithBikeid:(NSString *)bikeid deviceid:(NSString *)deviceid callback:(API_CALLBACK)callback;

/**
 确认升级
 
 @param bikeid 车辆id
 @param deviceid 设备id
 @param callback 接口回调
 */
- (void)confirmDeiveFirmUpdateWithBikeid:(NSString *)bikeid deviceid:(NSString *)deviceid callback:(API_CALLBACK)callback;
@end
