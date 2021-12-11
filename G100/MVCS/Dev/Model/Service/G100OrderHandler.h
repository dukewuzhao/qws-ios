//
//  G100OrderHandler.h
//  G100
//
//  Created by 曹晓雨 on 2016/10/27.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class G100DeviceDomain;
@class G100GoodDomain;

typedef enum  {
    showHint = 0,
    showWarningHint,
    showHudInView,
} orderStatusEnum;

@protocol OrderServiceDelegate <NSObject>

- (void)orderStatus:(orderStatusEnum)orderStatus msg:(NSString *)message;
- (void)submmitOrderResult:(ApiResponse *)response requestSucces:(BOOL)requestSucces orderNum:(NSString *)orderNum totalAmount:(CGFloat)totalAmount;
@end

@interface G100OrderHandler : NSObject
@property (nonatomic, weak)id<OrderServiceDelegate> delegate;


/**
 提交订单
 */
- (void)commit;

/**
 初始化订单handler

 @param selectDev  选择的设备
 @param selectGood 选择的商品
 @param bikeid     车辆id
 @param devid      设备id

 @return 
 */
- (instancetype)initWithDev:(G100DeviceDomain *)selectDev good:(G100GoodDomain *)selectGood bikeid:(NSString *)bikeid devid:(NSString *)devid;
@end
