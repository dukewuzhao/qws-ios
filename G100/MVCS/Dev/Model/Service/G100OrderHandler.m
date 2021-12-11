//
//  G100OrderHandler.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/27.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100OrderHandler.h"
#import "G100GoodDomain.h"
#import "G100DeviceDomainExpand.h"
#import "G100OrderApi.h"

@interface G100OrderHandler ()
    
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, strong) NSString *orderNumber;

@property (strong, nonatomic) G100DeviceDomain *selectDev;
@property (strong, nonatomic) G100GoodDomain   *selectGood;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;
    
@end

@implementation G100OrderHandler


- (instancetype)initWithDev:(G100DeviceDomain *)selectDev good:(G100GoodDomain *)selectGood bikeid:(NSString *)bikeid devid:(NSString *)devid
{
    self = [super init];
    if (self) {
        _selectDev= selectDev;
        _selectGood = selectGood;
        _bikeid = bikeid;
        _devid = devid;
        _amount = 1;
    }
    return self;
}
    
#pragma mark - 计算服务日期
- (void)calServiceDate
{
    NSDateFormatter * formatterPre = [[NSDateFormatter alloc]init];
    [formatterPre setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatterPre dateFromString:_selectDev.service.end_date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* dc1 = [[NSDateComponents alloc] init];
    [dc1 setMonth:_selectGood.service_months];
    if ([self.selectDev isOverdue]) {
        [dc1 setDay:(-self.selectDev.leftdays)];
    }
    
    NSDate *tmpDate = [gregorian dateByAddingComponents:dc1 toDate:date options:0];
    _selectGood.serviceenddate = [formatterPre stringFromDate:tmpDate];
}

- (void)commit {
    if (![_delegate respondsToSelector:@selector(orderStatus:msg:)]) {
        DLog(@"delegate didnot responds orderStauts");
        return;
    }
    
    if (_selectGood && _selectDev) {
        // 向服务器请求订单号
        _totalAmount = _selectGood.discount * _selectGood.price * _amount;
        if (_totalAmount == 0) {
            [self.delegate orderStatus:showWarningHint msg:@"金额不能为0"];
            return;
        }
        [self calServiceDate];
        [self submitOrder];
    }else {
        if (!_selectGood) {
            [self.delegate orderStatus:showHint msg:@"请选择套餐"];
        }else if (!_selectDev) {
            [self.delegate orderStatus:showHint msg:@"请选择要充值的车辆"];
        }
    }
}
- (void)submitOrder {
    __weak G100OrderHandler * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        if (requestSucces) {
            NSInteger orderid = [[response.data objectForKey:@"order_id"] integerValue];
            _orderNumber = [NSString stringWithFormat:@"%ld", (long)orderid];
                    
        }
        if ([wself.delegate respondsToSelector:@selector(submmitOrderResult:requestSucces:orderNum:totalAmount:)]) {
              [wself.delegate submmitOrderResult:response requestSucces:requestSucces orderNum:_orderNumber totalAmount:_totalAmount];
        }
      
    };
    
    [wself.delegate orderStatus:showHudInView msg:@"创建订单中... 请稍候"];
    [[G100OrderApi sharedInstance] sv_submitOrderWithBikeid:self.bikeid
                                                      devid:[NSString stringWithFormat:@"%@", @(_selectDev.device_id)]
                                                  productid:_selectGood.product_id
                                                  unitprice:_selectGood.price
                                                     amount:_amount
                                                   discount:_selectGood.discount
                                                     coupon:@""
                                                      price:_totalAmount
                                                  insurance:nil
                                                   callback:callback];
}

@end
