//
//  G100PriceCollectionViewCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/10/21.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BaseBuyServiceCollectionViewCell.h"
@class G100GoodDomain;


@interface G100PriceCollectionViewCell : G100BaseBuyServiceCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *planYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *saleLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

- (void)initUIWithMode:(G100GoodDomain *)goodsDomain;
- (CGFloat)heightForRow;

@end
