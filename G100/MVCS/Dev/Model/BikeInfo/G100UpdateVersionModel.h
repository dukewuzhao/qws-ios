//
//  G100UpdateVersionModel.h
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100DeviceFirmInfoModel;
@class G100DeviceFirmUpgradeHisModel;
@interface G100UpdateVersionModel : G100BaseDomain

@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

@property (nonatomic, strong) G100DeviceFirmInfoModel *firm;
@property (nonatomic, strong) NSArray <G100DeviceFirmUpgradeHisModel *>*upgrade_his;
//服务器当前时间，unix时间戳，秒
@property (nonatomic, assign) int ts;

@end

@interface G100DeviceFirmInfoModel : G100BaseDomain

///设备升级状态： 0默认状态，无更新 1有新版本 2升级下载中 3升级中 4用户已确认升级 5升级指令下发成功 6升级指令下发失败
@property (nonatomic, assign) int state;
///当前固件版本
@property (nonatomic, strong) NSString *current;
///最新可升级固件版本
@property (nonatomic, strong) NSString *latest;
///最新可升级固件版本发布时间，unix时间戳，秒
@property (nonatomic, assign) int latest_time;
///升级开始时间，unix时间戳，秒
@property (nonatomic, assign) int upgrade_begin_time;
///升级预计总时长，秒
@property (nonatomic, assign) int upgrade_total_est;
///升级预计剩余时长，秒
@property (nonatomic, assign) int upgrade_left_est;
///当前升级id，当state为0时为0
@property (nonatomic, strong) NSNumber *upgrade_id;
///"升级描述" 最新可升级固件版本更新描述
@property (nonatomic, strong) NSString *latest_desc;
///硬件升级提示
@property (nonatomic, strong) NSString *upgrade_prompt;
///升级固件写入开始时间
@property (nonatomic, assign) int upgrade_flash_begin_time;

@end

@interface G100DeviceFirmUpgradeHisModel : G100BaseDomain

///升级id
@property (nonatomic, assign) int upgrade_id;
///升级开始时间，unix时间戳，秒
@property (nonatomic, assign) int begin_time;
///升级结束时间，unix时间戳，秒
@property (nonatomic, assign) int end_time;
///升级结果 1 成功 2失败
@property (nonatomic, assign) int result;
///原因 result为2时 定义不同失败类型
@property (nonatomic, assign) int reason;
///升级版本 开始
@property (nonatomic, strong) NSString *from_firm;
///升级版本 结束
@property (nonatomic, strong) NSString *to_firm;

@end
