//
//  G100BindDevViewController.h
//  G100
//
//  Created by yuhanle on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@interface G100BindDevViewController : G100BaseVC

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userid;

/**
 *  设备对应需要绑定到的车辆id
 */
@property (copy, nonatomic) NSString *bikeid;
/**
 *  更换设备时 需要传入旧设备要绑定的id 如果没有值 则是普通的绑定流程
 *  否则的话 就走更换设备的流程
 */
@property (copy, nonatomic) NSString *devid;

/**
 *  绑定方式 1 GPS 2 手动输入 3 扫一扫功能
 */
@property (nonatomic, assign) int bindMode;

/**
 *  操作方式 0 绑定设备 1 更换设备 2 扫一扫 默认是0
 */
@property (assign, nonatomic) int operationMethod;

/**
 扫码结果
 */
@property (nonatomic, copy) NSString *qrcode;

/**
 绑定车辆
 
 @param qr_code 车辆二维码
 */
- (void)bindNewBikeWithQr_code:(NSString *)qr_code;

/**
 绑定新设备

 @param qr_code 设备二维码
 */
- (void)bindNewDeviceWithQr_code:(NSString *)qr_code;

/**
 绑定新设备
 
 @param devid 设备id
 */
- (void)bindNewDeviceWithDevid:(NSString *)devid;

@end
