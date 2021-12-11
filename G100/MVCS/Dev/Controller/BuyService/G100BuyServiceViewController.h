//
//  G100BuyServiceViewController.h
//  G100
//
//  Created by 曹晓雨 on 2016/10/21.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100BaseVC.h"

@class G100GoodDomain;
@class G100DeviceDomain;

@interface G100BuyServiceViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

/**
 用于其他页面跳转指定类型和商品
 */
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *productid;

/**
 跳转源 1 主页顶部提示框view
 */
@property (nonatomic, strong) NSNumber *fromVc;

@end
