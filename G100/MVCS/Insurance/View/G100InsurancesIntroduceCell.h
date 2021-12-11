//
//  G100InsurancesIntroduceCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BaseCell.h"
#import "PingAnInsuranceModel.h"

typedef void(^FreebtnClickBlock)(PingAnInsuranceModel *model);
@interface G100InsurancesIntroduceCell : G100BaseCell

@property (nonatomic, strong) PingAnInsuranceModel *model;
@property (nonatomic, copy) FreebtnClickBlock freeBtnClickBlock;
@end
