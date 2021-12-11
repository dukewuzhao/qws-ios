//
//  G100PushAlarmTestView.h
//  G100
//
//  Created by yuhanle on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

/**
 *  负责测试推送这块的所有流程 
 *  涉及所有的操作和处理都在这里完成
 */
@interface G100PushAlarmTestView : G100PopBoxBaseView

@property (nonatomic, assign) NSInteger entrance;//!< 设置测试的入口 即第一步测试模块
@property (nonatomic, assign) BOOL isTrainTest;//!< 是否连续测试
@property (nonatomic, copy) NSString *userid;//!< 用户id
@property (nonatomic, copy) NSString *bikeid;//!< 车辆id
@property (nonatomic, copy) NSString *devid;//!< 设备id
@property (nonatomic, copy) NSString *phoneNum;//!< 电话报警的接收电话

@property (nonatomic, strong) NSMutableDictionary *params;//!< 如果正在测试中 测试中的信息

@end
