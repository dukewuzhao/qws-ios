//
//  G100TestConfirmViewController.h
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

typedef void (^CompleteAlarmTestBlock)();

@interface G100TestConfirmViewController : G100BaseXibVC

@property (copy, nonatomic) NSString *userid;
@property (copy, nonatomic) NSString *bikeid;
@property (copy, nonatomic) NSString *devid;

/**
 *  是否是连续测试
 */
@property (assign, nonatomic) BOOL isTrainTest;

/**
 *  入口类型 1:App报警 2:微信报警 3:电话报警
 */
@property (assign, nonatomic) NSInteger entrance;

/**
 *  完成测试且有下一项测试时执行
 */
@property (copy, nonatomic) CompleteAlarmTestBlock completion;

@property (nonatomic, copy) NSString *phoneNum;//!< 电话报警的接收电话
@property (nonatomic, strong) NSMutableDictionary *params;//!< 如果正在测试中 测试中的信息

/**
 *  发送本地通知
 */
- (void)sendLocalNotification;

@end
