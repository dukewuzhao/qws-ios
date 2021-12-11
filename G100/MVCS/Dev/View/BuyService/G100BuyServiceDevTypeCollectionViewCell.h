//
//  G100BuyServiceDevTypeCollectionViewCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/10/21.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BaseBuyServiceCollectionViewCell.h"

@interface G100BuyServiceDevTypeCollectionViewCell : G100BaseBuyServiceCollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)initUIWithMode:(G100DeviceDomain *)deviveDomain;

- (CGFloat)heightForRow;
+ (CGFloat)heightForItem:(G100DeviceDomain *)deviveDomain;

@end
