//
//  G100QRBindDevViewController.h
//  G100
//
//  Created by yuhanle on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"
#import <AVFoundation/AVFoundation.h>

@interface G100QRBindDevViewController : G100BaseVC

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userid;
/**
 *  更换设备时 需要传入旧设备要绑定的id 如果没有值 则是普通的绑定流程
 *  否则的话 就走更换设备的流程
 */
@property (copy, nonatomic) NSString *devid;
/**
 *  操作方式 0 绑定设备 1 更换设备 默认是0
 */
@property (assign, nonatomic) int operationMethod;

@property (copy, nonatomic) NSString *bikeid;

/**
 *  是否处理结果中 YES/NO
 */
@property (nonatomic, assign) BOOL isProcessing;

/**
 *  设置扫描二维码后的操作
 *
 *  @param completionBlock 块操作
 */
- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock;

/**
 *  开始扫描
 */
- (void)startScanning;
/**
 *  暂停扫描
 */
- (void)stopScanning;

/**
 *  设置扫码的模式 1 扫码添加GPS设备 2 扫码功能 可以做很多事情
 *
 *  @param mode mode
 */
- (void)setSaoYiSaoMode:(int)mode;

@end
