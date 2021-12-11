//
//  G100PayOrderViewController.h
//  ebike
//
//  Created by yuhanle on 2017/11/21.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "G100BaseXibVC.h"
#import "G100OrderDomain.h"

@interface G100PayOrderViewController : G100BaseXibVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

/** APP 支付完成后
 *  可能已经从渠道中获取到支付结果信息
 *  但是仍需要通过订单号 从后台查询支付状态
 **/
@property (nonatomic, copy) NSString *orderid;

/**
 订单Model
 */
@property (nonatomic, strong) G100OrderDomain *orderModel;

@end
