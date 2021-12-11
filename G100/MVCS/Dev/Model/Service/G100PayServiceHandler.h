//
//  G100PayServiceDelegate.h
//  G100
//
//  Created by 曹晓雨 on 2016/10/26.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    showHint = 0,
    showWarningHint,
    showHudInView,
} PayResultStatus;

typedef enum {
    PFCancle = 1,
    PFOther,
} PayFaildType;

@protocol G100PayServiceDelegate <NSObject>

@optional
- (void)payFinished:(ApiResponse *)response requestSucces:(BOOL)requestSucces faildType:(PayFaildType)faildType;
- (void)paymentByPingpp:(ApiResponse *)response requestSucces:(BOOL)requestSucces;
- (void)payStatus:(PayResultStatus)payStatus msg:(NSString *)message;

@end

@interface G100PayServiceHandler : NSObject
    
@property (copy, nonatomic) NSString * orderNumber;
@property (assign, nonatomic) CGFloat amount;
@property (nonatomic, copy) NSString * cChannel; //!< 支付渠道标识
@property (nonatomic, weak) id <G100PayServiceDelegate> delegate;

/**
 支付订单
 */
-(void)realPayCommit;

/**
 初始化支付handler

 @param orderNum 订单号
 @param amount   总额
 @param cChannel 支付方式
 */
- (void)createWithOrderNum:(NSString * )orderNum amount:(CGFloat)amount cChannel:(NSString *)cChannel;
    
@end
