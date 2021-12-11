//
//  G100TopHintModel.h
//  G100
//
//  Created by 曹晓雨 on 2017/4/20.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100UpdateVersionModel.h"

@class G100DeviceDomain;
@class G100InsuranceBanner;
@class G100TopHintViewModel;
@interface G100TopHintModel : G100BaseDomain

/** 流量提醒 */
@property (nonatomic, strong) NSArray <G100DeviceDomain *> *devServiceOverdueArr;

/** 更新提醒 */
@property (nonatomic, strong) NSArray <G100UpdateVersionModel *> *waitUpdateArray;

/** 保险待领取 */
@property (nonatomic, strong) NSArray <G100InsuranceBanner *> *insuranceBannerArr;

/** 顶部提示条模型 */
@property (nonatomic, strong) NSArray <G100TopHintViewModel *> *allViewHints;

/** View 的高度 */
@property (nonatomic, assign) CGFloat viewHeight;

@end

typedef enum : NSUInteger {
    TopHintBuy = 0,
    TopHintUpdate,
    TopHintPullInsurance,
} TopHintType;

@interface G100TopHintViewModel : NSObject

@property (nonatomic, assign) TopHintType hintType;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *bgColor;

@end
