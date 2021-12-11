//
//  G100TopHintModel.m
//  G100
//
//  Created by 曹晓雨 on 2017/4/20.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TopHintModel.h"
#import "G100DeviceDomain.h"
#import "G100InsuranceManager.h"
#import "NSString+CalHeight.h"

@implementation G100TopHintModel

- (NSArray<G100TopHintViewModel *> *)allViewHints {
    NSMutableArray <G100TopHintViewModel *> * temp = [[NSMutableArray alloc] init];
    
    if (self.devServiceOverdueArr.count) {
        NSString *text = @"";
        UIColor *bgColor = [UIColor colorWithHexString:@"#00afa0"]; //绿色
        G100DeviceDomain *deviceDomain = self.devServiceOverdueArr.firstObject;
        if (deviceDomain.leftdays <= 0) {
            if (deviceDomain.leftdays <= -15) {
                text = @"请致电客服重新开通服务!";
                bgColor = [UIColor colorWithHexString:@"#ee0000"];  //红色
            }else {
                text = @"服务期已到期，设备无法使用，点击充值";
                bgColor = [UIColor colorWithHexString:@"#ff6c00"]; //黄色
            }
        }else {
            text = [NSString stringWithFormat:@"%ld天后，服务期将到期，点击充值", deviceDomain.leftdays];
        }
        
        G100TopHintViewModel *thvm = [[G100TopHintViewModel alloc] init];
        thvm.text = text;
        thvm.bgColor = bgColor;
        thvm.hintType = TopHintBuy;
        [temp addObject:thvm];
    }else if (self.waitUpdateArray.count) {
        NSString *text = @"设备有新版本，点击升级！";
        UIColor *bgColor = [UIColor colorWithHexString:@"#ee0000"];  //红色
        G100TopHintViewModel *thvm = [[G100TopHintViewModel alloc] init];
        thvm.text = text;
        thvm.bgColor = bgColor;
        thvm.hintType = TopHintUpdate;
        [temp addObject:thvm];
    }else if (self.insuranceBannerArr.count) {
        G100InsuranceBanner *insuranceBanner = self.insuranceBannerArr.firstObject;
        NSString *text = [NSString stringWithFormat:@"%ld天内，可以%@，点击领取", insuranceBanner.number, insuranceBanner.title];;
        UIColor *bgColor = [UIColor colorWithHexString:@"#ee0000"]; //红色
        G100TopHintViewModel *thvm = [[G100TopHintViewModel alloc] init];
        thvm.text = text;
        thvm.bgColor = bgColor;
        thvm.hintType = TopHintPullInsurance;
        [temp addObject:thvm];
    }
    
    return temp.copy;
}

- (CGFloat)viewHeight {
    _viewHeight = 0;
    
    for (G100TopHintViewModel *thvm in self.allViewHints) {
        CGFloat height = [NSString heightWithText:thvm.text fontSize:[UIFont systemFontOfSize:14] Width:WIDTH - 40] + 3;
        if (height <= 20) {
            height = 20;
        }
        _viewHeight = _viewHeight + height;
    }
    
    return _viewHeight;
}

@end

@implementation G100TopHintViewModel

@end
