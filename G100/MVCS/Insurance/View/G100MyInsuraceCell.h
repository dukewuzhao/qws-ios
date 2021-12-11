//
//  G100MyInsuraceCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BaseCell.h"

typedef void(^G100MyInsuranceStatebtnClickBlock) (NSInteger);

@interface G100MyInsuraceCell : G100BaseCell

@property (nonatomic, copy) G100MyInsuranceStatebtnClickBlock insuranceStatebtnClickBlock;

- (void)updateStatusUI;

@end
