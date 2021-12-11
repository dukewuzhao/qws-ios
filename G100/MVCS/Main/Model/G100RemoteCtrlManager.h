//
//  G100RemoteCtrlManager.h
//  G100
//
//  Created by yuhanle on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100RemoteCtrlManager : NSObject

/**
 *  创建远程控制模块
 *
 *  @return 远程控制模块
 */
+ (instancetype)sharedInstance;

/**
 *  GPRS发送远程控制指令
 *
 *  @param bikeid        车辆id
 *  @param devid         设备id
 *  @param command       指令类型 1设防 2 撤防 3开关电门 4找车 5开坐桶 6开中撑锁 7 开龙头锁
 *  @param commandParams 指令参数
 *  @param type          指令参数值 type 
    设防：1正常设防 2静音设防
    撤防：暂不使用
    开关电门：1开电门 2关电门
 *  @param callback      接口回调
 */
- (void)operateAlertorWithBikeid:(NSString *)bikeid
                           devid:(NSString *)devid
                         command:(DEV_ALERTOR_COMMAND)command
                   commandParams:(NSDictionary *)commandParams
                            type:(NSInteger)type
                        callback:(API_CALLBACK)callback;

@end
