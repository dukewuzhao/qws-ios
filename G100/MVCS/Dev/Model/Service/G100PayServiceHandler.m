//
//  G100PayServiceDelegate.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/26.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100PayServiceHandler.h"
#import "Pingpp.h"

#import "ServiceHintView.h"
#import "G100PaymentApi.h"
#import "G100OrderApi.h"

@implementation G100PayServiceHandler

- (void)dealloc {
    [self removeNotification];
    DLog(@"支付delegate 销毁");
}

- (instancetype)init {
    if (self) {
        [self registerNotification];
    }
    return self;
}

- (void)createWithOrderNum:(NSString * )orderNum amount:(CGFloat)amount cChannel:(NSString *)cChannel {
    _orderNumber = orderNum;
    _amount = amount;
    _cChannel = cChannel;
    
    [self realPayCommit];
}
    
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pingppPaymentResult:)
                                                 name:kGNPingPPPayResult
                                               object:nil];
}
    
- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGNPingPPPayResult
                                                  object:nil];
}

#pragma mark - 支付
-(void)realPayCommit {
    if(_cChannel && _amount && _orderNumber) {
        NSDictionary* dict = @{
                                @"channel" : self.cChannel, // 渠道 alipay, wx, upacp, bfb
                                @"amount"  : [NSNumber numberWithInteger:(NSInteger)(self.amount * 100)],   // 金额
                                @"order_no": _orderNumber
                               };
        
        __weak G100PayServiceHandler * wself = self;
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
            if (requestSucces) {
                NSString * charge = [response.data objectForKey:@"pingpp"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Pingpp createPayment:charge viewController:CURRENTVIEWCONTROLLER appURLScheme:kPingPPPayUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                        if ([result isEqualToString:@"success"]) {
                            [wself payFinished];
                        } else {
                            DLog(@"Error: code=%lu msg=%@", (unsigned long)error.code, [error getMsg]);
                            ServiceHintView * hintView = [[[NSBundle mainBundle] loadNibNamed:@"ServiceHintView" owner:wself options:nil] lastObject];
                            [hintView show];
                        }
                    }];
                });
            }
            if ([wself.delegate respondsToSelector:@selector(paymentByPingpp:requestSucces:)]) {
                 [wself.delegate paymentByPingpp:response requestSucces:requestSucces];
            }
           
        };
        if ([_delegate respondsToSelector:@selector(payStatus:msg:)])  {
           [self.delegate payStatus:showHudInView msg:@"支付中"];
        }

        [[G100PaymentApi sharedInstance] paymentByPingppWith:dict callback:callback];
    }else {
        if ([_delegate respondsToSelector:@selector(payStatus:msg:)]) {
            if (!_cChannel) {
                [self.delegate payStatus:showHint msg:@"请选择支付平台"];
            }else if (!_amount) {
                [self.delegate payStatus:showWarningHint msg:@"金额不能为0"];
            }else if (!_orderNumber){
                [self.delegate payStatus:showHint msg:@"订单号有误"];
            }
        }
    }
}

#pragma mark - 支付结果处理
- (void)pingppPaymentResult:(NSNotification *)notification {
    NSDictionary * dict = notification.userInfo;
    if ([[dict objectForKey:@"result"] isEqualToString:@"success"]) {
        [self payFinished];
    }else if ([[dict objectForKey:@"result"] isEqualToString:@"cancle"]){
        if ([self.delegate respondsToSelector:@selector(payFinished:requestSucces:faildType:)]) {
            [self.delegate payFinished:nil requestSucces:NO faildType:PFCancle];;
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(payFinished:requestSucces:faildType:)]) {
            [self.delegate payFinished:nil requestSucces:NO faildType:PFOther];;
        }
    }
}

#pragma mark - 支付成功
-(void)payFinished {
    __weak G100PayServiceHandler * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if ([wself.delegate respondsToSelector:@selector(payFinished:requestSucces:faildType:)]) {
            [wself.delegate payFinished:response requestSucces:requestSucces faildType:0];
        }
    };
    
    [[G100OrderApi sharedInstance] servicePayFinishedWithOrderid:[self.orderNumber integerValue] callback:callback];
}

@end
